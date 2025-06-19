import QtQuick 2.15
import "../data"
import "../components"
import "../tool.js" as Tool

Item {
    id: monsters
    anchors.fill: parent
    objectName: "Monsters"
    z: 3
    property string difficulty
    property Player target: null
    property var materialsParent: parent
    property bool active: true
    property double scaleFactor: 1.0

    property int waveNumber: 0
    property int maxNum: 100

    Component.onCompleted: {
        //monsters.spawnMonsters(1,"pursuer")
        //monsters.spawnMonsters(1,"charger")
    }

    //返回当前被target击中的怪物
    function getCollidingChild(target){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                if(child.isDead==true)continue
                if(Math.abs(target.x-child.x)<(target.width+child.width)/2 && Math.abs(target.y-child.y)<(target.height+child.height)/2){
                    return child
                }
            }
        }
        return null
    }

    function getClosestMonster(x,y,range){
        if(monsters.children.length==0)return null
        var m=null
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                if(child.isDead==true)continue
                if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(x,y))<range){
                    if(m==null)m=child
                    else if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(x,y)) < Tool.getDistance(Qt.point(m.x,m.y),Qt.point(x,y)))m=child
                }
            }
        }
        return m
    }

    function disappear(){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                child.disappear()
            }
        }
        bullets.clear()
    }

    function spawnMonsters(n,monsterName) {
        var forkComponent = Qt.createComponent("../components/Fork.qml");
        if (forkComponent.status === Component.Ready) {
            for(var i=0;i<n;i++){
                var margin = 50
                var x=Math.random() * (monsters.parent.width - margin*2)+margin;
                var y=Math.random() * (monsters.parent.height - margin*2)+margin;
                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(x,y))<300){//离玩家太近时重新定位
                    i--
                    continue
                }
                var fork = forkComponent.createObject(monsters.parent);
                fork.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                fork.x = x
                fork.y = y
                fork.rotation = Math.random() * 360
                fork.targetMonsterName=monsterName
            }
            sleepTimer.start()
        }else console.error("Error loading component:", forkComponent.errorString())
    }

    function forksToMonsters() {
            for (var i = 0; i < monsters.parent.children.length; i++) {
                var child = monsters.parent.children[i];
                if (child.objectName === "Fork") {
                    var source=monsterCore.getMonster(child.targetMonsterName).source
                    var monsterComponent = Qt.createComponent(source);
                    if (monsterComponent.status === Component.Ready) {
                        var monster = monsterComponent.createObject(monsters);
                        monster.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                        monster.x = child.x;
                        monster.y = child.y;
                        monster.z = 2
                        monster.owner=monsters
                        monster.target=monsters.target
                        monster.waveNumber=monsters.waveNumber
                        monster.bulletsParent=bullets
                        child.destroy();
                    }else console.error("Error loading component:", monsterComponent.errorString())
                }
            }
    }

    function dropMaterial(monster){
        var materialComponent=Qt.createComponent("../components/Material.qml")
        if (materialComponent.status === Component.Ready){
            for(var i=0;i<monster.monsterData.materialDrops;i++){
                var material=materialComponent.createObject(materialsParent)
                material.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                if(i==0){
                    material.x=monster.x+monster.width/2-material.width/2
                    material.y=monster.y+monster.height-material.height
                }else{
                    material.x=monster.x+monster.width/2-material.width/2+(Math.random()-0.5)*monster.width*2
                    material.y=monster.y+monster.height-material.height+(Math.random()-0.5)*monster.width*2
                }
            }
        }else console.log("Error loading component:", materialComponent.errorString());
    }

    MonsterCustomizationCore{
        id: monsterCore
        waveNumber: monsters.waveNumber
    }

    Bullets{
        id: bullets
        target: monsters.target
        active: true
        scaleFactor: monsters.scaleFactor
        z: 3
    }

    Timer {
        id: sleepTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            monsters.forksToMonsters()
        }
        function start(){
            running=true
        }
    }

    Timer {
        id: createMonsterTimer
        interval: 3000; running: monsters.active; repeat: true
        onTriggered: {
            if(monsters.children.length<monsters.maxNum){
                //console.log(monsterCore.children.length)
                for(var i=0;i<monsterCore.children.length;i++){
                    var monsterData=monsterCore.children[i]
                    var n=Math.floor(monsterData.initCount*monsterData.countRation)
                    if(n==0)continue
                    //console.log(n,monsterData.initCount,monsterData.countRation)
                    monsterData.countRation*=1+monsterData.countIcreaseRation
                    monsters.spawnMonsters(n,monsterData.objectName)
                }
            }
        }
    }
}
