import QtQuick
import QtQuick.Controls
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
                width: attributePanel.width
                height: parent.height
                color: "black"
                AttributePanel{
                    id: attributePanel
                    inLeft: false
                    scaleFactor: chestOpeningInterface.scaleFactor
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

