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
    property double scaleFactor: 1.0
    property bool active: true
    property bool paused: false

    property int maxNum: 100

    Component.onCompleted: {
        // var monster1=spawnMonster(monsters,"babyAlien")
        // monster1.x=800
        // monster1.y=800
        // monster1.target=target
        // monster1.active=false
        // var monster3=spawnMonster(monsters,"babyAlien")
        // monster3.x=900
        // monster3.y=800
        // monster3.target=target
        // monster3.active=false
        // var monster2=spawnMonster(monsters,"babyAlien")
        // monster2.x=1000
        // monster2.y=800
        // monster2.target=monster1

        // var monster4=spawnMonster(monsters,"babyAlien")
        // monster4.x=800
        // monster4.y=1000
        // monster4.target=monster1
        // var monster5=spawnMonster(monsters,"babyAlien")
        // monster5.x=800
        // monster5.y=900
        // monster5.target=target
        // monster5.active=false

        // var monster6=spawnMonster(monsters,"babyAlien")
        // monster6.x=930
        // monster6.y=930
        // monster6.target=monster1
        // var monster7=spawnMonster(monsters,"babyAlien")
        // monster7.x=850
        // monster7.y=850
        // monster7.target=target
        // monster7.active=false

        //monsters.spawnMonsters(100,"babyAlien")
        //monsters.spawnMonsters(1,"charger")
        monsters.spawnMonsters(10,"sprayer")
    }

    onPausedChanged: {
        if(paused==true){
            sleepTimer.pause()
            createMonsterTimer.pause()
        }else{
            sleepTimer.resume()
            createMonsterTimer.resume()
        }
    }

    MonsterCustomizationCore{
        id: monsterCore
    }

    //用来管理所有怪物生成的子弹
    Bullets{
        id: bullets
        target: monsters.target
        active: true
        scaleFactor: monsters.scaleFactor
        z: 3000
    }

    //用来实现从fork生成到怪物生成之间的时间间隔
    TimerCanPause {
        id: sleepTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            if(monsters.active)monsters.forksToMonsters()
        }
    }

    //定时生成怪物
    TimerCanPause {
        id: createMonsterTimer
        interval: 3000; running: monsters.active; repeat: true
        onTriggered: {
            if(!monsters.active)return
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

    //检测怪物间的碰撞
    Timer {
        id: checkCollidingMonsterTimer
        interval: 50; running: monsters.active && !monsters.paused; repeat: true
        onTriggered: {
            for (var i = 0; i < monsters.children.length; i++) {
                var child = monsters.children[i];
                if (child.objectName === "Monster") {
                    if(monsters.isFrontHaveOtherMonster(child,child.width/2))child.isFrontHaveOtherMonster=true
                    else child.isFrontHaveOtherMonster=false
                }
            }
        }
    }

    //返回target的前进方向checkDistance处有其他怪物挡路的布尔值
    function isFrontHaveOtherMonster(target,checkDistance){
        for (var i = 0; i < monsters.children.length; i++) {
            var other = monsters.children[i];
            if (other.objectName === "Monster") {
                if(other==target || other.monsterName!==target.monsterName)continue
                var dx=target.x-other.x
                var dy=(target.y+target.height)-(other.y+other.height)
                if(target.isFaceRight){
                    if(dx<=0){
                        if(target.isFaceUp){
                            if(dy>=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }else{
                            if(dy<=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }
                    }
                }else{
                    if(dx>=0){
                        if(target.isFaceUp){
                            if(dy>=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }else{
                            if(dy<=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }
                    }
                }
            }
        }
        return false
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

    //返回range范围内距离坐标(x,y)最近的怪物
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

    //令所有怪物消失
    function disappear(){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                child.disappear()
            }
        }
        for (var i = 0; i < monsters.parent.children.length; i++) {
            var child = monsters.parent.children[i];
            if(child.objectName === "Fork"){
                child.destroy()
            }
        }
        bullets.clear()
    }

    //生成n个怪物名为monsterName的怪物
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
                fork.paused=Qt.binding(function(){return monsters.paused})
            }
            sleepTimer.start()
        }else console.error("Error loading component:", forkComponent.errorString())
    }

    //将场上所有的fork转换成对应的怪物
    function forksToMonsters() {
            for (var i = 0; i < monsters.parent.children.length; i++) {
                var child = monsters.parent.children[i]
                if (child.objectName === "Fork") {
                    var monster = spawnMonster(monsters,child.targetMonsterName)
                    monster.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                    monster.x = child.x
                    monster.y = child.y
                    monster.owner=monsters
                    monster.target=monsters.target
                    monster.bulletsParent=bullets
                    monster.active=Qt.binding(function(){return monsters.active})
                    monster.paused=Qt.binding(function(){return monsters.paused})
                    if((monster.x-monster.target.x)>0)monster.faceLeft()
                    else monster.faceRight()
                    child.destroy()
                }
            }
    }

    //在parent中动态生成一个怪物名为monsterName的怪物
    function spawnMonster(parent,monsterName) {
        var source=monsterCore.getMonster(monsterName).source
        var monsterComponent = Qt.createComponent(source)
        if (monsterComponent.status === Component.Ready) {
            var monster = monsterComponent.createObject(parent);
        }else console.error("Error loading component:", monsterComponent.errorString())
        return monster
    }

    //在materialsParent中怪物monster的当前位置上生成其死亡时应掉落的材料
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
        }else console.log("Error loading component:", materialComponent.errorString())
    }

    function spawnBullet(x,y,width,height,damage,range,shootAngle,color){
        var bulletComponent = Qt.createComponent("../components/RoundBullet.qml")
        if (bulletComponent.status === Component.Ready) {
            var bullet = bulletComponent.createObject(bullets);
            bullet.scaleFactor=Qt.binding(function(){return monsters.scaleFactor})
            bullet.paused=Qt.binding(function(){return monsters.paused})
            bullet.width=width
            bullet.height=height
            bullet.x=x - bullet.width / 2
            bullet.y=y - bullet.height / 2
            bullet.originPoint=Qt.point(x - bullet.width / 2,y - bullet.height / 2)
            bullet.color=color
            bullet.damage=damage
            bullet.range=range
            bullet.shootAngle=shootAngle
        }else console.error("Error loading component:", bulletComponent.errorString())
    }
}
