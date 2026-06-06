import QtQuick 2.15
import "../logic/utils/tool.js" as Tool

Bullet {
    id: bullet
    width: 50
    height: width*0.28
    property var originPoint: Qt.point(0,0)
    property int fireRange: 400
    property double fireRate: 2500
    property double shootAngle: 0
    rotation: -shootAngle

    Component.onCompleted: {
        shoot.start()
    }

    onPausedChanged: {
        if(paused==true){
            shoot.pause()
        }else{
            shoot.resume()
        }
    }

    onScaleFactorChanged: {
        shoot.stop()
        width=width*scaleFactor/lastScaleFactor
        height=height*scaleFactor/lastScaleFactor
        originPoint=Qt.point(originPoint.x*scaleFactor/lastScaleFactor,originPoint.y*scaleFactor/lastScaleFactor)
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
        shoot.start()
    }

    ParallelAnimation {
        id: shoot
        running: false
        NumberAnimation { id: xAnimation; target: bullet; property: "x"; to: bullet.originPoint.x+Math.cos(bullet.shootAngle* (Math.PI/180))*bullet.fireRange*bullet.scaleFactor; loops: 1; duration: bullet.fireRange/(bullet.fireRate/1000); easing.type: Easing.Linear }
        NumberAnimation { id: yAnimation; target: bullet; property: "y"; to: bullet.originPoint.y-Math.sin(bullet.shootAngle* (Math.PI/180))*bullet.fireRange*bullet.scaleFactor;  loops: 1; duration: bullet.fireRange/(bullet.fireRate/1000); easing.type: Easing.Linear }
        onStopped: {
            //console.log(bullet.x,xAnimation.to)
            if(Tool.approximatelyEqual(bullet.x,xAnimation.to,bullet.fireRange*bullet.scaleFactor/10))bullet.destroy()
        }
        function pause(){
            if(running)paused=true
        }
        function resume(){
            paused=false
        }
    }
}
