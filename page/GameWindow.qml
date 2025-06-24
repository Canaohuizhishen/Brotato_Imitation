import QtQuick 2.15
import singleton.PlayerData
import "../components"

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

    Component.onCompleted: {
        // gameArea.player.roleName="wellRounded"
        // PlayerData.isInCombat=true
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            if(gameWindow.paused)gameWindow.resume()
            else gameWindow.pause()
        }
    }

    // Timer {
    //     interval: 100; running: true; repeat: true
    //     onTriggered: {
    //         //console.log(gameWindow.scaleFactor)
    //     }
    // }

    StartInterface{
        id: startInterface
        visible: true
        scaleFactor: gameWindow.scaleFactor
        z:100

        startButton.onClicked:{
            startInterface.visible=false
            roleSelectionInterface.visible=true
        }

        exitButton.onClicked:{
            Qt.quit()
        }
    }

    RoleSelectionInterface{
        id: roleSelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor

        onSelected:{
            roleSelectionInterface.visible=false
            weaponSelectionInterface.visible=true
            weaponSelectionInterface.selectedRoleName=selectedRoleName

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
            difficultySelectionInterface.visible=true
            difficultySelectionInterface.selectedRoleName=selectedRoleName
            difficultySelectionInterface.selectedWeaponName=selectedWeaponName
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
            difficultySelectionInterface.visible=false
            gameArea.player.roleName=selectedRoleName
            PlayerData.addWeapon(selectedWeaponName)
            gameArea.monsters.difficulty=selectedDifficulty
            PlayerData.isInCombat=true
            inSelectInterface=false
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
        }
    }

    // ShopScreen {
    //     anchors.fill: parent
    // }

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

    // SettlementInterface{
    //     visible: true
    // }

    PauseInterface{
        id: pauseInterface
        visible: false
        continueButton.onClicked: gameWindow.resume()
        restartButton.onClicked: gameWindow.restart()
        z: 100
    }

    StoreInterface{
        id: storeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        goButton.onClicked:{
            visible=false
            waveCountdown.start()
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
                PropertyChanges { delaytimer.running: true }
            },
            State {
                name: "inCombat"; when: (PlayerData.isInCombat)
                PropertyChanges { storeInterface.visible: false }
            }
        ]
        onPausedChanged: {
            if(paused==true){
                delaytimer.pause()
            }else{
                delaytimer.resume()
            }
        }
        TimerCanPause {
            id: delaytimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                if(chestNotificationBar.number){
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
        gameArea.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        pauseInterface.init()
        storeInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        PlayerData.init()

        gameArea.paused=Qt.binding(function(){return paused})
        upgradeNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        chestNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        PlayerData.isInCombat=true
        paused=false
    }

    function init(){
        paused=false
        inSelectInterface=true
        startInterface.init()
        roleSelectionInterface.init()
        weaponSelectionInterface.init()
        difficultySelectionInterface.init()
        gameArea.init()
        chestOpeningInterface.init()
        upgradeInterface.init()
        pauseInterface.init()
        storeInterface.init()
        upgradeNotificationBar.init()
        chestNotificationBar.init()
        PlayerData.init()

        gameArea.paused=Qt.binding(function(){return paused})
        upgradeNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
        chestNotificationBar.visible=Qt.binding(function(){return gameArea.visible})
    }
}
