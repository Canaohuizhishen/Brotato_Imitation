import QtQuick 2.15
import singleton.PlayerData
import "../components"
import "../monsters"
import "../weapons"

Item{
    id: gameArea
    width: parent.width*1.5
    height: width
    property var target: parent
    property Player player: player
    property Monsters monsters : monsters
    x: Math.min(Math.max(gameArea.width/2-player.x+(target.width-gameArea.width)/2,target.width*28/30-gameArea.width),target.width*1/15)
    y: Math.min(Math.max(gameArea.height/2-player.y+(target.height-gameArea.height)/2,target.height*18/20-gameArea.height),target.height*1/10)
    focus: false
    property bool active: false
    property double scaleFactor: 1.0

    property int interval: 1
    property int curWaveNumber: 1
    property int totalWaveNumber: 20
    property bool isWaveOver: false

    property var bullets: bullets
    property var materials: materials

    Component.onCompleted: {
    }

    onIsWaveOverChanged: {
        if(isWaveOver){
            monsters.disappear()
        }else {
            PlayerData.curHp=PlayerData.maxHp
            player.focus=true
            player.x=gameArea.width/2
            player.y=gameArea.height/2
        }
    }

    Background {
        id: background
        scaleFactor: gameArea.scaleFactor
    }

    Player {
        id: player
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
        onFaceLefted: {
            weapons.faceLeft()
        }
        onFaceRighted: {
            weapons.faceRight()
        }
    }

    Weapons{
        id: weapons
        scaleFactor: gameArea.scaleFactor
        owner: player
        target: monsters
        bulletsParent: bullets
    }

    Monsters {
        id: monsters
        target: player
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
        materialsParent: materials
        waveNumber: gameArea.curWaveNumber
    }

    Bullets{
        id: bullets
        target: monsters
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
    }

    Materials{
        id: materials
        target: player
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
    }
}
