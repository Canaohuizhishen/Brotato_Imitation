import QtQuick 2.15
import "../tool.js" as Tool

RoundBullet {
    id: bullet
    width: 25
    height: width
    objectName: "子弹"
    z: 5
    property var originPoint: Qt.point(0,0)
    property int range: 300
    property double speed: 400
    property double shootAngle: 0
    rotation: -shootAngle

    onPausedChanged: {
        if(paused==true){
            shoot.pause()
        }else{
            shoot.resume()
        }
    }

    onScaleFactorChanged: {
        shoot.stop()
        originPoint=Qt.point(originPoint.x*scaleFactor/lastScaleFactor,originPoint.y*scaleFactor/lastScaleFactor)
        shoot.start()
    }

    Component.onCompleted: {
        shoot.start()
    }

    ParallelAnimation {
        id: shoot
        running: false
        NumberAnimation { id: xAnimation; target: bullet; property: "x"; to: bullet.originPoint.x+Math.cos(bullet.shootAngle* (Math.PI/180))*bullet.range*bullet.scaleFactor; loops: 1; duration: bullet.range/(bullet.speed/1000); easing.type: Easing.Linear }
        NumberAnimation { id: yAnimation; target: bullet; property: "y"; to: bullet.originPoint.y-Math.sin(bullet.shootAngle* (Math.PI/180))*bullet.range*bullet.scaleFactor;  loops: 1; duration: bullet.range/(bullet.speed/1000); easing.type: Easing.Linear }
        onStopped: {
            //console.log(bullet.x,xAnimation.to)
            if(Tool.approximatelyEqual(bullet.x,xAnimation.to,bullet.range*bullet.scaleFactor/10))bullet.destroy()
        }
        function pause(){
            if(running)paused=true
        }
        function resume(){
            paused=false
        }
    }
}

