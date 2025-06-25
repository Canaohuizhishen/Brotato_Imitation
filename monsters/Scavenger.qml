import QtQuick 2.15
import "../components"
import "../tool.js" as Tool

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
            setGoalRandomlyTimer.pause()
            sprayAnimation.pause()
            shootAnimation.pause()
        }else{
            setGoalRandomlyTimer.resume()
            sprayAnimation.resume()
            shootAnimation.resume()
        }
    }

    TimerCanPause {
        id: setGoalRandomlyTimer
        interval: 3000
        running: scavenger.active && !scavenger.paused
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var margin = 50
            do{
            var x=Math.random() * (scavenger.owner.width - margin*2)+margin;
            var y=Math.random() * (scavenger.owner.height - margin*2)+margin;
            }while(Tool.getDistance(Qt.point(scavenger.x,scavenger.y),Qt.point(x,y))<scavenger.v*interval/1000)
            var point={
                x: x,
                y: y,
                width: 0,
                height: 0
            }
            scavenger.target=point
            spray()
        }
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

    function spray(){
        var dx=scavenger.x-scavenger.target.x
        var dy=scavenger.y-scavenger.target.y
        var distance = Math.sqrt(dx * dx + dy * dy);
        var x=scavenger.x-dx/distance*sprayRange
        var y=scavenger.y-dy/distance*sprayRange
        sprayAnimation.targetPoint=Qt.point(Math.min(Math.max(x,0),scavenger.parent.width-scavenger.width),Math.min(Math.max(y,0),scavenger.parent.height-scavenger.height))
        sprayAnimation.start()
        makeRedMask(scavenger)
    }

    function fire() {
        var dx = (scavenger.x + scavenger.width / 2) - scavenger.target.x
        var dy = (scavenger.y + scavenger.height / 2) - scavenger.target.y
        var angle = Math.atan2(dy, dx) * 180 / Math.PI;
        var x = scavenger.x + scavenger.width*2/3 - Math.cos(angle * (Math.PI / 180)) * scavenger.width *3/5
        var y = scavenger.y + scavenger.height*2/3 - Math.sin(angle * (Math.PI / 180)) * scavenger.height *3/5
        scavenger.parent.spawnBullet(x,y,scavenger.width / 2,scavenger.width / 2,scavenger.monsterData.damage,scavenger.sprayRange,180-angle,Qt.rgba(1, 0, 0, 1))
    }

    function makeRedMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: redOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/scavenger_redMask_faceRight.png" : "/images/scavenger_redMask_faceLeft.png"
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
