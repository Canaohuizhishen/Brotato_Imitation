import QtQuick 2.15

Item {
    id: materialBar
    width: 180*materialBar.scaleFactor
    height: 25*materialBar.scaleFactor
    property double scaleFactor: 1.0
    property double number: 0
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 75*materialBar.scaleFactor
    anchors.leftMargin: 40*materialBar.scaleFactor
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
        font.pixelSize: materialBar.scaleFactor*25
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
