import QtQuick 2.15
import "../tool.js" as Tool

MovingBullet {
    id: bullet
    width: 25
    height: width

    onPaint: {
        if(canPaintBullet)paintBullet()
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

