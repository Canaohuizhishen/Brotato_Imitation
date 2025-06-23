import QtQuick
import QtQuick.Controls


Item {
    id: root
    width: parent.width
    height: 40

    property string labelText: ""
    property int initialValue: 50
    signal valueChanged(int newValue)
    property bool isActive: false  // 新增：当前是否被激活
    property bool linkFontSize: false  // 控制字体大小关联

    function mapFontSize(sliderValue) {
        return 16 * (sliderValue / 100)
    }

    // 文本标签（左对齐）
    Text {
        id: label
        text: root.labelText
        color: "white"
        font.pixelSize: root.linkFontSize ? mapFontSize(slider.value) : 25
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: 80
        horizontalAlignment: Text.AlignLeft
    }

    // 滑块（居中）
    Slider {
        id: slider
        anchors {
            left: label.right
            right: percent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 50
            rightMargin: 15
        }
        height: 25  // 默认高度
        from: root.linkFontSize ? 80 : 0  // 动态范围
        to: root.linkFontSize ? 125 : 100
        value: root.linkFontSize ? 100 : root.initialValue
        stepSize: root.linkFontSize ? 1 : 3
        handle: Item { visible: false }


        // 悬停检测
        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
        }

        // 点击检测
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                if (root.parent && root.parent.deselectAllSliders) {
                    root.parent.deselectAllSliders()
                }
                root.isActive = true
            }
        }
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                if (root.parent && root.parent.deselectAllSliders) {
                    root.parent.deselectAllSliders()
                }
            }
        }

        // 背景轨道
        background: Rectangle {
            id: trackBg
            anchors.fill: parent
            color: "#252525"                          // 默认状态

            // 进度条
            Rectangle {
                id: progressBar
                width: slider.visualPosition * parent.width
                height: {
                    if (root.isActive) return 30
                    if (hoverHandler.hovered) return 30
                    return 25
                }
                color: (root.isActive || hoverHandler.hovered) ? "white" : "#afafaf"
                radius: 0
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // 悬停/激活时的高度变化
        states: [
            State {
                when: root.isActive
                PropertyChanges { target: slider; height: 30 }
            },
            State {
                when: hoverHandler.hovered && !root.isActive
                PropertyChanges { target: slider; height: 30 }
            }
        ]
        transitions: Transition {
            NumberAnimation { property: "height"; duration: 150 }
        }

        onValueChanged: {
            if (root.linkFontSize) {
                label.font.pixelSize = mapFontSize(value)
            }
            root.valueChanged(Math.round(value))
        }
    }

    // 百分比（右对齐）
    Text {
        id: percent
        text: {
            if (root.linkFontSize) {
                return Math.round(slider.value) + "%" // 显示80%-125%
            }
            return Math.round(slider.value) + "%"
        }
        color: "white"
        font.pixelSize: 24
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 60
        horizontalAlignment: Text.AlignRight
    }
    onLinkFontSizeChanged: {
        if (linkFontSize) {
            slider.value = 100
            label.font.pixelSize = mapFontSize(100)
        } else {
            slider.value = initialValue
            label.font.pixelSize = 25
        }
    }


    // 提供给父组件调用的方法
    function deselect() {
        root.isActive = false
    }
}
