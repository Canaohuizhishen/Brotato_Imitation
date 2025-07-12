import QtQuick 2.15
import singleton.PlayerData

Item {
    id: waveCountdown
    property double scaleFactor: 1.0
    property int totalTime: Math.min(15+PlayerData.currentWaveNumber*5,90)
    property int remainingTime: totalTime
    property bool running: PlayerData.isInCombat
    property bool active: true
    property bool paused: false
    width: parent.width
    height: 35*waveCountdown.scaleFactor
    z: 10
    anchors.top: parent.top
    anchors.topMargin: 55*waveCountdown.scaleFactor

    onRemainingTimeChanged: {
        if(remainingTime==0){
            PlayerData.isInCombat=false
        }
    }

    onRunningChanged: {
        if(running==true){
            remainingTime=totalTime
        }else{
            PlayerData.curXp+=PlayerData.harvesting
            PlayerData.materialsNumber+=PlayerData.harvesting
            PlayerData.harvesting=Math.ceil(PlayerData.harvesting*1.05)
        }
    }

    onPausedChanged: {
        if(paused==true){
            timer.pause()
        }else{
            timer.resume()
        }
    }

    function init(){
        visible=true
    }

    function start(){
        PlayerData.isInCombat=true
    }

    function stop(){
        PlayerData.isInCombat=false
    }

    TimerCanPause {
        id: timer
        interval: 1000; running: PlayerData.isInCombat && waveCountdown.active; repeat: true;
        onTriggered: {
            if(waveCountdown.remainingTime>0)waveCountdown.remainingTime--;
        }
    }

    Text {
        id: text
        text: waveCountdown.remainingTime
        color: waveCountdown.remainingTime<=5 ? "red" : "white"
        font.pixelSize: waveCountdown.height
        style: Text.Outline
        styleColor: "black"
        anchors.centerIn: parent
    }
}
