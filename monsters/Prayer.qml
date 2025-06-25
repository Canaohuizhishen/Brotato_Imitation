import QtQuick 2.15
import "../components"
import "../tool.js" as Tool

Monster{
    id: prayer
    monsterName: "prayer"
    imageWidth: 150
    imageHeight: imageWidth*1.05
    property int baseSpawnBulletWidth: 300
    property int spawnR: 200 //子弹生成区域的初始半径
    property int maxSpawnR: 400 //子弹生成区域的最大半径
    property int existTime: 0

    onIsDeadChanged: {
        if(windUpAnimation.running)windUpAnimation.pause()
    }

    onPausedChanged: {
        if(paused==true){
            timer.pause()
            attackTimer.pause()
            windUpAnimation.pause()
            attackAnimation.pause()
        }else{
            timer.resume()
            attackTimer.resume()
            windUpAnimation.resume()
            attackAnimation.resume()
        }
    }

    TimerCanPause {
        id: timer
        interval: 1000
        running: prayer.active
        repeat: true
        onTriggered: {
            existTime++
            if(existTime>30 && spawnR<maxSpawnR){
                spawnR+=20
            }
        }
    }

    TimerCanPause {
        id: attackTimer
        interval: 3000
        running: prayer.active && !prayer.paused
        repeat: true
        onTriggered: {
            windUp()
        }
    }

    transform: Scale {
        id: squashScale
        origin.x: prayer.width/2
        origin.y: prayer.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: windUpAnimation
        loops: 1
        running: false

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; from: 1; to: 0.7; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; from: 1; to: 1.3; duration: 500; easing.type: Easing.InOutQuad }
        }

        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.2; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.8; duration: 100; easing.type: Easing.OutQuad }
        }
        onStopped: {
            attackAnimation.start()
            running=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    ParallelAnimation {
        id: attackAnimation
        loops: 1
        running: false
        NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
        NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: 100; easing.type: Easing.OutQuad }
        onStarted: {
            if(prayer.existTime<60)prayer.fireRandomly()
            else prayer.fireCircularly()
        }
        onStopped: {
            running=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    function windUp(){
        windUpAnimation.start()
        makeRedMask(prayer)
    }

    function fireRandomly() {
        var n=spawnR*spawnR/3000
        var bulletX=target.x+target.width/2
        var bulletY=target.y+target.height/2
        var bulletWidth=prayer.width / 5
        var bulletHeight=bulletWidth
        var bulletDamage=prayer.monsterData.damage
        var bulletColor=Qt.rgba(1, 0, 0, 1)
        var bulletExistTime=700
        prayer.parent.spawnRandomStaticBullets(n,bulletX,bulletY,bulletWidth,bulletHeight,bulletDamage,bulletColor,bulletExistTime,spawnR)
    }

    function fireCircularly() {
        var spawnR=250
        var n=spawnR*spawnR/2000
        var bulletX=target.x+target.width/2
        var bulletY=target.y+target.height/2
        var bulletWidth=prayer.width / 5
        var bulletHeight=bulletWidth
        var bulletDamage=prayer.monsterData.damage
        var bulletColor=Qt.rgba(1, 0, 0, 1)
        var bulletExistTime=700
        prayer.parent.spawnCircularStaticBullets(n,bulletX,bulletY,bulletWidth,bulletHeight,bulletDamage,bulletColor,bulletExistTime,spawnR)
    }

    function makeRedMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: redOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/prayer_redMask_faceRight.png" : "/images/prayer_redMask_faceLeft.png"
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
