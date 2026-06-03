import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import "../components"
import "../logic/ShopLogicHandler.js" as Controller
import "../data"

Item {
    id: chestOpeningInterface
    property ChestNotificationBar chestNotificationBar //数据来源
    property double scaleFactor: 1.0
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100

    property alias getButton: getButton
    property alias recycleButton: recycleButton
    signal processedOne()

    function init(){
        visible=false
    }

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
        spacing: 170*chestOpeningInterface.scaleFactor

        AttributePanel{
            id: attributePanel
            scale: 1.2
            scaleFactor: chestOpeningInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
            inLeft: false
        }

        PropCard{
            id: propCard
            propName: chestNotificationBar.number ? chestNotificationBar.chests.get(0).propName : ""
            scaleFactor: chestOpeningInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
        }

        Column{
            spacing: 50*chestOpeningInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter

            Button{
                id: getButton
                text: "拿取"
                width: 230*chestOpeningInterface.scaleFactor
                height: width/4
                background: Rectangle {
                    color: getButton.pressed || getButton.hovered ? "white" : "black"
                    radius: 4*chestOpeningInterface.scaleFactor
                }
                contentItem: Text {
                    text: getButton.text
                    font.pixelSize: 23*chestOpeningInterface.scaleFactor
                    color: getButton.pressed || getButton.hovered ? "black" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // PlayerData.addProp(propCard.propName)
                    Controller.mergeDuplicateProps(propCard.propName)
                    // console.log(propCard.propName)
                    propCard.propCore.applyEffects(propCard.core.effects)
                    attributePanel.upData()
                    chestNotificationBar.reduceChest()
                    processedOne()
                    sound.playClickSound()
                }
                onHoveredChanged: {
                    if(hovered) {
                        sound.playHoverSound1()
                    }
                }
            }

            Button{
                id: recycleButton
                width: getButton.width
                height: width/4
                background: Rectangle {
                    color: recycleButton.pressed || recycleButton.hovered ? "white" : "black"
                    radius: 4*chestOpeningInterface.scaleFactor
                }
                Row {
                    spacing: 8*chestOpeningInterface.scaleFactor
                    anchors.centerIn: recycleButton
                    Image {
                        source: "qrc:/images/material_icon.png"
                        width: 30*chestOpeningInterface.scaleFactor
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
                    sound.playClickSound()
                }

                onHoveredChanged: {
                    if(hovered) {
                        sound.playHoverSound1()
                    }
                }
            }
        }
    }
}
