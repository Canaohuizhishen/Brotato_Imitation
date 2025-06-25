import QtQuick 2.15
import "../tool.js" as Tool

Canvas {
    id: bullet
    width: 25
    height: width
    objectName: "子弹"
    z: 5
    property bool paused: false
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property color color: Qt.rgba(1, 0, 0, 1)
    property int damage: 0
    property bool isDestroy: false
    property bool canPaintBullet: true //可以画出子弹的布尔值
    property bool hitNotDestroy: false //击中目标后不会销毁的布尔值
    property bool inHitCoolDown: false

    onScaleFactorChanged: {
        width=width*scaleFactor/lastScaleFactor
        height=width
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
    }

    onPausedChanged: {
        if(paused==true){
            hitCoolDownTimer.pause()
        }else{
            hitCoolDownTimer.resume()
        }
    }

    onPaint: {
        if(canPaintBullet)paintBullet()
    }

    TimerCanPause {
        id: hitCoolDownTimer
        interval: 250
        running: bullet.inHitCoolDown && bullet.canPaintBullet
        repeat: false
        onTriggered: {
            inHitCoolDown=false
        }
    }

    function paintBullet(){
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
}

