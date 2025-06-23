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

    onWidthChanged: updateScale()
    onHeightChanged: updateScale()

    function updateScale() {
        scaleFactor = width / 1280
    }

    Component.onCompleted: {
        waveCountdown.start()
        gameArea.player.focus=true
        gameArea.player.roleName="wellRounded"
    }

    // Timer {
    //     interval: 100; running: true; repeat: true
    //     onTriggered: {
    //         //console.log(gameWindow.scaleFactor)
    //     }
    // }

    // StartInterface{
    //     id: startInterface
    //     visible: true
    //     scaleFactor: gameWindow.scaleFactor
    //     z:100

    //     startButton.onClicked:{
    //         startInterface.visible=false
    //         roleSelectionInterface.visible=true
    //     }

    //     exitButton.onClicked:{
    //         Qt.quit()
    //     }
    // }

    // RoleSelectionInterface{
    //     id: roleSelectionInterface
    //     visible: false
    //     scaleFactor: gameWindow.scaleFactor

    //     onSelected:{
    //         roleSelectionInterface.visible=false
    //         weaponSelectionInterface.visible=true
    //         weaponSelectionInterface.selectedRoleName=selectedRoleName

    //     }

    //     backButton.onClicked: {
    //         init()
    //         roleSelectionInterface.visible=false
    //         startInterface.visible=true
    //     }
    // }

    // WeaponSelectionInterface{
    //     id: weaponSelectionInterface
    //     visible: false
    //     scaleFactor: gameWindow.scaleFactor

    //     onSelected:{
    //         weaponSelectionInterface.visible=false
    //         difficultySelectionInterface.visible=true
    //         difficultySelectionInterface.selectedRoleName=selectedRoleName
    //         difficultySelectionInterface.selectedWeaponName=selectedWeaponName
    //     }

    //     backButton.onClicked: {
    //         init()
    //         weaponSelectionInterface.visible=false
    //         roleSelectionInterface.visible=true
    //     }
    // }

    // DifficultySelectionInterface{
    //     id: difficultySelectionInterface
    //     visible: false
    //     scaleFactor: gameWindow.scaleFactor

    //     onSelected:{
    //         difficultySelectionInterface.visible=false
    //         waveCountdown.start()
    //         gameArea.player.roleName=selectedRoleName
    //         gameArea.monsters.difficulty=selectedDifficulty
    //     }

    //     backButton.onClicked: {
    //         init()
    //         difficultySelectionInterface.visible=false
    //         weaponSelectionInterface.visible=true
    //     }
    // }

    GameArea {
        id: gameArea
        target: gameWindow
        visible: false
        scaleFactor: gameWindow.scaleFactor
        chestBar: chestNotificationBar
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
    }

    // Pause{
    //     id:pause
    //     visible: false
    // }
    // Shortcut {
    //     sequence: "Esc"
    //     onActivated: {
    //         pause.visible = !pause.visible
    //         // 这里可以添加游戏暂停/继续的逻辑
    //     }
    // }

    StoreInterface{
        id: storeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        goButton.onClicked:{
            visible=false
            waveCountdown.start()
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

    WaveCountdown{
        id: waveCountdown
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        active: gameArea.active
        paused: gameArea.paused
        states: [
            State {
                name: "notInCombat"; when: (!PlayerData.isInCombat)
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

    UpgradeNotificationBar{
        id: upgradeNotificationBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        onNumberChanged: {
            if(number===0){
                upgradeInterface.visible=false
                waveCountdown.visible=true
                storeInterface.visible=true
            }
        }
    }

    ChestNotificationBar{
        id: chestNotificationBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        onNumberChanged: {
            if(number===0){
                // upgradeInterface.visible=false
                // waveCountdown.visible=true
                // storeInterface.visible=true
            }
        }
    }
}
