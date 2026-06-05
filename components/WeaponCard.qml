import QtQuick 2.15
import "../data"
import singleton.PlayerData
import singleton.SettingsData
import "../data/i18n.js" as I18n

Rectangle {
    id: weaponCard
    property string weaponName
    property var core: weaponName == "" ? weaponCore.getWeapon("smg") : weaponCore.getWeapon(weaponName)
    property double scaleFactor: 1.0
    visible: weaponName != ""
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4*scaleFactor

    Rectangle {
        id: weaponIcon
        width: 68*weaponCard.scaleFactor
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 12*weaponCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*weaponCard.scaleFactor
        color: "#323232"
        radius: 4*weaponCard.scaleFactor

        Image {
            width: parent.width
            height: width
            source: weaponCard.weaponName == "" ? "" : "qrc:/images/icon_"+weaponCard.weaponName+".png"
            anchors.centerIn: parent
        }
    }

    ScaledText {
        text: weaponCard.weaponName == "" ? "" : I18n.tr(core.weaponName, SettingsData.language)
        color: "white"
        basePixelSize: 18
        uiScale: weaponCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: weaponIcon.width+20*weaponCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*weaponCard.scaleFactor
    }

    ScaledText {
        text: weaponCard.weaponName=="" ? "" : I18n.tr(core.type, SettingsData.language)
        color: "#ffffc0"
        basePixelSize: 15
        uiScale: weaponCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: weaponIcon.width+20*weaponCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 32*weaponCard.scaleFactor
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    TextEdit {
        text: weaponCard.weaponName=="" ? "" : weaponCore.renderWeaponTalentText(core)
        font.pixelSize: 14*weaponCard.scaleFactor
        readOnly: true
        textFormat: TextEdit.RichText
        width: 200*weaponCard.scaleFactor
        height: 100*weaponCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 12*weaponCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: weaponIcon.height+24*weaponCard.scaleFactor
    }
}
