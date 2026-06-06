import QtQuick 2.15
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Rectangle {
    id: recardCard
    property string roleName
    property double scaleFactor: 1.0
    visible: roleName != ""
    anchors.left: parent.horizontalCenter
    anchors.leftMargin: 3
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4

    Image {
        source: "qrc:/images/recording.png"
        width: 50*recardCard.scaleFactor
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30*recardCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("纪录", SettingsData.language)
        color: "white"
        basePixelSize: 19
        uiScale: recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 105*recardCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("通关最高难度", SettingsData.language)
        color: "#ffffc0"
        basePixelSize: 15
        uiScale: recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 140*recardCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("尚无记录", SettingsData.language)
        color: "white"
        basePixelSize: 15
        uiScale: recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 160*recardCard.scaleFactor
    }
}
