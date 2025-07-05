import QtQuick
import QtQuick.Controls
import singleton.PlayerData
import "../components"

Item {
    id: settlementInterface
    anchors.fill: parent
    z: 300

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#353535"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#555555" }
            GradientStop { position: 0.5; color: "#353535" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }
    }

    Column{
        anchors.centerIn: settlementInterface
        spacing: 15

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "胜利|战败  危险* "
            font.pointSize: 30
        }

        Rectangle{
            id:back
            width: 1100
            height: 550
            color: "#1A1A1A"
            Rectangle{
                id:rec
                width: attributePanel.width
                height: parent.height
                color: "black"
                AttributePanel{
                    id: attributePanel
                    inLeft: false
                    scaleFactor: chestOpeningInterface.scaleFactor
                }
            }
            Item {
                anchors.left:rec.right
                anchors.leftMargin: 100
                height: 230
                anchors.top: back.top
                anchors.topMargin: 20
                //武器栏
                PurchasedWeaponsBar {
                    id: weaponBar
                    showNumber: false
                    purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel

                }
                //道具栏
                PurchasedPropsBar {
                    anchors.top: weaponBar.bottom
                    anchors.topMargin: 40
                    purchasedPropsModel: PlayerData.shopContext._purchasedPropsModel
                    duplicatePropsCountModel: PlayerData.shopContext._duplicatePropsCountModel
                }
            }
        }

        Row{
            // anchors.left: parent.left
            // anchors.leftMargin: 280
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            SetButton{
                text: "重试"
                width: 200
                height: 40
            }
            SetButton{
                text: "新游戏"
                width: 200
                height: 40
            }
            SetButton{
                text: "返回主菜单"
                width: 400
                height: 40
            }
        }
    }
}

