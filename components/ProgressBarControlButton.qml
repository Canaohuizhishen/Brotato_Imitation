import QtQuick
import QtQuick.Controls


Item {
    id: root
    property double scaleFactor: 1.0
    width: parent.width
    height: 40*root.scaleFactor

    property string labelText: ""
    /// 音频通道标识：master / sfx / music / ""（非音量滑块留空）
    property string audioChannel: ""
    property int initialValue: 50
    property int currentValue: initialValue  // 可被父级绑定的当前值
    signal valueChanged(int newValue)
    property bool isActive: false  // 新增：当前是否被激活
    property bool linkFontSize: false  // 控制字体大小关联
    property int sliderFrom: 0         // 滑块范围下限
    property int sliderTo: 100         // 滑块范围上限
    property bool _settingFromExternal: false  // 防止循环更新的内部标志

    function mapFontSize(sliderValue) {
        return 25 * (sliderValue / 100)
    }

    // 测量标签在目标字号下的完整宽度（用于超长英文时缩小字号）
    TextMetrics {
        id: labelMetrics
        text: root.labelText
        font.pixelSize: (root.linkFontSize ? mapFontSize(slider.value) : 25) * root.scaleFactor
    }

    // 字号收缩因子：文本超过标签宽度时按比例缩小
    // 减 2px 容差：补偿字体 hinting 导致实际渲染比 TextMetrics 宽出 1-3px
    readonly property real _labelFitScale: Math.min(1.0, ((130 - 2) * root.scaleFactor) / Math.max(1, labelMetrics.width))

    // 文本标签（固定宽 130px，超长自动缩小字号，clip 防溢出）
    ScaledText {
        id: label
        text: root.labelText
        color: "white"
        font.pixelSize: (root.linkFontSize ? mapFontSize(slider.value) : 25) * root.scaleFactor * root._labelFitScale
        anchors {
            left: parent.left
            leftMargin: 10*root.scaleFactor
            verticalCenter: parent.verticalCenter
        }
        width: 130*root.scaleFactor
        horizontalAlignment: Text.AlignLeft
        clip: true
    }

    // 滑块
    Slider {
        id: slider
        anchors {
            left: label.right
            right: percent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 5*root.scaleFactor
            rightMargin: 15*root.scaleFactor
        }
        height: 25*root.scaleFactor
        from: root.sliderFrom
        to: root.sliderTo
        value: root.currentValue
        stepSize: 1
        handle: Item { visible: false }

        Component.onCompleted: {
            if (root.audioChannel === "master") {
                sound.setMasterVolume(value * 0.01)
            } else if (root.audioChannel === "sfx") {
                sound.setSfxVolume(value * 0.01)
            } else if (root.audioChannel === "music") {
                sound.setMusicVolume(value * 0.01)
            }
        }

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                if (root.parent && root.parent.deselectAllSliders) {
                    root.parent.deselectAllSliders()
                }
                root.isActive = true
            }
        }

        background: Rectangle {
            id: trackBg
            anchors.fill: parent
            color: "#252525"

            Rectangle {
                id: progressBar
                width: slider.visualPosition * parent.width
                height: {
                    if (root.isActive) return 30*root.scaleFactor
                    if (hoverHandler.hovered) return 30*root.scaleFactor
                    return 25*root.scaleFactor
                }
                color: (root.isActive || hoverHandler.hovered) ? "white" : "#afafaf"
                radius: 0
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        states: [
            State {
                when: root.isActive
                PropertyChanges { target: slider; height: 30*root.scaleFactor }
            },
            State {
                when: hoverHandler.hovered && !root.isActive
                PropertyChanges { target: slider; height: 30*root.scaleFactor }
            }
        ]
        transitions: Transition {
            NumberAnimation { property: "height"; duration: 150 }
        }

        onValueChanged: {
            root.valueChanged(Math.round(value))
            if (root.audioChannel === "master") {
                sound.setMasterVolume(value * 0.01)
            } else if (root.audioChannel === "sfx") {
                sound.setSfxVolume(value * 0.01)
            } else if (root.audioChannel === "music") {
                sound.setMusicVolume(value * 0.01)
            }
        }
    }

    // 百分比（右对齐）
    ScaledText {
        id: percent
        text: {
            if (root.linkFontSize) {
                return Math.round(slider.value) + "%"
            }
            return Math.round(slider.value) + "%"
        }
        color: "white"
        basePixelSize: 24
        uiScale: root.scaleFactor
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 60*root.scaleFactor
        horizontalAlignment: Text.AlignRight
    }
    // 当外部（如 SettingsData.loadSettings）修改 currentValue 时，同步到 slider
    onCurrentValueChanged: {
        if (!_settingFromExternal && Math.round(slider.value) !== currentValue) {
            _settingFromExternal = true
            slider.value = currentValue
            _settingFromExternal = false
        }
    }

    // 提供给父组件调用的方法
    function deselect() {
        root.isActive = false
    }
}
