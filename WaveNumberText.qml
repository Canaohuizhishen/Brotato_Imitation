import QtQuick 2.15

Item {
    id: waveNumberText
    property double scaleFactor: 1.0
    property int text: 0
    property int size: 24*waveNumberText.scaleFactor
    width: parent.width
    height: 15*waveNumberText.scaleFactor
    z:10

    anchors.top: parent.top
    anchors.topMargin: 15*waveNumberText.scaleFactor

    Text {
        id: text
        text: "第"+waveNumberText.text+"波"
        color: "black"
        font.pixelSize: waveNumberText.size
        style: Text.Outline
        styleColor: "black"
        anchors.centerIn: parent
    }

    Text {
        text: text.text
        color: "white"
        font.pixelSize: text.font.pixelSize
        anchors.centerIn: text.anchors.centerIn
    }
}
