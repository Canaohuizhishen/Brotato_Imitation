import QtQuick 2.15

/**
 * FloatingText — 通用浮动文本组件（对象池友好版）
 *
 * 供 tool.js 文本池循环复用：showText() 配置后播放渐隐动画，动画结束后
 * 自动隐藏（visible=false），不销毁对象。承载内容不止伤害数字——回血、
 * 闪避、拾取提示、波次结算大字等都复用本组件。
 *
 * 用法（由 tool.js 的 createText 内部调用）：
 *   text.showText("999", 27, "yellow", 100, 200, 600, "black")
 */
Text {
    id: root

    font.bold: true
    style: Text.Outline
    styleColor: outlineColor
    z: 10000

    // 可配置属性
    property string outlineColor: "black"
    property int textDuration: 600

    function showText(text, size, color, x, y, duration, outline) {
        root.text = text
        root.font.pixelSize = Math.floor(size)
        root.color = color
        root.x = x
        root.y = y
        root.textDuration = duration || 600
        root.styleColor = outline || "black"
        root.opacity = 0
        root.visible = true
        fadeAnim.restart()
    }

    SequentialAnimation {
        id: fadeAnim
        loops: 1
        running: false

        OpacityAnimator {
            target: root
            from: 0
            to: 0.8
            duration: root.textDuration / 2
        }
        OpacityAnimator {
            target: root
            from: 0.8
            to: 0
            duration: root.textDuration / 2
        }
        onStopped: {
            root.visible = false
        }
    }
}
