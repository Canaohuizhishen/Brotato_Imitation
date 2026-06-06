import QtQuick 2.15
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Rectangle {
    id: difficultyCard
    property string difficulty
    property double scaleFactor: 1.0
    visible: difficulty != ""
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4*difficultyCard.scaleFactor

    Rectangle {
        id: difficultyIcon
        width: 68*difficultyCard.scaleFactor
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 12*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*difficultyCard.scaleFactor
        color: "#444444"
        radius: 4

        Image {
            width: parent.width
            height: width
            source: difficultyCard.difficulty == "" ? "" : "/images/icon_"+difficultyCard.difficulty+".png"
            anchors.centerIn: parent
        }
    }

    ScaledText {
        text: I18n.tr("危险", SettingsData.language)+difficultyCard.difficulty
        color: "white"
        basePixelSize: 18
        uiScale: difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: difficultyIcon.width+20*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*difficultyCard.scaleFactor
    }

    ScaledText {
        text: I18n.tr("难度", SettingsData.language)
        color: "#ffffc0"
        basePixelSize: 15
        uiScale: difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: difficultyIcon.width+20*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 32*difficultyCard.scaleFactor
    }

    TextEdit {
        text: difficultyCard.difficulty=="" ? "" : core.getDifficultyDescription(difficultyCard.difficulty)
        font.pixelSize: 14*difficultyCard.scaleFactor
        readOnly: true
        textFormat: TextEdit.RichText
        width: 200*difficultyCard.scaleFactor
        height: 100*difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 12*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: difficultyIcon.height+24*difficultyCard.scaleFactor
    }

    Item{
        id: core
        function getDifficultyDescription(n){
            switch(n-'0'){
            case 0: return "<font color='white'>" + I18n.tr("无修改", SettingsData.language) + "</font>"
            default: return ""
            }
        }
    }
}
