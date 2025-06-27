import QtQuick
import QtQuick.Shapes
import singleton.PlayerData
import QtQuick.Controls

Item {
    id: root
    //property real healthPercentage: 1.0 //测试用的生命百分比
    property real minHoleScale: 0.9   //最小孔洞
    property real minHoleThreshold: 0.5
    property real healthPercentage: PlayerData.curHp / PlayerData.maxHp
    property real holeScale: {
        if (healthPercentage >= minHoleThreshold) return 1.0;
        return minHoleScale + (1 - minHoleScale) * (healthPercentage / minHoleThreshold);
    }

    property real calculatedOpacity: {
        const maxOpacity = 0.9;       // 最大不透明度（当health=0时）
        const threshold = minHoleThreshold;
        if (healthPercentage >= threshold) return 0.0;
        return maxOpacity * (1 - healthPercentage / threshold);
    }
    property real contentAreaOpacity: {
        const maxOpacity = 0.4;       // 最大不透明度（health=0时）
        const minOpacity = 0.1;       // 最小不透明度（health=minHoleThreshold时）
        if (healthPercentage >= minHoleThreshold) return 0.0; // 高于阈值时完全透明
        return maxOpacity - (maxOpacity - minOpacity) * (healthPercentage / minHoleThreshold);
    }
    Connections {
           target: PlayerData
           function onHpChanged() {
               // 强制更新属性绑定
               healthPercentage = PlayerData.curHp / PlayerData.maxHp
               // 请求重绘
               maskCanvas.requestPaint()
           }
       }
    Rectangle {
        id: contentArea
        anchors.centerIn: parent
        width: 1280
        height: 720
        color: Qt.rgba(0, 0, 0, root.contentAreaOpacity)

    }

    // 椭圆遮罩层
    Canvas {
        id: maskCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // 绘制半透明黑色遮罩
            ctx.fillStyle = Qt.rgba(0, 0, 0,root.calculatedOpacity)
            ctx.fillRect(0, 0, width, height)
            var scaledWidth = contentArea.width * root.holeScale
            var scaledHeight = contentArea.height * root.holeScale
            var centerX = (width - scaledWidth) / 2
            var centerY = (height - scaledHeight) / 2

            // 清除椭圆区域（创建孔洞）
            ctx.globalCompositeOperation = "destination-out"
            ctx.beginPath()
            ctx.ellipse(centerX, centerY, scaledWidth, scaledHeight)
            ctx.fill()
        }

    }

    //测试用的
    // Rectangle {
    //     anchors.fill: debugText
    //     anchors.margins: -10
    //     color: "#80000000"
    //     radius: 5
    // }

    // Text {
    //     id: debugText
    //     anchors.top: parent.top
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     color: "white"
    //     font.pixelSize: 20
    //     text: `生命值: ${(healthPercentage * 100).toFixed(1)}% |
    //     不透明度: ${calculatedOpacity.toFixed(2)} |
    //     孔洞缩放: ${holeScale.toFixed(2)}`
    // }

    //     // 手动控制滑块
    //     Slider {
    //         id: healthSlider
    //         anchors {
    //             bottom: parent.bottom
    //             horizontalCenter: parent.horizontalCenter
    //             margins: 20
    //         }
    //         width: parent.width * 0.8
    //         from: 0
    //         to: 1
    //         value: root.healthPercentage

    //         onValueChanged: {
    //             root.healthPercentage = value
    //             maskCanvas.requestPaint()
    //         }
    //     }

}
