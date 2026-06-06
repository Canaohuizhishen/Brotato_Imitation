import QtQuick 2.15
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Rectangle {
    id: lockCard
    property double scaleFactor: 1.0
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4

    Image {
        source: "qrc:/images/lock3.png"
        width: 45*lockCard.scaleFactor
        height: width*1.3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 65*lockCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("敬请期待", SettingsData.language)
        color: "white"
        basePixelSize: 18
        uiScale: lockCard.scaleFactor
        anchors.centerIn: parent
    }
}
