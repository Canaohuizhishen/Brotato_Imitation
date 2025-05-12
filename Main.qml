import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Brotato

ApplicationWindow {
    id: window
    visible: true
    width: 1000
    height: width/16*10
    title: "土豆兄弟(Brotato)(仿)"
    color: "black"
    property double scaleFactor: 1.0

    onWidthChanged: updateScale()
    onHeightChanged: updateScale()

    function updateScale() {
        scaleFactor = Math.min(width / 1000, height / (1000/16*10))
    }

    Component.onCompleted: {
    }

    GameArea {
        id: gameArea
        target: window
        visible: false
        scaleFactor: window.scaleFactor
        active: false
    }

    StartInterface{
        id: startInterface
        visible: true
        scaleFactor: window.scaleFactor
        z:100

        start.onClicked:{
            startInterface.visible=false
            gameArea.visible=true
            gameArea.active=true
            gameArea.player.focus=true
        }

        exit.onClicked:{
            Qt.quit()
        }
    }

    HealthBar {
        id: healthBar
        visible: gameArea.visible
        maxHp: playerData.maxHp
        hp: playerData.hp
    }

    ExperienceBar {
        id: experienceBar
        visible: gameArea.visible
        level: playerData.maxHp
        maxXp: playerData.maxHp
        xp: playerData.hp
    }

    WaveNumberText {
        id: waveNumberText
        visible: gameArea.visible
        text: gameArea.curWaveNumber
    }

    WaveCountdown{
        id: waveCountdown
        visible: gameArea.visible
        running: gameArea.active
        states: [
            State {
                name: "waveOver"; when: (waveCountdown.remainingTime==0)
                PropertyChanges { target: gameArea; isWaveOver: true; active: false }
            }
        ]
    }
}
