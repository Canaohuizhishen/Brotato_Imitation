import QtQuick 2.15

Item {
    id: waveCountdown
    property double scaleFactor: 1.0
    property int waveNumber: 0
    property bool isWaveOver: false
    property int totalTime: Math.min(15+waveNumber*5,60)
    property int remainingTime: totalTime
    property bool running: false
    property int size: 28*waveCountdown.scaleFactor
    width: parent.width
    height: 15*waveCountdown.scaleFactor
    z: 10

    anchors.top: parent.top
    anchors.topMargin: 50*waveCountdown.scaleFactor

    onRemainingTimeChanged: {
        if(remainingTime==0){
            //running=false
            isWaveOver=true
        }
    }
    onRunningChanged: {
        if(running==true){
            waveNumber++
            remainingTime=totalTime
            isWaveOver=false
        }
    }

    function start(){
        running=true
    }

    Timer {
        id: timer
        interval: 1000; running: waveCountdown.running; repeat: true
        onTriggered: {
            waveCountdown.remainingTime--;
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
        color: waveCountdown.remainingTime<=5 ? "red" : "white"
        font.pixelSize: waveCountdown.size
        anchors.centerIn: text.anchors.centerIn
    }
}
