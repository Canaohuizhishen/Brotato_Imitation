import QtQuick
import QtQuick.Controls
import singleton.PlayerData
import "../components"

Item {
    id: settlementInterface
    property double scaleFactor: 1.0
    anchors.fill: parent
    z: 300
    property alias retryButton: retryButton
    property alias newGameButton: newGameButton
    property alias backMainMenuButton: backMainMenuButton

    Component.onDestruction: {
        if(visible)PlayerData.currentWaveNumber=1
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

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (PlayerData.currentWaveNumber>=20 ? "胜利" : "战败")+"  第"+PlayerData.currentWaveNumber+"波-危险"+PlayerData.difficulty
            color: "white"
            font.pointSize: 21*settlementInterface.scaleFactor
            style: Text.Outline
            styleColor: "black"
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
                    purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel
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
                    purchasedPropsModel: PlayerData.shopContext._purchasedPropsModel
                    duplicatePropsCountModel: PlayerData.shopContext._duplicatePropsCountModel
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
                text: "重试"
                width: 200*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
            SetButton{
                id: newGameButton
                text: "新游戏"
                width: 200*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
            SetButton{
                id: backMainMenuButton
                text: "返回主菜单"
                width: 400*settlementInterface.scaleFactor
                height: 40*settlementInterface.scaleFactor
            }
        }
    }
}

