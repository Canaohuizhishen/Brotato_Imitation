import QtQuick 2.15
import "../tool.js" as Tool

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

    function charge(){
        isCharging=true
        active=false
        var dx=charger.x-charger.target.x
        var dy=charger.y-charger.target.y
        var distance = Math.sqrt(dx * dx + dy * dy);
        var x=charger.x-dx/distance*chargeRange
        var y=charger.y-dy/distance*chargeRange
        if(dx>0)charger.faceLeft()
        else charger.faceRight()
        faceTarget=false
        chargeAnimation.targetPoint=Qt.point(Math.min(Math.max(x,0),charger.parent.width-charger.width),Math.min(Math.max(y,0),charger.parent.height-charger.height))
        chargeAnimation.start()
        makeRedMask(charger)
    }

    function makeRedMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: redOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/${monsterName}_redMask_faceRight.png" : "/images/${monsterName}_redMask_faceLeft.png"
                        z: 100
                        Component.onCompleted: {
                        }
                        SequentialAnimation {
                            loops: 1
                            running: true
                            OpacityAnimator {
                                target: redOverlay
                                from: 0
                                to: 0.9
                                duration: 600
                                onStopped: {
                                    redOverlay.destroy()
                                }
                            }
                            OpacityAnimator {
                                target: redOverlay
                                from: 0.9
                                to: 0
                                duration: 200
                                onStopped: {
                                    redOverlay.destroy()
                                }
                            }
                        }
                    }`,
                    parent,
                    "dynamicImage"
                    );
    }

    Timer {
        id: checkTimer
        interval: 100
        running: !charger.isCharging && !charger.inChargeCoolDown
        repeat: true
        onTriggered: {
            var inAttackRange=Tool.getDistance(Qt.point(charger.x,charger.y),Qt.point(charger.target.x,charger.target.y))<charger.core.attackRange
            if(inAttackRange)charger.charge()
        }
    }

    Timer {
        id: coolDownTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: {
            charger.inChargeCoolDown=false
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
            NumberAnimation { target: charger; property: "x"; to: chargeAnimation.targetPoint.x; duration: chargeAnimation.targetPoint.x==0||chargeAnimation.targetPoint.x==charger.parent.width-charger.width ? Math.abs(charger.x-chargeAnimation.targetPoint.x) : charger.chargeRange; easing.type: Easing.Linear }
            NumberAnimation { target: charger; property: "y"; to: chargeAnimation.targetPoint.y; duration: chargeAnimation.targetPoint.y==0||chargeAnimation.targetPoint.y==charger.parent.height-charger.height ? Math.abs(charger.y-chargeAnimation.targetPoint.y) : charger.chargeRange; easing.type: Easing.Linear }
        }

        onStopped: {
            charger.inChargeCoolDown=true
            coolDownTimer.start()
            charger.isCharging=false
            charger.active=true
            charger.faceTarget=true
            running=false
        }
    }

    Timer {
        id: collisionDetectionTimer
        interval: charger.interval; running: chargeAnimation.running; repeat: true
        onTriggered: {
            if (Tool.getDistance(Qt.point(charger.x,charger.y),Qt.point(charger.target.x,charger.target.y)) < charger.target.width/2) {//已碰撞
                charger.hit()
            }
        }
    }

}
