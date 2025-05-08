import QtQuick 2.15

Item{
    id: gameArea
    width: parent.width*1.5
    height: width
    property var target: parent
    x: Math.min(Math.max(gameArea.width/2-player.x+(target.width-gameArea.width)/2,target.width*19/20-gameArea.width),target.width*1/20)
    y: Math.min(Math.max(gameArea.height/2-player.y+(target.height-gameArea.height)/2,target.height*19/20-gameArea.height),target.height*1/20)
    focus: false
    property bool active: true

    property int interval: 1
    property int curWaveNumber: 1
    property int totalWaveNumber: 20
    property bool isWaveOver: false

    Background {
        id: background
    }

    Player {
        id: player
        x: background.width/2
        y: background.height/2
        active: gameArea.active
    }

    Monsters {
        id: monsters
        target: player
        active: gameArea.active
    }
}
