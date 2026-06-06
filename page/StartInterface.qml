import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../components"
import "../logic/utils/i18n.js" as I18n

Item{
    id: startInterface
    property double scaleFactor: 1.0
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100

    property Button resumeButton: resume
    property Button startButton: start
    property Button settingButton: setting
    property Button exitButton: exit

    // --- 动态按钮宽度：测量所有按钮文本，取最长者+内边距 ---
    // x（双边留白）= 原固定按钮宽度(screenWidth/15) - 原中文文本宽度
    readonly property real buttonFontPixelSize: 23 * SettingsData.fontScale * scaleFactor

    Image {
        id: startImage
        source: "qrc:/images/startInterface3.png"
        width: parent.width
        height: parent.height
    }

    Button{
        id: resume
        text: I18n.tr("继续", SettingsData.language)
        height: startInterface.height/15
        visible: false
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*13/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: resume.pressed || resume.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: ScaledText {
            text: resume.text
            basePixelSize: 23
            uiScale: startInterface.scaleFactor
            color: resume.pressed || resume.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
        onClicked: {
            sound.playClickSound()
        }
    }

    Button{
        id: start
        text: I18n.tr("开始", SettingsData.language)
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*10/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: start.pressed || start.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: ScaledText {
            text: start.text
            basePixelSize: 23
            uiScale: startInterface.scaleFactor
            color: start.pressed || start.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
        onClicked: {
            sound.playClickSound()
        }
    }

    Button{
        id: setting
        text: I18n.tr("设置", SettingsData.language)
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*7/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: setting.pressed || setting.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: ScaledText {
            text: setting.text
            basePixelSize: 23
            uiScale: startInterface.scaleFactor
            color: setting.pressed || setting.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
        onClicked: {
            sound.playClickSound()
        }
    }

    Button{
        id: exit
        text: I18n.tr("退出", SettingsData.language)
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*4/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: exit.pressed || exit.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: ScaledText {
            text: exit.text
            basePixelSize: 23
            uiScale: startInterface.scaleFactor
            color: exit.pressed || exit.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
        onClicked: {
            sound.playClickSound()
        }
    }

    // --- 统一测量并设置按钮宽度 ---
    TextMetrics {
        id: buttonWidthMeter
        font.pixelSize: buttonFontPixelSize
    }

    // 默认字号（无 fontScale）下中文文本宽度，用于计算固定 padding
    TextMetrics {
        id: defaultChineseWidthMeter
        font.pixelSize: 23 * scaleFactor
    }

    function updateButtonWidths() {
        var texts = [resume.text, start.text, setting.text, exit.text]
        var maxW = 0
        for (var i = 0; i < texts.length; i++) {
            buttonWidthMeter.text = texts[i]
            if (buttonWidthMeter.width > maxW)
                maxW = buttonWidthMeter.width
        }
        // 原来的固定按钮宽度 = 屏幕宽度/15
        // 原来的中文文本宽度 = "继续"在默认字号(无 fontScale)下的宽度
        defaultChineseWidthMeter.text = "继续"
        var x = (startInterface.width / 15) - defaultChineseWidthMeter.width
        var w = maxW + x
        resume.width = w
        start.width = w
        setting.width = w
        exit.width = w
    }

    // 语言切换 / 字体缩放时重新计算按钮宽度
    Connections {
        target: SettingsData
        function onFontScaleChanged() { updateButtonWidths() }
        function onLanguageChanged() { updateButtonWidths() }
    }

    // 用 Connections 替代声明式绑定，避免单例属性重求值失效
    Component.onCompleted: {
        resume.visible = PlayerData.currentWaveNumber > 1
        updateButtonWidths()
    }

    Connections {
        target: PlayerData
        function onCurrentWaveNumberChanged() {
            resume.visible = PlayerData.currentWaveNumber > 1
        }
    }

    onScaleFactorChanged: updateButtonWidths()

    function init(){
        visible=false
    }
}
