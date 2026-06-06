import QtQuick 2.15
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Item {
    id: waveNumberText
    property double scaleFactor: 1.0
    property int text: 0
    width: parent.width
    height: 28*waveNumberText.scaleFactor
    z:10
    anchors.top: parent.top
    anchors.topMargin: 15*waveNumberText.scaleFactor

    Text {
        id: text
        text: I18n.tr("第", SettingsData.language)+waveNumberText.text+I18n.tr("波", SettingsData.language)
        color: "white"
        font.pixelSize: waveNumberText.height
        style: Text.Outline
        styleColor: "black"
        anchors.centerIn: parent
    }
}
