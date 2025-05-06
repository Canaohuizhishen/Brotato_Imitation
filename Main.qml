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

    GameArea {
        id: gameArea
        x: Math.min(Math.max(gameArea.width/2-player.x+(window.width-gameArea.width)/2,window.width*19/20-gameArea.width),window.width*1/20)
        y: Math.min(Math.max(gameArea.height/2-player.y+(window.height-gameArea.height)/2,window.height*19/20-gameArea.height),window.height*1/20)

        Player {
            id: player
            x: gameArea.width/2
            y: gameArea.height/2

        }

        Monsters {
            id: monsters
            target: player
        }

        Component.onCompleted: {
            //gameArea.x=window.width-gameArea.width
        }

        Timer {
            interval: gameArea.interval; running: true; repeat: true
            onTriggered: {

            }
        }
    }

    HealthBar {
        maxHp: playerData.maxHp
        hp: playerData.hp
    }

    ExperienceBar {
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
                PropertyChanges { target: gameArea; isWaveOver: true }
                PropertyChanges { target: monsters; active: false }
                PropertyChanges { target: player; active: false }
            },
            State {
                name: "waveRunning"; when: (!gameArea.isWaveOver)
                PropertyChanges { target: monsters; active: true }
                PropertyChanges { target: player; active: true }
            }
        ]
    }
}
