import QtQuick 2.15
import "../tool.js" as Tool

Canvas {
    id: bullet
    width: 50
    height: width*0.28
    objectName: "子弹"
    z: 5
    property var sourceWeaponName
    property bool paused: false
    property var originPoint: Qt.point(0,0)
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property color color: Qt.rgba(1, 1, 0.45, 1)
    property int damage: 0
    property int range: 400
    property double speed: 2500
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
        height=height*scaleFactor/lastScaleFactor
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
        gradient.addColorStop(0.64, Qt.rgba(bullet.color.r, bullet.color.g, bullet.color.b, 1))
        gradient.addColorStop(1, Qt.rgba(bullet.color.r, bullet.color.g, bullet.color.b, 0))
        ctx.fillStyle = gradient
        ctx.beginPath()
        ctx.ellipse(0, 0, width, height) // 绘制椭圆
        ctx.fill()
    }
    Component.onCompleted: {
        shoot.start()
    }
    Canvas {
        width: bullet.width/1.2
        height: bullet.height/1.1
        anchors.centerIn: bullet
        z: 4
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = Qt.rgba(bullet.color.r, bullet.color.g, bullet.color.b, 1)
            ctx.beginPath()
            ctx.ellipse(0, 0, width, height) // 绘制椭圆
            ctx.fill()
        }
    }
    Canvas {
        width: bullet.width/1.5
        height: bullet.height/1.3
        anchors.centerIn: bullet
        z: 5
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "white"
            ctx.beginPath()
            ctx.ellipse(0, 0, width, height) // 绘制椭圆
            ctx.fill()
        }
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
