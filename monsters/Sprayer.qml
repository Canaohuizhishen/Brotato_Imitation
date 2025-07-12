import QtQuick 2.15
import "../components"
import "../tool.js" as Tool

Monster{
    id: sprayer
    monsterName: "sprayer"
    imageWidth: 53
    imageHeight: imageWidth*0.9346
    property int sprayRange: core.attackRange*3*scaleFactor
    property int stopRange: core.attackRange*2/3*scaleFactor
    property int escapeRange: stopRange*2/3
    property bool isSpraying: false
    property bool isEscaping: false
    property bool insprayCoolDown: false

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

    function checkSprayBehavior() {
        if (!active || paused) return
        var distance = Tool.getDistance(Qt.point(x, y), Qt.point(target.x, target.y))
        var inAttackRange = distance < core.attackRange * scaleFactor
        if (inAttackRange && !isSpraying && !insprayCoolDown) spray()
        if (distance < stopRange && !isEscaping) isMoveStoped = true
        else isMoveStoped = false
        if (distance < escapeRange) {
            isEscaping = true
            moveDirectionConverse = true
        } else if (distance > stopRange) {
            isEscaping = false
            moveDirectionConverse = false
        }
        if (isInEdge()) {
            isEscaping = false
        }
    }

    TimerCanPause {
        id: coolDownTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            sprayer.insprayCoolDown=false
        }
    }

    transform: Scale {
        id: squashScale
        origin.x: sprayer.width/2
        origin.y: sprayer.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: sprayAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(sprayer.x,sprayer.y)

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
            sprayer.fire()
        }
        onStopped: {
            sprayer.isSpraying=false
            sprayer.insprayCoolDown=true
            coolDownTimer.start()
            running=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    function spray(){
        isSpraying=true
        var dx=sprayer.x-sprayer.target.x
        var dy=sprayer.y-sprayer.target.y
        var distance = Math.sqrt(dx * dx + dy * dy);
        var x=sprayer.x-dx/distance*sprayRange
        var y=sprayer.y-dy/distance*sprayRange
        sprayAnimation.targetPoint=Qt.point(Math.min(Math.max(x,0),sprayer.parent.width-sprayer.width),Math.min(Math.max(y,0),sprayer.parent.height-sprayer.height))
        sprayAnimation.start()
        makeRedMask(sprayer)
    }

    function fire() {
        var dx = (sprayer.x + sprayer.width / 2) - (sprayer.target.x+sprayer.target.width/2)
        var dy = (sprayer.y + sprayer.height / 2) - (sprayer.target.y+sprayer.target.height/2)
        var angle = Math.atan2(dy, dx) * 180 / Math.PI;
        var x = sprayer.x + sprayer.width*2/3 - Math.cos(angle * (Math.PI / 180)) * sprayer.width *3/5
        var y = sprayer.y + sprayer.height*2/3 - Math.sin(angle * (Math.PI / 180)) * sprayer.height *3/5
        sprayer.parent.spawnBullet(x,y,sprayer.width / 2,sprayer.width / 2,sprayer.monsterData.damage,sprayer.sprayRange,180-angle,Qt.rgba(1, 0, 0, 1))
    }

    function makeRedMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: redOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "qrc:/images/sprayer_redMask_faceRight.png" : "qrc:/images/sprayer_redMask_faceLeft.png"
                        z: 100
                        Component.onCompleted: {
                        }
                        SequentialAnimation {
                            loops: 1
                            running: true
                            OpacityAnimator {
                                target: redOverlay
                                from: 0
                                to: 0.55
                                duration: 600
                                onStopped: {
                                    redOverlay.destroy()
                                }
                            }
                            OpacityAnimator {
                                target: redOverlay
                                from: 0.55
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
}
