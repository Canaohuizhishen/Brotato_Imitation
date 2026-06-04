import QtQuick 2.15
import singleton.PlayerData
import "../components"
import "../bullets"
import "../monsters"
import "../weapons"
import "../drops"
import "../logic"

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
    property bool isInCombat: PlayerData.isInCombat

    property Bullets bullets: bullets
    property Drops drops: drops
    property ChestNotificationBar chestBar
    property alias gameLoop: gameLoop

    GameLoop {
        id: gameLoop
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
    }

    Component.onCompleted: {
        // 注册全局 GameLoop 回调
        gameLoop.registerPerFrame(function(dt) { player.updateMovement(dt) })
        gameLoop.registerPerFrame(function(dt) { monsters.updateAllMonsterMovements(dt) })
        gameLoop.registerPerFrame(function() { bullets.checkBulletCollisions() })
        gameLoop.registerPerFrame(function() { monsters.bullets.checkBulletCollisions() })
        gameLoop.registerPerFrame(function() { weapons.updateGoals() })
        gameLoop.registerPer200ms(function() { monsters.checkMonsterCollisions() })
        gameLoop.registerPer200ms(function() { drops.checkDropCollisions() })
        gameLoop.registerPer3000ms(function() { monsters.createWaveMonsters() })
        // 将 gameLoop 引用传递给 monsters 用于子类怪物回调注册
        monsters.gameLoop = gameLoop
    }

    onIsInCombatChanged: {
        if(isInCombat){
            PlayerData.curHp=PlayerData.maxHp
            visible=true
            active=true
            player.focus=true
            player.x=gameArea.width/2
            player.y=gameArea.height/2
            player.faceRight()
        }else {
            active=false
            monsters.disappear()
        }
    }

    onActiveChanged: {
        if(active)player.focus=true
    }

    onPausedChanged: {
        if(!paused)player.focus=true
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
        chestBar: gameArea.chestBar
        onFaceLefted: weapons.faceLeft()
        onFaceRighted: weapons.faceRight()
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
        dropsParent: drops
        forkParent: background.forks
    }

    Bullets{
        id: bullets
        target: monsters
        active: gameArea.isInCombat && gameArea.active
        scaleFactor: gameArea.scaleFactor
    }

    Drops{
        id: drops
        target: player
        active: gameArea.isInCombat && gameArea.active
        scaleFactor: gameArea.scaleFactor
    }

    function init(){
        visible=false
        active=false
        paused=false
        player.init()
        weapons.init()
        monsters.init()
        bullets.init()
        drops.init()

        player.active=Qt.binding(function(){return isInCombat && active})
        player.paused=Qt.binding(function(){return paused})
        weapons.active=Qt.binding(function(){return isInCombat && active})
        weapons.paused=Qt.binding(function(){return paused})
        monsters.active=Qt.binding(function(){return isInCombat && active})
        monsters.paused=Qt.binding(function(){return paused})
        bullets.active=Qt.binding(function(){return isInCombat && active})
        drops.active=Qt.binding(function(){return isInCombat && active})
    }

    function clear(){
        monsters.clear()
        bullets.clear()
        drops.clear()
    }
}
