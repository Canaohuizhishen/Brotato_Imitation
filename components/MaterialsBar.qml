import QtQuick 2.15

Item {
    id: materialBar
    width: 215*materialBar.scaleFactor
    height: 32*materialBar.scaleFactor
    property double scaleFactor: 1.0
    property double number: 0
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 97*materialBar.scaleFactor
    anchors.leftMargin: 15*materialBar.scaleFactor
    z: 10

    Image {
        id: image
        source: "/images/material_icon.png"
        width: height
        height: materialBar.height
        anchors.left: materialBar.left
        anchors.leftMargin: 5*materialBar.scaleFactor
        anchors.verticalCenter: materialBar.verticalCenter
    }

    Text {
        id: numberText
        text: materialBar.number
        color: "black"
        font.pixelSize: materialBar.height
        style: Text.Outline
        styleColor: "black"
        anchors.left: parent.left
        anchors.leftMargin: image.width+12*materialBar.scaleFactor
    }

    Text {
        text: numberText.text
        color: "white"
        font.pixelSize: numberText.font.pixelSize
        anchors.centerIn: numberText
    }
}
