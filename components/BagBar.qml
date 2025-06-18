import QtQuick 2.15

Item {
    id: bagBar
    width: 215*bagBar.scaleFactor
    height: 32*bagBar.scaleFactor
    property double scaleFactor: 1.0
    property double number: 0
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 135*bagBar.scaleFactor
    anchors.leftMargin: 15*bagBar.scaleFactor
    z: 10

    Image {
        id: image
        source: "/images/bag_icon.png"
        width: height
        height: bagBar.height
        anchors.left: bagBar.left
        anchors.leftMargin: 5*bagBar.scaleFactor
        anchors.verticalCenter: bagBar.verticalCenter
    }

    Text {
        id: numberText
        text: bagBar.number
        color: "black"
        font.pixelSize: bagBar.height
        style: Text.Outline
        styleColor: "black"
        anchors.left: parent.left
        anchors.leftMargin: image.width+12*bagBar.scaleFactor
    }

    Text {
        text: numberText.text
        color: "white"
        font.pixelSize: numberText.font.pixelSize
        anchors.centerIn: numberText
    }
}
