import QtQuick 2.15
import singleton.PlayerData
import "../components"
import "../tool.js" as Tool

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
        //console.log(scaleFactor)
    }

    Component.onCompleted: {
        // gameArea.player.roleName="wellRounded"
        // PlayerData.addWeapon("smg")
        // PlayerData.isInCombat=true
        // inSelectInterface=false
    }

    Component.onDestruction: {
        backMainMenu()
    }

    Shortcut {
        sequence: "Esc"
        enabled: !inSelectInterface && pauseInterface.inMain && !settingInterface.visible ? true : false
        onActivated: {
            if(gameWindow.paused)gameWindow.resume()
            else gameWindow.pause()
        }
    }

    SettingInterface {
        id: settingInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        showModifier: inSelectInterface
    }

    PauseInterface{
        id: pauseInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        continueButton.onClicked: gameWindow.resume()
        restartButton.onClicked: gameWindow.restart()
        settingButton.onClicked:  {
            pauseInterface.visible=Qt.binding(function(){return !settingInterface.visible})
            settingInterface.visible=true
        }
        backMainMenuButton.onClicked: gameWindow.backMainMenu()
    }

    StartInterface{
        id: startInterface
        visible: true
        scaleFactor: gameWindow.scaleFactor
        z:100
        resumeButton.visible: PlayerData.currentWaveNumber>1 ? true : false
        resumeButton.onClicked: continueGame()
        startButton.onClicked:{
            startInterface.visible=false
            roleSelectionInterface.init()
            roleSelectionInterface.visible=true
        }
        settingButton.onClicked: {
            settingInterface.visible=true
        }
        exitButton.onClicked: Qt.quit()
    }

    RoleSelectionInterface{
        id: roleSelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            roleSelectionInterface.visible=false
            weaponSelectionInterface.init()
            weaponSelectionInterface.selectedRoleName=selectedRoleName
            weaponSelectionInterface.visible=true
        }
        backButton.onClicked: {
            init()
            startInterface.visible=true
        }
    }

    WeaponSelectionInterface{
        id: weaponSelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            weaponSelectionInterface.visible=false
            difficultySelectionInterface.selectedRoleName=selectedRoleName
            difficultySelectionInterface.selectedWeaponName=selectedWeaponName
            difficultySelectionInterface.visible=true
        }
        backButton.onClicked: {
            init()
            roleSelectionInterface.visible=true
        }
    }

    DifficultySelectionInterface{
        id: difficultySelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        onSelected:{
            PlayerData.init()
            difficultySelectionInterface.visible=false
            for(var i=0;i<1;i++)PlayerData.addWeapon(selectedWeaponName,1)
            PlayerData.roleName=""
            PlayerData.roleName=selectedRoleName
            PlayerData.originWeaponName=""
            PlayerData.originWeaponName=selectedWeaponName
            PlayerData.difficulty=selectedDifficulty
            PlayerData.isInCombat=true
            inSelectInterface=false
            paused=false
            //PlayerData.currentWaveNumber=20
        }
        backButton.onClicked: {
            init()
            weaponSelectionInterface.visible=true
        }
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
                drops.allMaterialsToBag(bagBar.mapToItem(gameArea,bagBar.imageCenterPoint))
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
                visible=false
                if(upgradeNotificationBar.number){
                    upgradeInterface.visible=true
                    waveCountdown.visible=false
                }else{
                    storeInterface.visible=true
                }
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
                upgradeInterface.visible=false
                waveCountdown.visible=true
                storeInterface.visible=true
            }
        }
    }

    StoreInterface{
        id: storeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        startButton.onClicked:{
            visible=false
            waveCountdown.start()
        }
        onVisibleChanged: {
            if(visible)PlayerData.currentWaveNumber++
        }
        Connections {
            target: pauseInterface
            function onVisibleChanged() {
                if(pauseInterface.visible)storeInterface.hideComponents()
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
                    Tool.createText(gameWindow,"战败",50*scaleFactor,"white",gameWindow.width/2-50*scaleFactor,100*scaleFactor,2000)
                }
            }
        }
        TimerCanPause {
            id: delayDietimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                gameArea.visible=false
                settlementInterface.visible=true
            }
        }
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
        states: [
            State {
                name: "notInCombat"; when: (!PlayerData.isInCombat && !gameWindow.inSelectInterface)
                PropertyChanges { delayOvertimer.running: true }
                StateChangeScript {
                    script: {
                        if(!waveCountdown.remainingTime){
                            if(PlayerData.currentWaveNumber<20)Tool.createText(gameWindow,"通过!",40*scaleFactor,"white",gameWindow.width/2-40*scaleFactor,100*scaleFactor,2000)
                            else Tool.createText(gameWindow,"胜利!",50*scaleFactor,"white",gameWindow.width/2-50*scaleFactor,100*scaleFactor,2000)
                        }
                    }
                }
            },
            State {
                name: "inCombat"; when: (PlayerData.isInCombat)
                PropertyChanges { storeInterface.visible: false }
            }
        ]
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
                if(PlayerData.currentWaveNumber===20){
                    settlementInterface.visible=true
                }else if(chestNotificationBar.number){
                    chestOpeningInterface.visible=true
                }else if(upgradeNotificationBar.number){
                    upgradeInterface.visible=true
                    waveCountdown.visible=false
                }else{
                    storeInterface.visible=true
                }
            }
        }
    }

    HealthBar {
        id: healthBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        maxHp: PlayerData.maxHp
        hp: PlayerData.curHp
    }

    ExperienceBar {
        id: experienceBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        level: PlayerData.curLevel
        maxXp: PlayerData.maxXp
        xp: PlayerData.curXp
    }

    MaterialsBar{
        id: materialsBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        number: PlayerData.materialsNumber
    }

    BagBar{
        id: bagBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        number: PlayerData.remainingMaterialsNumber
    }

    WaveNumberText {
        id: waveNumberText
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        text: PlayerData.currentWaveNumber
    }

    function pause(){
        gameWindow.paused = true
        pauseInterface.visible = true
    }

    function resume(){
        gameWindow.paused = false
        pauseInterface.visible = false
    }

    function restart(){
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
        upgradeNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        chestNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        var roleName=PlayerData.roleName
        PlayerData.roleName=""
        PlayerData.roleName=roleName
        PlayerData.addWeapon(PlayerData.originWeaponName,1)

        PlayerData.isInCombat=true
        paused=false
    }

    function continueGame(){
        PlayerData.currentWaveNumber--
        startInterface.visible=false
        storeInterface.visible=true
        paused=false
        inSelectInterface=false
    }

    function backMainMenu(){
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
        PlayerData.materialsNumber-=PlayerData.curWaveMaterialsNumber
        PlayerData.curXp-=PlayerData.curWaveMaterialsNumber
        PlayerData.curWaveMaterialsNumber=0
        PlayerData.remainingMaterialsNumber=0
        PlayerData.isInCombat=false
        gameArea.clear()
        settingInterface.init()
        pauseInterface.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        storeInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        waveCountdown.init()

        inSelectInterface=true
        gameArea.paused=Qt.binding(function(){return paused})
        upgradeNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        chestNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        startInterface.visible=true
    }

    function backMainMenuFromSettlement(){
        init()
        startInterface.visible=true
    }

    function newGame(){
        init()
        roleSelectionInterface.visible=true
    }

    function init(){
        paused=false
        inSelectInterface=true
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
        upgradeNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        chestNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
    }
}
