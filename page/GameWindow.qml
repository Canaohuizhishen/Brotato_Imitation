import QtQuick 2.15
import singleton.PlayerData
import singleton.SettingsData
import singleton.MonstersData
import "../components"
import "../logic/TextPool.js" as TextPool
import "../logic/ParticlePool.js" as ParticlePool
import "../data/cores"
import "../logic/utils/i18n.js" as I18n
import "../sound"

Item {
    id: gameWindow
    width: 1280
    height: 720
    anchors.centerIn: parent
    clip: true
    property double scaleFactor: 1.0
    property bool inSelectInterface: true
    property bool paused: false

    onWidthChanged: updateScale()
    onHeightChanged: updateScale()

    function updateScale() {
        scaleFactor = width / 1280
    }

    Component.onDestruction: {
        backMainMenu()
    }

    PageManager {
        id: pageManager
    }

    Component.onCompleted: {
        pageManager.register("start", startInterface)
        pageManager.register("roleSelection", roleSelectionInterface)
        pageManager.register("weaponSelection", weaponSelectionInterface)
        pageManager.register("difficultySelection", difficultySelectionInterface)
        pageManager.register("gameArea", gameArea)
        pageManager.register("store", storeInterface)
        pageManager.register("chestOpening", chestOpeningInterface)
        pageManager.register("upgrade", upgradeInterface)
        pageManager.register("settlement", settlementInterface)
        pageManager.register("pause", pauseInterface)
        pageManager.register("retryWave", retryWaveInterface)
        pageManager.register("setting", settingInterface)
        pageManager.push("start")   // 初始栈：[start]（M4：start 入栈收口）
    }

    Sound {
        id: sound
    }

    Shortcut {
        sequence: "Esc"
        enabled: !inSelectInterface && pauseInterface.inMain && !settingInterface.visible ? true : false
        onActivated: {
            // 死亡重试确认框：Esc = 否（与点「否」同路径；避免误触战场暂停/栈错乱）
            if (retryWaveInterface.visible) { gameWindow.declineRetry(); return }
            if(gameWindow.paused)gameWindow.resume()
            else gameWindow.pause()
        }
    }

    SettingInterface {
        id: settingInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onCloseRequested: pageManager.pop()
    }

    PauseInterface{
        id: pauseInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        continueButton.onClicked: gameWindow.resume()
        restartButton.onClicked: gameWindow.restart()
        settingButton.onClicked:  {
            pageManager.push("setting")
        }
        backMainMenuButton.onClicked: gameWindow.backMainMenu()
    }

    StartInterface{
        id: startInterface
        visible: true
        scaleFactor: gameWindow.scaleFactor
        resumeButton.onClicked: continueGame()
        startButton.onClicked:{
            pageManager.push("roleSelection")
        }
        settingButton.onClicked: {
            pageManager.push("setting")
        }
        exitButton.onClicked: Qt.quit()
    }

    RoleSelectionInterface{
        id: roleSelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            pageManager.push("weaponSelection")
            weaponSelectionInterface.selectedRoleName=selectedRoleName
        }
        backButton.onClicked: {
            pageManager.pop()
        }
    }

    WeaponSelectionInterface{
        id: weaponSelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            pageManager.push("difficultySelection")
            difficultySelectionInterface.selectedRoleName=selectedRoleName
            difficultySelectionInterface.selectedWeaponName=selectedWeaponName
        }
        backButton.onClicked: {
            pageManager.pop()
        }
    }

    WeaponCustomizationCore {
        id: weaponCore
    }

    DifficultySelectionInterface{
        id: difficultySelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            PlayerData.init()
            pageManager.clearToBase()
            // for(var i=0;i<1;i++)PlayerData.addWeapon(selectedWeaponName,1)
            for(var i=0;i<1;i++)PlayerData.addWeapon(weaponCore.getWeapon(selectedWeaponName,1).weaponName,1)
            PlayerData.roleName=""
            PlayerData.roleName=selectedRoleName
            PlayerData.addProp(selectedRoleName)
            PlayerData.originWeaponName=""
            PlayerData.originWeaponName=selectedWeaponName
            PlayerData.difficulty=selectedDifficulty
            PlayerData.isInCombat=true
            inSelectInterface=false
            paused=false
            //PlayerData.currentWaveNumber=20
            //PlayerData.materialsNumber=10000
        }
        backButton.onClicked: {
            pageManager.pop()
            init()   // 维持现状：difficulty 仅在返回键重置（无 onEnter 钩子）
        }
    }

    FPSCounter {
        id: fpsCounter
        gameLoop: gameArea.gameLoop
        visible: SettingsData.showFPS
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 8
    }

    GameArea {
        id: gameArea
        target: gameWindow
        visible: false
        active: false
        scaleFactor: gameWindow.scaleFactor
        chestBar: chestNotificationBar
        paused: gameWindow.paused
        onIsInCombatChanged: {
            if(!isInCombat){
                drops.allMaterialsToBag(hud.bagBar.mapToItem(gameArea, hud.bagBar.imageCenterPoint))
                drops.allFruitsToPlayer(player)
                drops.allChestToPlayer(player)
            }
            //monsters.spawnMonsters(1,"prayer")
        }
    }

    DyingBorder{
        anchors.fill: parent
    }

    ChestOpeningInterface{
        id: chestOpeningInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        chestNotificationBar: chestNotificationBar
        onProcessedOne:{
            if(chestNotificationBar.number==0){
                if(upgradeNotificationBar.number){
                    pageManager.replace("upgrade")
                    waveCountdown.visible=false
                }else{
                    pageManager.replace("store")
                }
            }
        }
        onVisibleChanged: {
            if(visible) {
                sound.fadeOut()
            }
        }
    }

    UpgradeInterface{
        id: upgradeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        upgradeNotificationBar: upgradeNotificationBar
        onChoosedOne: {
            if(upgradeNotificationBar.number===0){
                pageManager.replace("store")
                waveCountdown.visible=true
            }
        }
        onVisibleChanged: {
            if(visible) {
                sound.fadeOut()
            }
        }
    }

    StoreInterface{
        id: storeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        startButton.onClicked:{
            pageManager.clearToBase()
            waveCountdown.start()
        }
        onVisibleChanged: {
            if(visible) {
                PlayerData.currentWaveNumber++
                sound.fadeOut()
            } else {
                sound.fadeIn()
            }
        }
        Connections {
            target: pauseInterface
            function onVisibleChanged() {
                if(pauseInterface.visible || settingInterface.visible)storeInterface.hideComponents()
                else storeInterface.unhideComponents()
            }
        }

    }

    SettlementInterface {
        id: settlementInterface
        scaleFactor: gameWindow.scaleFactor
        visible: false
        retryButton.onClicked: gameWindow.restart()
        newGameButton.onClicked: gameWindow.newGame()
        backMainMenuButton.onClicked: gameWindow.backMainMenuFromSettlement()
        Connections {
            target: PlayerData
            function onCurHpChanged() {
                if(PlayerData.curHp<=0){
                    gameArea.active=false
                    gameArea.paused=true
                    delayDietimer.start()
                    TextPool.createText(gameWindow,I18n.tr("战败",SettingsData.language),50*scaleFactor,"white",gameWindow.width/2-50*scaleFactor,100*scaleFactor,2000)
                }
            }
        }
        TimerCanPause {
            id: delayDietimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                // 防守：已经回到主菜单/选择流时，忽略残留的计时器触发（对齐 delayOvertimer）
                if(gameWindow.inSelectInterface) return
                if (SettingsData.retryFailedWave) {
                    // 重新挑战失败的敌袭：先弹确认框（透明，盖在冻结的战场画面上），由玩家选择
                    pageManager.push("retryWave")
                    return
                }
                gameArea.visible = false   // 基座例外：不进栈，死亡路径直接隐藏
                pageManager.push("settlement")
            }
        }
    }

    RetryWaveInterface {
        id: retryWaveInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        yesButton.onClicked: gameWindow.retryCurrentWave()
        noButton.onClicked: gameWindow.declineRetry()
    }

    UpgradeNotificationBar{
        id: upgradeNotificationBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
    }

    ChestNotificationBar{
        id: chestNotificationBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
    }

    WaveCountdown{
        id: waveCountdown
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        active: gameArea.active
        paused: gameArea.paused
        onPausedChanged: {
            if(paused==true){
                delayOvertimer.pause()
                delayDietimer.pause()
            }else{
                delayOvertimer.resume()
                delayDietimer.resume()
            }
        }

        TimerCanPause {
            id: delayOvertimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                // 防守：如果已经回到主菜单，忽略残留的计时器触发
                if(gameWindow.inSelectInterface) return
                if(PlayerData.currentWaveNumber===20){
                    pageManager.push("settlement")
                }else if(chestNotificationBar.number){
                    pageManager.push("chestOpening")
                }else if(upgradeNotificationBar.number){
                    pageManager.push("upgrade")
                    waveCountdown.visible=false
                }else{
                    pageManager.push("store")
                }
            }
        }
    }

    // 替代原先 QML states 管理 delayOvertimer：
    // 波次结束→启动计时器；波次开始→关闭商店并停止计时器
    Connections {
        target: PlayerData
        function onIsInCombatChanged() {
            if (PlayerData.isInCombat) {
                delayOvertimer.stop()
            } else if (!gameWindow.inSelectInterface) {
                delayOvertimer.stop()
                delayOvertimer.running = false
                delayOvertimer.running = true
                // 显示通过/胜利文本（覆盖倒计时结束和Boss击杀两种路径）
                if(PlayerData.currentWaveNumber<20){
                    TextPool.createText(gameWindow,I18n.tr("通过!",SettingsData.language),40*scaleFactor,"white",gameWindow.width/2-40*scaleFactor,100*scaleFactor,2000)
                }else{
                    TextPool.createText(gameWindow,I18n.tr("胜利",SettingsData.language)+"!",50*scaleFactor,"white",gameWindow.width/2-50*scaleFactor,100*scaleFactor,2000)
                }
            }
        }
    }

    HUD {
        id: hud
        visible: gameArea.visible   // 显隐来源与抽取前一致：战斗相位（gameArea.visible）驱动
        scaleFactor: gameWindow.scaleFactor
    }

    function pause(){
        gameWindow.paused = true
        pageManager.push("pause")
    }

    function resume(){
        gameWindow.paused = false
        pageManager.pop()
    }

    function restart(){
        inSelectInterface=true
        delayDietimer.stop()   // 清掉可能残留的死亡转场计时器（快速重开路径）
        pageManager.clearToBase()
        settingInterface.init()
        pauseInterface.init()
        gameArea.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        storeInterface.init()
        settlementInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        waveCountdown.init()
        PlayerData.init()

        gameArea.paused=Qt.binding(function(){return paused})
        var roleName=PlayerData.roleName
        PlayerData.roleName=""
        PlayerData.roleName=roleName
        PlayerData.addWeapon(PlayerData.originWeaponName,1)

        PlayerData.isInCombat=true
        paused=false
        inSelectInterface=false
    }

    // ── 死亡重试（"重新挑战失败的敌袭"）───────────────────────────
    // 是：原地重开当前波 —— 语义 = 刚从上一波商店进入本波（满血、倒计时回满、
    // 出怪节奏从零、本波中途所得严格回退）。isInCombat 保持 true 不动，
    // 避免触发由 isInCombat 变化驱动的波终收获结算/通过流程。
    function retryCurrentWave(){
        if(inSelectInterface) return
        delayDietimer.stop()
        pageManager.clearToBase()          // 收起确认框（含极端情况下垫在底下的暂停页）
        PlayerData.rollbackWaveGains()     // 严格回退本波收益（单一收口，见 PlayerData）
        chestNotificationBar.init()        // 本波积攒的宝箱/升级清零（波初态均为 0）
        upgradeNotificationBar.init()
        gameArea.monsters.clear()          // 立即销毁旧怪：渐隐动画被恢复会"复活开火"，销毁对象=动画同灭
        gameArea.monsters.bullets.clear()  // Monsters.clear() 不含怪物子弹容器，需补清
        gameArea.bullets.clear()
        gameArea.drops.clear()
        MonstersData.resetForWave()        // 出怪节奏复位（波次号不变，onWaveNumberChanged 不会触发）
        gameArea.gameLoop.resetSpawnPhase()// 出怪桶相位清零：首刷回到 +3s（否则沿用死亡时刻相位，可能瞬刷）
        paused = false
        gameArea.paused = Qt.binding(function(){return paused})   // 重建被死亡字面量赋值打断的绑定
        gameArea.beginWave()               // 波次开始复位（与 isInCombat 真分支同源）
        waveCountdown.remainingTime = waveCountdown.totalTime
        gameArea.player.mouseTarget = null                                    // 清掉残留的鼠标移动目标
        gameArea.player.keysPressed = ({"W": false, "A": false, "S": false, "D": false})   // 清掉可能残留的按键状态
    }

    // 否：走正常死亡结算流程（等价于原 delayDietimer 触发路径）
    function declineRetry(){
        if(inSelectInterface) return
        gameArea.visible = false
        pageManager.replace("settlement")
    }

    function continueGame(){
        PlayerData.currentWaveNumber--
        storeInterface.isContinue = true
        pageManager.replace("store")   // start → store
        paused=false
        inSelectInterface=false
    }

    function backMainMenu(){
        // 必须先设 inSelectInterface=true，阻止 onIsInCombatChanged 误触发 delayOvertimer
        inSelectInterface=true
        delayDietimer.stop()   // 清掉可能残留的死亡转场计时器（死亡 2 秒内快速返回的路径）
        if(PlayerData.currentWaveNumber===1){
            roleSelectionInterface.init()
            weaponSelectionInterface.init()
            difficultySelectionInterface.init()
            PlayerData.init()
        }
        if(!storeInterface.visible){
            PlayerData.harvesting-=Math.max(PlayerData.harvesting*0.05,1)
            PlayerData.materialsNumber-=PlayerData.harvesting
            PlayerData.curXp-=PlayerData.harvesting
        }
        pageManager.clearToBase()   // 清栈收口（须在经济结算之后：暂停盖商店时 store 仍为可见态，不得误罚）
        PlayerData.rollbackWaveGains()   // 回退本波收益（单一收口；经验为精确口径）
        PlayerData.remainingMaterialsNumber=0   // 维持既有语义：返回主菜单清空余料池
        PlayerData.isInCombat=false
        gameArea.clear()
        // 回主菜单清理对象池残留（两池均惰性重建，无需常驻）
        TextPool.release()
        ParticlePool.release()
        settingInterface.init()
        pauseInterface.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        storeInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        waveCountdown.init()

        gameArea.paused=Qt.binding(function(){return paused})
        pageManager.push("start")
        // 主动存档，不依赖 destruction 顺序
        if (PlayerData.currentWaveNumber > 1) {
            PlayerData.saveGame()
        }
    }

    function backMainMenuFromSettlement(){
        init()
        pageManager.push("start")
    }

    function newGame(){
        init()
        pageManager.push("start")
        pageManager.push("roleSelection")
    }

    function init(){
        paused=false
        inSelectInterface=true
        delayDietimer.stop()   // 清掉可能残留的死亡转场计时器（重置路径统一收口）
        pageManager.clearToBase()
        settingInterface.init()
        pauseInterface.init()
        startInterface.init()
        roleSelectionInterface.init()
        weaponSelectionInterface.init()
        difficultySelectionInterface.init()
        gameArea.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        storeInterface.init()
        settlementInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        waveCountdown.init()
        PlayerData.init()

        gameArea.paused=Qt.binding(function(){return paused})
    }
}
