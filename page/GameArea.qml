import QtQuick 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../components"
import "../bullets"
import "../monsters"
import "../entities"
import "../weapons"
import "../drops"
import "../constructs"
import "../logic"
import "../logic/SpatialGrid.js" as SpatialGrid

Item{
    id: gameArea
    width: parent.width*1.5
    height: width
    property var target: parent
    property Player player: player
    property Monsters monsters : monsters
    x: Math.min(Math.max(gameArea.width/2-player.x+(target.width-gameArea.width)/2,target.width*28/30-gameArea.width),target.width*1/15) + (shakeActive ? shakeXOffset : 0)
    y: Math.min(Math.max(gameArea.height/2-player.y+(target.height-gameArea.height)/2,target.height*18/20-gameArea.height),target.height*1/10) + (shakeActive ? shakeYOffset : 0)
    focus: false
    property double scaleFactor: 1.0
    property bool active: false
    property bool paused: false
    property bool isInCombat: PlayerData.isInCombat
    // 屏幕振动
    property bool shakeActive: false
    property real shakeXOffset: 0
    property real shakeYOffset: 0
    property int shakeIntensity: 6  // 振动幅度（像素）

    function triggerShake() {
        if (shakeAnim.running) shakeAnim.stop()
        shakeAnim.start()
    }

    SequentialAnimation {
        id: shakeAnim
        loops: 1
        PropertyAction { target: gameArea; property: "shakeActive"; value: true }

        // 快速左右/上下抖动
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: shakeIntensity; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: shakeIntensity/2; duration: 25 }
        }
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: -shakeIntensity; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: -shakeIntensity/2; duration: 25 }
        }
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: shakeIntensity/2; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: shakeIntensity/3; duration: 25 }
        }
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: -shakeIntensity/2; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: shakeIntensity/4; duration: 25 }
        }
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: shakeIntensity/4; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: -shakeIntensity/3; duration: 25 }
        }
        ParallelAnimation {
            NumberAnimation { target: gameArea; property: "shakeXOffset"; to: 0; duration: 25 }
            NumberAnimation { target: gameArea; property: "shakeYOffset"; to: 0; duration: 25 }
        }
        PropertyAction { target: gameArea; property: "shakeActive"; value: false }
    }

    property Bullets bullets: bullets
    property Drops drops: drops
    property ChestNotificationBar chestBar
    property alias gameLoop: gameLoop
    property alias componentCache: componentCache

    GameLoop {
        id: gameLoop
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
    }

    ComponentCache {
        id: componentCache
    }

    Component.onCompleted: {
        // 初始化空间网格（200×200 单元格）
        SpatialGrid.init(200)

        // 注册全局 GameLoop 回调
        // 注意顺序：移动 → 网格重建 → 碰撞检测 → 武器瞄准
        gameLoop.registerPerFrame(function(dt) { player.updateMovement(dt) })
        gameLoop.registerPerFrame(function(dt) { monsters.updateAllMonsterMovements(dt) })
        // 每帧重建空间网格（所有活着的怪物重新插入）
        gameLoop.registerPerFrame(function() {
            SpatialGrid.clear()
            monsters.updateSpatialGrid()
        })
        gameLoop.registerPerFrame(function() { monsters.checkMonsterCollisions() })
        gameLoop.registerPerFrame(function() { bullets.checkBulletCollisions() })
        gameLoop.registerPerFrame(function() { monsters.bullets.checkBulletCollisions() })
        gameLoop.registerPerFrame(function() { weapons.updateGoals() })
        // 构筑物更新
        gameLoop.registerPerFrame(function() { constructs.updateAllTargets() })
        gameLoop.registerPerFrame(function() { constructs.checkMineCollisions() })
        gameLoop.registerPer200ms(function() { drops.checkDropCollisions() })
        gameLoop.registerPer3000ms(function() { monsters.createWaveMonsters() })
        // 将 gameLoop 引用传递给 monsters 用于子类怪物回调注册
        monsters.gameLoop = gameLoop
        // 将 componentCache 传递给子组件
        monsters.componentCache = componentCache
        weapons.componentCache = componentCache
        background.componentCache = componentCache
        drops.componentCache = componentCache
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
            // 敌袭结束优化：清理残留弹体、掉落物以提升性能
            if (SettingsData.endOfWaveOptimization) {
                bullets.clear()
                monsters.bullets.clear()
                drops.clear()
            }
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
        onScreenShakeRequested: gameArea.triggerShake()
    }

    Weapons{
        id: weapons
        scaleFactor: gameArea.scaleFactor
        owner: player
        target: monsters
        bulletsParent: bullets
        constructsContainer: constructs
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

    Constructs{
        id: constructs
        active: gameArea.isInCombat && gameArea.active
        paused: gameArea.paused
        componentCache: componentCache
        bulletsParent: bullets
        gameArea: gameArea
        monsterContainer: monsters
    }

    // 低血量屏幕变暗警示
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: Qt.rgba(0.8, 0, 0, 0.4)
        visible: SettingsData.dimScreen && gameArea.isInCombat
                 && PlayerData.curHp / PlayerData.maxHp < 0.25
        opacity: Math.max(0, (1 - PlayerData.curHp / PlayerData.maxHp / 0.25)) * 0.6
        z: 90
    }

    // 手动瞄准准心（四向缺口十字 + 中心圆 — 原作风络）
    Item {
        id: crosshair
        visible: SettingsData.manualAim && gameArea.isInCombat && gameArea.active && !gameArea.paused
        x: gameMouseArea.mouseX - width / 2
        y: gameMouseArea.mouseY - height / 2
        width: 80 * scaleFactor
        height: 80 * scaleFactor
        z: 100

        // 四根独立的臂 + 中心圆，每根臂有红色填充 + 黑色描边
        readonly property real armW: 6 * scaleFactor   // 臂宽
        readonly property real armL: 24 * scaleFactor   // 臂长（从缺口边缘算起）
        readonly property real gap:  12 * scaleFactor    // 中心缺口半宽（单侧间隙）

        // 上臂
        Rectangle {
            x: parent.width / 2 - parent.armW / 2
            y: parent.height / 2 - parent.gap - parent.armL
            width: parent.armW
            height: parent.armL
            color: "#c82020"
            border.width: 1
            border.color: "black"
        }
        // 下臂
        Rectangle {
            x: parent.width / 2 - parent.armW / 2
            y: parent.height / 2 + parent.gap
            width: parent.armW
            height: parent.armL
            color: "#c82020"
            border.width: 1
            border.color: "black"
        }
        // 左臂
        Rectangle {
            x: parent.width / 2 - parent.gap - parent.armL
            y: parent.height / 2 - parent.armW / 2
            width: parent.armL
            height: parent.armW
            color: "#c82020"
            border.width: 1
            border.color: "black"
        }
        // 右臂
        Rectangle {
            x: parent.width / 2 + parent.gap
            y: parent.height / 2 - parent.armW / 2
            width: parent.armL
            height: parent.armW
            color: "#c82020"
            border.width: 1
            border.color: "black"
        }
        // 中心圆点（10px 直径）
        Rectangle {
            x: parent.width / 2 - 5 * scaleFactor
            y: parent.height / 2 - 5 * scaleFactor
            width: 10 * scaleFactor
            height: 10 * scaleFactor
            radius: 5 * scaleFactor
            color: "#c82020"
            border.width: 1
            border.color: "black"
        }
    }

    // 鼠标事件处理：手动瞄准 + 仅限鼠标移动
    MouseArea {
        id: gameMouseArea
        anchors.fill: parent
        enabled: gameArea.isInCombat && gameArea.active && (SettingsData.manualAim || SettingsData.mouseOnly)
        hoverEnabled: SettingsData.manualAim
        propagateComposedEvents: true
        z: 50

        // 手动瞄准时隐藏系统光标，用自定义准心替代
        cursorShape: (SettingsData.manualAim && !gameArea.paused) ? Qt.BlankCursor : Qt.ArrowCursor
        Connections {
            target: SettingsData
            function onManualAimChanged() {
                gameMouseArea.hoverEnabled = SettingsData.manualAim
            }
        }

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton && SettingsData.manualAim && SettingsData.manualAimOnPress) {
                weapons.manualAimPoint = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true
            }
            if (mouse.button === Qt.RightButton && SettingsData.mouseOnly) {
                player.mouseTarget = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true
            }
        }

        onPositionChanged: function(mouse) {
            if (SettingsData.manualAim) {
                if (!SettingsData.manualAimOnPress) {
                    // 常开模式：鼠标位置 = 武器目标
                    weapons.manualAimPoint = Qt.point(mouse.x, mouse.y)
                } else if (mouse.buttons & Qt.LeftButton) {
                    // 按下瞄准模式：按住左键时跟随鼠标
                    weapons.manualAimPoint = Qt.point(mouse.x, mouse.y)
                } else {
                    // 按下瞄准模式：松开左键 → 清空目标 → 回退自动瞄准
                    weapons.manualAimPoint = null
                }
            }
            if (SettingsData.mouseOnly && player.mouseTarget !== null && mouse.buttons & Qt.RightButton) {
                player.mouseTarget = Qt.point(mouse.x, mouse.y)
            }
        }
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
        constructs.init()

        player.active=Qt.binding(function(){return isInCombat && active})
        player.paused=Qt.binding(function(){return paused})
        weapons.active=Qt.binding(function(){return isInCombat && active})
        weapons.paused=Qt.binding(function(){return paused})
        monsters.active=Qt.binding(function(){return isInCombat && active})
        monsters.paused=Qt.binding(function(){return paused})
        bullets.active=Qt.binding(function(){return isInCombat && active})
        drops.active=Qt.binding(function(){return isInCombat && active})
        constructs.active=Qt.binding(function(){return isInCombat && active})
        constructs.paused=Qt.binding(function(){return paused})
    }

    function clear(){
        monsters.clear()
        bullets.clear()
        drops.clear()
        constructs.clear()
    }
}
