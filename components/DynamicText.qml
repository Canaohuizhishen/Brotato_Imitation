import QtQuick 2.15
import "../tool.js" as Tool

/**
 * DynamicText — 安全的动态文本显示组件
 *
 * 替代 Tool.createText() 的 QML 字符串插值方式，
 * 通过属性传值避免注入风险。
 *
 * 用法：
 *   var component = Qt.createComponent("DynamicText.qml")
 *   var txt = component.createObject(parent, {
 *       text: "Hello",
 *       color: "white",
 *       size: 24,
 *       x: 100,
 *       y: 50,
 *       duration: 1500,
 *       outlineColor: "black"
 *   })
 */
Text {
    id: root

    property int duration: 600
    property string outlineColor: "black"

    font.bold: true
    style: Text.Outline
    styleColor: root.outlineColor
    z: 100

    Component.onCompleted: {
        fadeAnim.start()
    }

    SequentialAnimation {
        id: fadeAnim
        loops: 1
        running: false

        OpacityAnimator {
            target: root
            from: 0
            to: 0.8
            duration: root.duration / 2
        }
        OpacityAnimator {
            target: root
            from: 0.8
            to: 0
            duration: root.duration / 2
        }
        onStopped: {
            root.destroy()
        }
    }
}
