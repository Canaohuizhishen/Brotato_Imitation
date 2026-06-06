import QtQuick 2.15
import "../logic/utils/tool.js" as Tool
import "../components"

Monster{
    id: charger
    monsterName: "charger"
    imageWidth: 53
    imageHeight: imageWidth*0.9346
    property int chargeRange: charger.core.attackRange*2
    property bool isCharging: false
    property bool inChargeCoolDown: false

    onIsDeadChanged: {
        if(chargeAnimation.running)chargeAnimation.pause()
    }

    onPausedChanged: {
        if(paused==true){
            chargeAnimation.pause()
        }else{
            chargeAnimation.resume()
        }
    }

    function charge(){
        isCharging=true
        active=false
        var dx=charger.x-charger.target.x
        var dy=charger.y-charger.target.y
        var distance = Math.sqrt(dx * dx + dy * dy);
        var x=charger.x-dx/distance*chargeRange*scaleFactor
        var y=charger.y-dy/distance*chargeRange*scaleFactor
        if(dx>0)charger.faceLeft()
        else charger.faceRight()
        faceTarget=false
        chargeAnimation.targetPoint=Qt.point(Math.min(Math.max(x,0),charger.parent.width-charger.width),Math.min(Math.max(y,0),charger.parent.height-charger.height))
        chargeAnimation.start()
        showRedMask()
    }

    // 预声明红色遮罩（对象池模式，避免运行时 Qt.createQmlObject）
    Image {
        id: redMask
        anchors.fill: parent
        source: charger.isFaceRight ? "qrc:/images/" + monsterName + "_redMask_faceRight.png" : "qrc:/images/" + monsterName + "_redMask_faceLeft.png"
        visible: false
        opacity: 1.0
        z: 100

        SequentialAnimation {
            id: maskAnimator
            running: false

            OpacityAnimator {
                target: redMask
                from: 0
                to: 0.7
                duration: 600
            }
            OpacityAnimator {
                target: redMask
                from: 0.7
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

    TimerCanPause {
        id: coolDownTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: {
            charger.inChargeCoolDown=false
        }
    }

    function checkChargeRange() {
        if (isCharging || inChargeCoolDown || paused || !active) return
        var inAttackRange = Tool.getDistance(Qt.point(x, y), Qt.point(target.x, target.y)) < core.attackRange * scaleFactor
        if (inAttackRange) charge()
    }

    function checkChargeCollision() {
        if (!chargeAnimation || !chargeAnimation.running || paused) return
        if (Tool.getDistance(Qt.point(x, y), Qt.point(target.x, target.y)) < target.width / 2) {
            hit()
        }
    }

    transform: Scale {
        id: squashScale
        origin.x: charger.width/2
        origin.y: charger.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: chargeAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(charger.x,charger.y)

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; from: 1; to: 0.7; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; from: 1; to: 1.3; duration: 600; easing.type: Easing.InOutQuad }
        }

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.2; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.8; duration: 100; easing.type: Easing.OutQuad }
        }

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: charger; property: "x"; to: chargeAnimation.targetPoint.x; duration: chargeAnimation.targetPoint.x===0||chargeAnimation.targetPoint.x===charger.parent.width-charger.width ? Math.abs(charger.x-chargeAnimation.targetPoint.x) : charger.chargeRange; easing.type: Easing.Linear }
            NumberAnimation { target: charger; property: "y"; to: chargeAnimation.targetPoint.y; duration: chargeAnimation.targetPoint.y===0||chargeAnimation.targetPoint.y===charger.parent.height-charger.height ? Math.abs(charger.y-chargeAnimation.targetPoint.y) : charger.chargeRange; easing.type: Easing.Linear }
        }

        onStopped: {
            charger.inChargeCoolDown=true
            coolDownTimer.start()
            charger.isCharging=false
            charger.active=true
            charger.faceTarget=true
            running=false
        }

        function pause(){
            if(running)paused=true
        }
    }

}
