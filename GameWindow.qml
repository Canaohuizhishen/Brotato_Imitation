import QtQuick 2.15

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
    }

    // Timer {
    //     interval: 100; running: true; repeat: true
    //     onTriggered: {
    //         console.log(gameWindow.scaleFactor)
    //     }
    // }

    GameArea {
        id: gameArea
        target: gameWindow
        visible: false
        scaleFactor: gameWindow.scaleFactor
        active: false
    }

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
            roleSelectionInterface.visible=false
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
            weaponSelectionInterface.visible=false
            roleSelectionInterface.visible=true
        }
    }

    DifficultySelectionInterface{
        id: difficultySelectionInterface
        visible: false
        scaleFactor: gameWindow.scaleFactor

        onSelected:{
            difficultySelectionInterface.visible=false
            gameArea.visible=true
            gameArea.active=true
            gameArea.player.focus=true
            gameArea.player.roleName=selectedRoleName
            gameArea.monsters.difficulty=selectedDifficulty
        }

        backButton.onClicked: {
            init()
            difficultySelectionInterface.visible=false
            weaponSelectionInterface.visible=true
        }
    }

    HealthBar {
        id: healthBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        maxHp: playerData.maxHp
        hp: playerData.hp
    }

    ExperienceBar {
        id: experienceBar
        visible: gameArea.visible
        scaleFactor: gameWindow.scaleFactor
        level: playerData.maxHp
        maxXp: playerData.maxHp
        xp: playerData.hp
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
        states: [
            State {
                name: "waveOver"; when: (waveCountdown.remainingTime==0)
                PropertyChanges { target: gameArea; isWaveOver: true; active: false }
            }
        ]
    }
}
