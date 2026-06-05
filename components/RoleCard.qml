import QtQuick 2.15
import "../data"
import singleton.SettingsData
import "../data/i18n.js" as I18n

Rectangle {
    id: roleCard
    property string roleName
    property var core: roleName == "" ? roleCore.getRole("wellRounded") : roleCore.getRole(roleName)
    property double scaleFactor: 1.0
    visible: roleName != ""
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4*scaleFactor

    Rectangle {
        id: roleIcon
        width: 68*roleCard.scaleFactor
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 12*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*roleCard.scaleFactor
        color: "#444444"
        radius: 4*roleCard.scaleFactor

        Image {
            width: parent.width
            height: width
            source: roleCard.roleName == "" ? "" : "/images/icon_"+core.objectName+".png"
            anchors.centerIn: parent
        }
    }

    ScaledText {
        text: roleCard.roleName == "" ? "" : core.roleName
        color: "white"
        basePixelSize: 18
        uiScale: roleCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: roleIcon.width+20*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*roleCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("角色", SettingsData.language)
        color: "#ffffc0"
        basePixelSize: 15
        uiScale: roleCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: roleIcon.width+20*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 32*roleCard.scaleFactor
    }

    RoleCustomizationCore{
        id: roleCore
    }

    TextEdit {
        text: roleCard.roleName=="" ? "" : core.talentText
        font.pixelSize: 14*roleCard.scaleFactor
        readOnly: true
        textFormat: TextEdit.RichText
        width: 200*roleCard.scaleFactor
        height: 100*roleCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 12*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: roleIcon.height+24*roleCard.scaleFactor
    }
}
