import QtQuick 2.15

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

    Text{
        text: "纪录"
        color: "white"
        font.pixelSize: 19*recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 105*recardCard.scaleFactor
    }

    Text{
        text: "通关最高难度"
        color: "#dad2a4"
        font.pixelSize: 15*recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 140*recardCard.scaleFactor
    }

    Text{
        text: "尚无记录"
        color: "white"
        font.pixelSize: 15*recardCard.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 160*recardCard.scaleFactor
    }
}
