import QtQuick 2.15
import "../tool.js" as Tool

MovingBullet {
    id: bullet
    width: 50
    height: width*0.28

    onPaint: {
        if(canPaintBullet)paintBullet()
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

    function paintBullet(){
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
}
