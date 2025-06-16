import QtQuick 2.15
import "../data"

Rectangle {
    id: roleCard
    property string roleName
    property double scaleFactor: 1.0
    visible: roleName != ""
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4

    Rectangle {
        id: roleIcon
        width: 68
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 12*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*roleCard.scaleFactor
        color: "#444444"
        radius: 4

        Image {
            width: parent.width*(roleCard.roleName=="" ? 0 : core.getRole(roleCard.roleName).scalingFactor*roleCard.scaleFactor)
            height: width*(roleCard.roleName=="" ? 0 : core.getRole(roleCard.roleName).aspectRatio)
            source: roleCard.roleName == "" ? "" : "/images/"+roleCard.roleName+"_avatar3.png"
            anchors.centerIn: parent
        }
    }

    Text{
        text: roleCard.roleName == "" ? "" : core.getRole(roleCard.roleName).roleName
        color: "white"
        font.pixelSize: 18*roleCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: roleIcon.width+20*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*roleCard.scaleFactor
    }

    Text{
        text: "角色"
        color: "#dad2a4"
        font.pixelSize: 15*roleCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: roleIcon.width+20*roleCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 32*roleCard.scaleFactor
    }

    RoleCustomizationCore{
        id: core
    }

    TextEdit {
        text: roleCard.roleName=="" ? "" : core.getRole(roleCard.roleName).talentText
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
