import QtQuick 2.15
import "../tool.js" as Tool

Canvas {
    id: bullet
    width: 25
    height: width
    objectName: "子弹"
    z: 5
    property bool paused: false
    property var originPoint: Qt.point(0,0)
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property color color: Qt.rgba(1, 0, 0, 1)
    property int damage: 0
    property int range: 300
    property double speed: 400
    property double shootAngle: 0
    rotation: -shootAngle
    property bool isDestroy: false

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
        height=width
        originPoint=Qt.point(originPoint.x*scaleFactor/lastScaleFactor,originPoint.y*scaleFactor/lastScaleFactor)
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
        shoot.start()
    }

    onPaint: {
        var ctx = getContext("2d")
        var gradient = ctx.createRadialGradient(
                    width / 2, height / 2, 0,
                    width / 2, height / 2, Math.max(width / 2, height / 2)
                    )
        gradient.addColorStop(0, Qt.rgba(1, 1, 1, 1))
        gradient.addColorStop(0.38, Qt.rgba(1, 1, 1, 1))
        gradient.addColorStop(0.5, Qt.rgba(bullet.color.r, bullet.color.g+0.2, bullet.color.b+0.2, 1))
        gradient.addColorStop(0.75, Qt.rgba(bullet.color.r, bullet.color.g, bullet.color.b, 1))
        gradient.addColorStop(1, Qt.rgba(bullet.color.r, bullet.color.g, bullet.color.b, 0))
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

