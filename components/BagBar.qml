import QtQuick 2.15

Item {
    id: bagBar
    width: 180*bagBar.scaleFactor
    height: 25*bagBar.scaleFactor
    property double scaleFactor: 1.0
    property double number: 0
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 105*bagBar.scaleFactor
    anchors.leftMargin: 40*bagBar.scaleFactor
    z: 10

    Image {
        id: image
        source: "/images/袋子图标.png"
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
        font.pixelSize: bagBar.scaleFactor*25
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
