import QtQuick
import QtQuick.Controls
import "../components"
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

// 死亡后"重新挑战失败的敌袭"确认框（设置项 retryFailedWave 开启时启用）。
// 全屏透明：仅居中文本 + 是/否按钮，冻结的战场画面直接透出；
// 文本/按钮结构复用 PauseInterface 的 backMenu（是否返回主菜单?）。
Item {
    id: root
    anchors.fill: parent
    property double scaleFactor: 1.0
    focus: true
    property alias yesButton: yesButton
    property alias noButton: noButton

    // 输入隔离：全屏吸收层（防点击穿透到战场；仿 PauseInterface 根部 TapHandler）
    TapHandler{
        onTapped: {}
    }

    Column {
        width: 380*root.scaleFactor
        anchors.centerIn: parent
        spacing: 15*root.scaleFactor

        ScaledText {
            text: I18n.tr("重新挑战当前的敌袭吗?", SettingsData.language)
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            basePixelSize: 30
            uiScale: root.scaleFactor
        }

        SetButton {
            id: yesButton
            text: I18n.tr("是", SettingsData.language)
            width: parent.width
            height: width/8
        }

        SetButton {
            id: noButton
            text: I18n.tr("否", SettingsData.language)
            width: parent.width
            height: width/8
        }
    }
}
