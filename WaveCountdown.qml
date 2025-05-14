import QtQuick 2.15

Item {
    id: waveCountdown
    property double scaleFactor: 1.0
    property int remainingTime: 60
    property bool running: false
    property int size: 28*waveCountdown.scaleFactor
    width: parent.width
    height: 15*waveCountdown.scaleFactor
    z: 10

    anchors.top: parent.top
    anchors.topMargin: 50*waveCountdown.scaleFactor

    Timer {
        id: timer
        interval: 1000; running: waveCountdown.running; repeat: true
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
