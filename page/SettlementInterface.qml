import QtQuick
import QtQuick.Controls
import singleton.PlayerData
import "../components"

Item {
    width: 1280
    height: 720

    Column{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "胜利|战败  危险* "
            font.pointSize: 30
            //height: 30
        }
        Rectangle{
            id:back
            width: 1100
            height: 600
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
                anchors.topMargin: 15
                //武器栏
                PurchasedWeaponsBar {
                    id:weapon
                     purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel

                }
                //道具栏
                PurchasedPropsBar {
                    anchors.top: weapon.bottom
                    anchors.topMargin: 180
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

