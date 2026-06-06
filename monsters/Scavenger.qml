import QtQuick 2.15
import "../components"
import "../logic/utils/tool.js" as Tool

Monster{
    id: scavenger
    monsterName: "scavenger"
    imageWidth: 50
    imageHeight: imageWidth*1.17
    property int sprayRange: 1000

    onIsDeadChanged: {
        if(sprayAnimation.running)sprayAnimation.pause()
    }

    onPausedChanged: {
        if(paused==true){
            sprayAnimation.pause()
            shootAnimation.pause()
        }else{
            sprayAnimation.resume()
            shootAnimation.resume()
        }
    }

    function setGoalRandomly() {
        if (!active || paused) return
        var margin = 50
        var rx, ry
        do {
            rx = Math.random() * (owner.width - margin * 2) + margin
            ry = Math.random() * (owner.height - margin * 2) + margin
        } while (Tool.getDistance(Qt.point(x, y), Qt.point(rx, ry)) < v * interval / 1000)
        target = { x: rx, y: ry, width: 0, height: 0 }
        spray()
    }

    // 基类 Monster.updateMovement 在到达目标点时自动调用此函数
    function onReachTarget() {
        setGoalRandomly()
    }

    // 阻塞超过 1 秒仍未滑开 → 换方向
    function onBlockedTimeout() {
        setGoalRandomly()
    }

    transform: Scale {
        id: squashScale
        origin.x: scavenger.width/2
        origin.y: scavenger.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: sprayAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(scavenger.x,scavenger.y)

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; from: 1; to: 0.7; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; from: 1; to: 1.3; duration: 500; easing.type: Easing.InOutQuad }
        }

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.2; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.8; duration: 100; easing.type: Easing.OutQuad }
        }
        onStopped: {
            shootAnimation.start()
            running=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    ParallelAnimation {
        id: shootAnimation
        loops: 1
        running: false
        NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
        NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
        onStarted: {
            scavenger.fire()
        }
        onStopped: {
            running=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    // 预声明红色遮罩
    Image {
        id: redMask
        anchors.fill: parent
        source: scavenger.isFaceRight ? "qrc:/images/" + monsterName + "_redMask_faceRight.png" : "qrc:/images/" + monsterName + "_redMask_faceLeft.png"
        visible: false
        opacity: 1.0
        z: 100

        SequentialAnimation {
            id: maskAnimator
            running: false

            OpacityAnimator {
                target: redMask
                from: 0
                to: 0.55
                duration: 600
            }
            OpacityAnimator {
                target: redMask
                from: 0.55
                to: 0
                duration: 200
                onStopped: redMask.visible = false
            }
        }
    }

    function showRedMask() {
        redMask.visible = true
        maskAnimator.restart()
    }

    function spray(){
        var dx=scavenger.x-scavenger.target.x
        var dy=scavenger.y-scavenger.target.y
        var distance = Math.sqrt(dx * dx + dy * dy);
        var x=scavenger.x-dx/distance*sprayRange
        var y=scavenger.y-dy/distance*sprayRange
        sprayAnimation.targetPoint=Qt.point(Math.min(Math.max(x,0),scavenger.parent.width-scavenger.width),Math.min(Math.max(y,0),scavenger.parent.height-scavenger.height))
        sprayAnimation.start()
        showRedMask()
    }

    function fire() {
        var dx = (scavenger.x + scavenger.width / 2) - scavenger.target.x
        var dy = (scavenger.y + scavenger.height / 2) - scavenger.target.y
        var angle = Math.atan2(dy, dx) * 180 / Math.PI;
        var x = scavenger.x + scavenger.width*2/3 - Math.cos(angle * (Math.PI / 180)) * scavenger.width *3/5
        var y = scavenger.y + scavenger.height*2/3 - Math.sin(angle * (Math.PI / 180)) * scavenger.height *3/5
        scavenger.parent.spawnBullet(x,y,scavenger.width / 2,scavenger.width / 2,scavenger.monsterData.damage,scavenger.sprayRange,180-angle,Qt.rgba(1, 0, 0, 1))
    }


}
