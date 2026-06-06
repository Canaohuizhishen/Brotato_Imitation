import QtQuick
import QtQuick.Controls
import singleton.PlayerData
import singleton.SettingsData
import "../components"
import "../logic/utils/i18n.js" as I18n

Item {
    id: settlementInterface
    property double scaleFactor: 1.0
    anchors.fill: parent
    z: 300
    property alias retryButton: retryButton
    property alias newGameButton: newGameButton
    property alias backMainMenuButton: backMainMenuButton

    Component.onDestruction: {//在结算界面退出游戏时清空数据,防止用户在结算界面大退再重启后可以点击继续重打最后一波
        if(visible)PlayerData.init()
    }

    onVisibleChanged: {//在结算界面出现时更新最高通关难度数据
        if(visible && PlayerData.currentWaveNumber>=20){
            if(PlayerData.maxDifficultyCompleted<PlayerData.difficulty)PlayerData.maxDifficultyCompleted=PlayerData.difficulty
        }
    }

    function init(){
        visible=false
    }

    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#555555" }
            GradientStop { position: 0.5; color: "#353535" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }
    }

    Column{
        anchors.centerIn: settlementInterface
        spacing: 15*settlementInterface.scaleFactor

        ScaledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: PlayerData.curHp>0
                ? I18n.trFormat("settlement_victory", SettingsData.language, [PlayerData.currentWaveNumber, PlayerData.difficulty])
                : I18n.trFormat("settlement_defeat", SettingsData.language, [PlayerData.currentWaveNumber, PlayerData.difficulty])
            color: "white"
            basePixelSize: 21
            uiScale: settlementInterface.scaleFactor
            style: Text.Outline
            styleColor: "black"
        }

        // 无尽模式得分
        ScaledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (PlayerData.currentWaveNumber < 20) return ""
                var modeName = SettingsData.endlessScoreMode === 0
                    ? I18n.tr("最高敌袭次数", SettingsData.language) : I18n.tr("最高难度", SettingsData.language)
                var score = SettingsData.endlessScoreMode === 0
                    ? PlayerData.currentWaveNumber
                    : PlayerData.currentWaveNumber * PlayerData.difficulty
                return I18n.trFormat("endless_score", SettingsData.language, [modeName, score])
            }
            color: "#FFD700"
            basePixelSize: 18
            uiScale: settlementInterface.scaleFactor
            visible: PlayerData.currentWaveNumber >= 20
        }

        Rectangle{
            id:back
            width: 1100*settlementInterface.scaleFactor
            height: 550*settlementInterface.scaleFactor
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#212121" }
                GradientStop { position: 1.0; color: "#0d0d0d" }
            }
            Rectangle{
                id:rec
                width: attributePanel.width
                height: parent.height
                color: "black"
                AttributePanel{
                    id: attributePanel
                    inLeft: false
                    scaleFactor: settlementInterface.scaleFactor
                }
            }
            Item {
                anchors.left:rec.right
                anchors.leftMargin: 100*settlementInterface.scaleFactor
                height: 230*settlementInterface.scaleFactor
                anchors.top: back.top
                anchors.topMargin: 20*settlementInterface.scaleFactor
                //武器栏
                WeaponsBar {
                    id: weaponBar
                    columns: 6
                    scaleFactor: settlementInterface.scaleFactor
                    showNumber: false
                    showButton: false
                    inUp: false
                    inLeft: false
                }
                //道具栏
                PropsBar {
                    id: propBar
                    columns: 8
                    scaleFactor: settlementInterface.scaleFactor
                    anchors.top: weaponBar.bottom
                    anchors.topMargin: 30*settlementInterface.scaleFactor
                    inUp: true
                    inLeft: false
                }
            }
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15*settlementInterface.scaleFactor
            SetButton{
                id: retryButton
                text: I18n.tr("重试", SettingsData.language)
                width: 200*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
            SetButton{
                id: newGameButton
                text: I18n.tr("新游戏", SettingsData.language)
                width: 200*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
            SetButton{
                id: backMainMenuButton
                text: I18n.tr("返回主菜单", SettingsData.language)
                width: 400*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
        }
    }
}

