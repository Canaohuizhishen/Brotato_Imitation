import QtQuick
import QtQuick.Shapes
import singleton.PlayerData
import QtQuick.Controls

Item {
    id: root
    property real healthPercentage: 0
    Connections {
        target: PlayerData
        function onCurHpChanged() {
            if(PlayerData.curHp===0){
                healthPercentage = 0.001
                dieMaskAnimator.start()
            }else{
                dieMask.opacity=0
                if(PlayerData.curHp / PlayerData.maxHp<0.6)healthPercentage = PlayerData.curHp / PlayerData.maxHp
                else healthPercentage = 0
            }
            maskCanvas.requestPaint()
        }
    }

    Rectangle{
        id: dieMask
        anchors.fill: parent
        color: "black"
        opacity: 0
        OpacityAnimator {
            id: dieMaskAnimator
            target: dieMask
            from: 0
            to: 0.5
            duration: 1000
            running: false
        }
    }

    // 椭圆遮罩层
    Canvas {
        id: maskCanvas
        anchors.fill: parent
        visible: healthPercentage
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.save()
            ctx.translate(width/2, height / 2)
            ctx.scale(1, height/width)

            var gradient = ctx.createRadialGradient(
                        0, 0, 0,
                        0, 0, Math.max(width/1.5+width*0.0055*healthPercentage*100, width/1.5)
                        )
            gradient.addColorStop(0, Qt.rgba(0, 0, 0, 0.02))
            gradient.addColorStop(0.5, Qt.rgba(0, 0, 0, 0.03))
            gradient.addColorStop(0.55, Qt.rgba(0, 0, 0, 0.04))
            gradient.addColorStop(0.6, Qt.rgba(0, 0, 0, 0.1))
            gradient.addColorStop(0.65, Qt.rgba(0, 0, 0, 0.19))
            gradient.addColorStop(0.7, Qt.rgba(0, 0, 0, 0.29))
            gradient.addColorStop(0.75, Qt.rgba(0, 0, 0, 0.39))
            gradient.addColorStop(0.8, Qt.rgba(0, 0, 0, 0.48))
            gradient.addColorStop(0.85, Qt.rgba(0, 0, 0, 0.56))
            gradient.addColorStop(0.9, Qt.rgba(0, 0, 0, 0.65))
            gradient.addColorStop(0.95, Qt.rgba(0, 0, 0, 0.73))
            gradient.addColorStop(1, Qt.rgba(0, 0, 0, 0.8))

            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.fillRect(-width/2, -height, width, height*2)
            ctx.fill()

            ctx.restore()
        }
    }
}
