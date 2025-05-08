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

    Component.onCompleted: {
        //background.x=window.width-background.width
    }

    GameArea {
        id: gameArea
        target: window
        visible: true
    }

    HealthBar {
        id: healthBar
        maxHp: playerData.maxHp
        hp: playerData.hp
    }

    ExperienceBar {
        id: experienceBar
        level: playerData.maxHp
        maxXp: playerData.maxHp
        xp: playerData.hp
    }

    WaveNumberText {
        id: waveNumberText
        text: gameArea.curWaveNumber
    }

    WaveCountdown{
        id: waveCountdown
        states: [
            State {
                name: "waveOver"; when: (waveCountdown.remainingTime==0)
                PropertyChanges { target: gameArea; isWaveOver: true; active: false }
            },
            State {
                name: "waveRunning"; when: (!gameArea.isWaveOver)
                PropertyChanges { target: gameArea; active: true }
            }
        ]
    }
}
