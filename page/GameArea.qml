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
    property double scaleFactor: 1.0
    property bool active: false
    property bool paused: false

    property int interval: 1
    property int totalWaveNumber: 20
    property bool isInCombat: PlayerData.isInCombat

    property var bullets: bullets
    property var materials: materials

    Component.onCompleted: {
    }

    onIsInCombatChanged: {
        if(isInCombat){
            PlayerData.curHp=PlayerData.maxHp
            visible=true
            active=true
            paused=false
            player.focus=true
            player.x=gameArea.width/2
            player.y=gameArea.height/2
        }else {
            active=false
            monsters.disappear()
        }
    }

    Background {
        id: background
        scaleFactor: gameArea.scaleFactor
    }

    Player {
        id: player
        scaleFactor: gameArea.scaleFactor
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
        onFaceLefted: {
            weapons.faceLeft()
        }
        onFaceRighted: {
            weapons.faceRight()
        }
        Keys.onEscapePressed: {
            gameArea.paused=!gameArea.paused
        }
    }

    Weapons{
        id: weapons
        scaleFactor: gameArea.scaleFactor
        owner: player
        target: monsters
        bulletsParent: bullets
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
    }

    Monsters {
        id: monsters
        target: player
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
        scaleFactor: gameArea.scaleFactor
        materialsParent: materials
    }

    Bullets{
        id: bullets
        target: monsters
        active: gameArea.isInCombat && gameArea.active
        scaleFactor: gameArea.scaleFactor
    }

    Materials{
        id: materials
        target: player
        active: gameArea.isInCombat && gameArea.active
        scaleFactor: gameArea.scaleFactor
    }
}
