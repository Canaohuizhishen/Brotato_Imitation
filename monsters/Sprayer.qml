import QtQuick 2.15
import "../tool.js" as Tool

Monster{
    id: sprayer
    monsterName: "sprayer"
    imageWidth: 53
    imageHeight: imageWidth*0.9346
    property int sprayRange: core.attackRange*3*scaleFactor
    property int stopRange: core.attackRange*2/3
    property int escapeRange: stopRange*2/3
    property bool isSpraying: false
    property bool isEscaping: false
    property bool insprayCoolDown: false

    onIsDeadChanged: {
        if(sprayAnimation.running)sprayAnimation.pause()
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
        var dx = sprayer.x + sprayer.width / 2 - (sprayer.target.x+sprayer.target.width/2)
        var dy = sprayer.y + sprayer.height / 2 - (sprayer.target.y+sprayer.target.height/2)
        var angle = Math.atan2(dy, dx) * 180 / Math.PI;
        var x = sprayer.x + sprayer.width*2/3 - Math.cos(angle * (Math.PI / 180)) * sprayer.width *3/5
        var y = sprayer.y + sprayer.height*2/3 - Math.sin(angle * (Math.PI / 180)) * sprayer.height *3/5
        var bullet = Qt.createQmlObject(
            `import QtQuick 2.15;
            Canvas {
                id: bullet
                width: ${sprayer.width / 2}
                height: width
                objectName: "子弹"
                x: ${x - width / 2}
                y: ${y - height / 2}
                z: 5
                property int damage: ${sprayer.monsterData.damage}
                onPaint: {
                    var ctx = getContext("2d")
                    var gradient = ctx.createRadialGradient(
                        width / 2, height / 2, 0,
                        width / 2, height / 2, Math.max(width / 2, height / 2)
                    )
                    gradient.addColorStop(0, Qt.rgba(1, 1, 1, 1))
                    gradient.addColorStop(0.38, Qt.rgba(1, 1, 1, 1))
                    gradient.addColorStop(0.5, Qt.rgba(1, 0.2, 0.2, 1))
                    gradient.addColorStop(0.75, Qt.rgba(1, 0, 0, 1))
                    gradient.addColorStop(1, Qt.rgba(1, 0, 0, 0))
                    ctx.fillStyle = gradient
                    ctx.beginPath()
                    ctx.ellipse(0, 0, width, height)
                    ctx.fill()
                }
                Component.onCompleted: {
                    shoot.start()
                }
                ParallelAnimation {
                    id: shoot
                    running: false
                    property int range: ${sprayer.sprayRange}
                    NumberAnimation { target: bullet; property: "x"; to: ${x - Math.cos(angle * (Math.PI / 180)) * sprayer.sprayRange}; loops: 1; duration: 3 * shoot.range; easing.type: Easing.Linear }
                    NumberAnimation { target: bullet; property: "y"; to: ${y - Math.sin(angle * (Math.PI / 180)) * sprayer.sprayRange}; loops: 1; duration: 3 * shoot.range; easing.type: Easing.Linear }
                    onStopped: bullet.destroy()
                }
            }`,
            sprayer.bulletsParent,
            "dynamicImage"
        );
    }

    function makeRedMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: redOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/sprayer_redMask_faceRight.png" : "/images/sprayer_redMask_faceLeft.png"
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
        running: true
        repeat: true
        onTriggered: {
            var distance=Tool.getDistance(Qt.point(sprayer.x,sprayer.y),Qt.point(sprayer.target.x,sprayer.target.y))
            var inAttackRange=distance<sprayer.core.attackRange
            if(inAttackRange && !sprayer.isSpraying && !sprayer.insprayCoolDown && !sprayer.isEscaping)sprayer.spray()
            if(distance<sprayer.stopRange && !sprayer.isEscaping)sprayer.active=false
            else sprayer.active=true
            if(distance<sprayer.escapeRange){
                sprayer.isEscaping=true
                sprayer.moveDirectionConverse=true
            }else if(distance>sprayer.stopRange){
                sprayer.isEscaping=false
                sprayer.moveDirectionConverse=false
            }
            if(sprayer.isInEdge()){
                sprayer.isEscaping=false
            }
        }
    }

    Timer {
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
    }

    Timer {
        id: collisionDetectionTimer
        interval: sprayer.interval; running: sprayAnimation.running; repeat: true
        onTriggered: {
            if (Tool.getDistance(Qt.point(sprayer.x,sprayer.y),Qt.point(sprayer.target.x,sprayer.target.y)) < sprayer.target.width/2) {//已碰撞
                sprayer.hit()
            }
        }
    }

}
