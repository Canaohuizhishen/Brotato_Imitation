import QtQuick 2.15
import "../tool.js" as Tool

Item {
    id: monsters
    anchors.fill: parent
    z: 2
    property string difficulty
    property Player target: null
    property bool active: true
    property double scaleFactor: 1.0
    property int interval: 5
    property double v: 0.05*scaleFactor
    property double stepSize: v*interval

    property int maxNum: 100
    property double nextspawnMonstersCount: 5
    property double monsterSpawnRateIncrease: 0.05

    Component.onCompleted: {
        //spawnForks(1)
    }

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

    function killAll(){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                child.kill()
            }
        }
    }

    function spawnForks(n) {
        var forkComponent = Qt.createComponent("../components/Fork.qml");
        if (forkComponent.status === Component.Ready) {
            for(var i=0;i<n;i++){
                var fork = forkComponent.createObject(monsters.parent);
                fork.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                var margin = 50
                fork.x = Math.random() * (monsters.parent.width - margin*2)+margin;
                fork.y = Math.random() * (monsters.parent.height - margin*2)+margin;
                fork.rotation = Math.random() * 360
            }
            sleepTimer.start()
        }else console.log("Monsters.qml: 找不到文件: Fork.qml")
    }

    function spawnMonsters() {
        var monsterComponent = Qt.createComponent("Monster.qml");
        if (monsterComponent.status === Component.Ready) {
            for (var i = 0; i < monsters.parent.children.length; i++) {
                var child = monsters.parent.children[i];
                if (child.objectName === "Fork") {
                    var monster = monsterComponent.createObject(monsters);
                    monster.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                    monster.x = child.x;
                    monster.y = child.y;
                    monster.z = 2
                    child.destroy();
                }
            }
        }
    }

    Timer {
        id: sleepTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            monsters.spawnMonsters()
        }
        function start(){
            running=true
        }
    }

    Timer {
        id: createMonsterTimer
        interval: 2000; running: monsters.active; repeat: true
        onTriggered: {
            if(monsters.children.length<monsters.maxNum){
                var n=Math.floor(Math.random()*(monsters.nextspawnMonstersCount-3)+3)
                //console.log(n)
                monsters.spawnForks(n)
                monsters.nextspawnMonstersCount=monsters.nextspawnMonstersCount*(1+monsters.monsterSpawnRateIncrease)
            }else monsters.nextspawnMonstersCount/=2
            //console.log(monsters.children.length,monsters.nextspawnMonstersCount)
        }
    }

    Timer {
        id: monsterMoveTimer
        interval: monsters.interval; running: monsters.active; repeat: true
        onTriggered: {
            for (var i = 0; i < monsters.children.length; i++) {
                var child = monsters.children[i];
                if (child.objectName === "Monster") {//console.log("1")
                    if(child.isDead==true)continue
                    if(!child.active)continue
                    var dx = (monsters.target.x + monsters.target.width/2) - (child.x + child.width/2);
                    var dy = (monsters.target.y + monsters.target.height/2) - (child.y + child.height/2);
                    var distance = Math.sqrt(dx * dx + dy * dy);

                    if (distance < monsters.stepSize) {
                        child.x = monsters.target.x + monsters.target.width/2 - child.width/2;
                        child.y = monsters.target.y + monsters.target.height/2 - child.height/2;
                    } else {
                        var stepX = (dx / distance) * monsters.stepSize;
                        var stepY = (dy / distance) * monsters.stepSize;
                        child.x += stepX;
                        child.y += stepY;
                    }

                    if(dx<0)child.faceLeft()
                    else child.faceRight()
                }
            }
        }
    }

    // 碰撞检测
    function checkCollisions() {
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {console.log("2")  // 调试输出
                if (target.x < child.x + child.width &&
                    target.x + target.width > child.x &&
                    target.y < child.y + child.height &&
                    target.y + target.height > child.y) {
                    monsters.gameOver = true;
                    monsterMoveTimer.stop();
                    gameOverText.visible = true;
                }
            }
        }
    }

}
