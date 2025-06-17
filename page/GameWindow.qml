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
        gameArea.visible=true
        gameArea.active=true
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
    //         gameArea.visible=true
    //         gameArea.active=true
    //         gameArea.player.focus=true
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
        active: false
        curWaveNumber: waveCountdown.waveNumber

        onIsWaveOverChanged: {
            if(isWaveOver){
                materials.allToBag(gameWindow.mapToItem(gameArea,52.5,117.5))
            }
        }
    }

    // UpgradeInterface{
    //     id: upgradeInterface
    // }

    StoreInterface{
        id: storeInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor
        goButton.onClicked:{
            visible=false
            gameArea.visible=true
            gameArea.active=true
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
        text: gameArea.curWaveNumber
    }

    WaveCountdown{
        id: waveCountdown
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        running: gameArea.active
        //running:false
        states: [
            State {
                name: "waveOver"; when: (waveCountdown.isWaveOver)
                PropertyChanges { gameArea.isWaveOver: true; gameArea.active: false}
                PropertyChanges { delaytimer.running: true}
                PropertyChanges { upgradeNotificationBar.isCombatting: false}
            },
            State {
                name: "waveRunning"; when: (!waveCountdown.isWaveOver)
                PropertyChanges { gameArea.isWaveOver: false; gameArea.active: true}
                PropertyChanges { storeInterface.visible: false}
                PropertyChanges { upgradeNotificationBar.isCombatting: true}
            }
        ]

        Timer {
            id: delaytimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                storeInterface.visible=true
                gameArea.visible=false
            }
        }
    }

    UpgradeNotificationBar{
        id: upgradeNotificationBar
        scaleFactor: gameWindow.scaleFactor
    }
}
