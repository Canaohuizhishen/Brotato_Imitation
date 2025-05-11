import QtQuick 2.15

Item{
    id: gameArea
    width: parent.width*1.5
    height: width
    property var target: parent
    property Player player: player
    x: Math.min(Math.max(gameArea.width/2-player.x+(target.width-gameArea.width)/2,target.width*28/30-gameArea.width),target.width*1/15)
    y: Math.min(Math.max(gameArea.height/2-player.y+(target.height-gameArea.height)/2,target.height*18/20-gameArea.height),target.height*1/10)
    focus: false
    property bool active: true
    property double scaleFactor: 1.0

    property int interval: 1
    property int curWaveNumber: 1
    property int totalWaveNumber: 20
    property bool isWaveOver: false

    Background {
        id: background
        scaleFactor: gameArea.scaleFactor
    }

    Player {
        id: player
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
    }

    Monsters {
        id: monsters
        target: player
        active: gameArea.active
        scaleFactor: gameArea.scaleFactor
    }
}
