import QtQuick 2.15

Item {
    id: waveCountdown
    property int remainingTime: 60
    property int size: 28
    width: parent.width
    height: 15
    z: 10

    anchors.top: parent.top
    anchors.topMargin: 50

    Timer {
        id: timer
        interval: 1000; running: true; repeat: true
        onTriggered: {
            if (waveCountdown.remainingTime>0) {
                waveCountdown.remainingTime--;
            }
        }
    }

    Text {
        id: text
        text: waveCountdown.remainingTime
        color: "black"
        font.pixelSize: waveCountdown.size
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
