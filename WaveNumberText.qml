import QtQuick 2.15

Item {
    id: waveNumberText
    property int text: 0
    property int size: 24
    width: parent.width
    height: 15
    z:10

    anchors.top: parent.top
    anchors.topMargin: 15

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
