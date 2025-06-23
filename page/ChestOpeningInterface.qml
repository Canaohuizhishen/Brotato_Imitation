import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import "../components"

Item {
    id: chestOpeningInterface
    property ChestNotificationBar chestNotificationBar
    property double scaleFactor: 1.0
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100

    property alias getButton: getButton
    property alias recycleButton: recycleButton
    signal processedOne()

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.85
    }

    Text {
        id: upgradeTitle
        text: "发现道具!"
        font.pixelSize: 42*chestOpeningInterface.scaleFactor
        style: Text.Outline
        color: "black"
        anchors.top: parent.top
        anchors.topMargin: 70*chestOpeningInterface.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: upgradeTitle.text
            color: "white"
            font.pixelSize: upgradeTitle.font.pixelSize
            anchors.centerIn: upgradeTitle
        }
    }

    Row{
        anchors.centerIn: chestOpeningInterface
        spacing: 170

        AttributePanel{
            id: attributePanel
            scale: 1.2
            scaleFactor: chestOpeningInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
        }

        PropCard{
            id: propCard
            propName: chestNotificationBar.number ? chestNotificationBar.chests.get(0).propName : ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Column{
            spacing: 50
            anchors.verticalCenter: parent.verticalCenter

            Button{
                id: getButton
                text: "拿取"
                width: 230
                height: width/4
                background: Rectangle {
                    color: getButton.pressed || getButton.hovered ? "white" : "black"
                    radius: 4
                }
                contentItem: Text {
                    text: getButton.text
                    font.pixelSize: 23*chestOpeningInterface.scaleFactor
                    color: getButton.pressed || getButton.hovered ? "black" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    propCard.core.apply()
                    attributePanel.upData()
                    chestNotificationBar.reduceChest()
                    processedOne()
                }
            }

            Button{
                id: recycleButton
                width: getButton.width
                height: width/4
                background: Rectangle {
                    color: recycleButton.pressed || recycleButton.hovered ? "white" : "black"
                    radius: 4
                }
                Row {
                    spacing: 8
                    anchors.centerIn: recycleButton
                    Image {
                        source: "qrc:/images/material_icon.png"
                        width: 30
                        height: width
                    }
                    Text {
                        text: "+"+propCard.core.basePrice
                        font.pixelSize: 23*chestOpeningInterface.scaleFactor
                        color: recycleButton.pressed || recycleButton.hovered ? "black" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        text: "回收"
                        font.pixelSize: 23*chestOpeningInterface.scaleFactor
                        color: recycleButton.pressed || recycleButton.hovered ? "black" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                onClicked: {
                    PlayerData.materialsNumber+=propCard.core.basePrice
                    chestNotificationBar.reduceChest()
                    processedOne()
                }
            }
        }
    }
}
