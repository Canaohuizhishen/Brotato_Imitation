import QtQuick
import QtQuick.Controls
import"../components"
import singleton.PlayerData
import "../logic/ShopLogicHandler.js" as Controller

Rectangle {
    id: root
    anchors.fill: parent
    color: Qt.rgba(0,0,0,0.7)
    visible: true
    focus: true
    z: 200
    property double scaleFactor: 1.0
    property alias continueButton: continueButton
    property alias restartButton: restartButton
    property alias settingButton: settingButton
    property alias backMainMenuButton: backMainMenuButton

    property bool inMain: true

    //拦截点击事件，防止点击穿透
    TapHandler{
        onTapped: {}
    }

    //拦截悬停事件，防止悬停穿透
    HoverHandler {
        onHoveredChanged: {}
    }

    Item {
        id: pause
        anchors.fill: parent

        Column {
            id:set
            anchors.left: parent.left
            anchors.leftMargin: 100*root.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 260*root.scaleFactor
            width: 380*root.scaleFactor
            height: 230*root.scaleFactor
            spacing: 10*root.scaleFactor

            SetButton {
                id:continueButton
                text: "继续"
                width: parent.width
                height: width/8
                onClicked: {
                }
            }
            SetButton {
                text: "重新开始"
                width: parent.width
                height: width/8
                onClicked: {
                    root.inMain=false
                    pause.visible = false
                    restartMenu.visible = true
                    restartMenu.forceActiveFocus()
                }
            }
            SetButton {
                id: settingButton
                text: "设置"
                width: parent.width
                height: width/8
            }
            SetButton {
                text: "返回主菜单"
                width: parent.width
                height: width/8
                onClicked: {
                    root.inMain=false
                    pause.visible = false
                    backMenu.visible = true
                    backMenu.forceActiveFocus()
                }
            }
            SetButton {
                text: "测试濒死"
                width: parent.width
                height: width/8
                onClicked: {
                    PlayerData.curHp = 1
                }
            }
        }

        Item {
            anchors.left:set.right
            anchors.leftMargin: 80*root.scaleFactor
            height: 230*root.scaleFactor
            anchors.right:attributePanel.left
            anchors.top: parent.top
            anchors.topMargin: 50*root.scaleFactor
            //武器栏
            PurchasedWeaponsBar {
                id:weapon
                anchors.verticalCenter: parent.verticalCenter
                scaleFactor: root.scaleFactor
                purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel

            }

            //道具栏
            PurchasedPropsBar {
                anchors.top: weapon.bottom
                anchors.topMargin: 200*root.scaleFactor
                scaleFactor: root.scaleFactor
                purchasedPropsModel: PlayerData.shopContext._purchasedPropsModel
                duplicatePropsCountModel: PlayerData.shopContext._duplicatePropsCountModel
                columns: 5
                Component.onCompleted: {
                    //console.log("暂停界面道具栏 - 列数:", columns)
                    // 强制更新布局
                    updateLayout()
                }
            }
        }

        AttributePanel{
            id: attributePanel
            inLeft: true
            scaleFactor: root.scaleFactor
            anchors.right: parent.right
            anchors.rightMargin: 100*root.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: backMenu
        width: 380*root.scaleFactor
        height: 200*root.scaleFactor
        visible: false
        focus: true
        anchors.centerIn: parent

        Keys.onEscapePressed: {
            backMenu.visible = false
            pause.visible = true
            root.inMain=true
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20*root.scaleFactor
            spacing: 15*root.scaleFactor

            Text {
                text: "是否返回主菜单?"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 30*root.scaleFactor
            }

            SetButton {
                id:backMainMenuButton
                text: "是"
                width: parent.width
                height: width/8
                onClicked: {
                    backMenu.visible = false
                    pause.visible = true
                    root.inMain=true
                }
            }

            SetButton {
                text: "否"
                width: parent.width
                height: width/8
                onClicked: {
                    backMenu.visible = false
                    pause.visible = true
                    root.inMain=true
                }
            }
        }
    }

    Item {
        id: restartMenu
        width: 380*root.scaleFactor
        height: 200*root.scaleFactor
        visible: false
        focus: true
        anchors.centerIn: parent

        Keys.onEscapePressed: {
            restartMenu.visible = false
            pause.visible = true
            root.inMain=true
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20*root.scaleFactor
            spacing: 15

            Text {
                text: "是否重新开始本轮游戏?"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 30*root.scaleFactor
            }

            SetButton {
                id: restartButton
                text: "是"
                width: parent.width
                height: width/8
                onClicked: {
                    restartMenu.visible = false
                    pause.visible = true
                    root.inMain=true
                }
            }

            SetButton {
                text: "否"
                width: parent.width
                height: width/8
                onClicked: {
                    restartMenu.visible = false
                    pause.visible = true
                    root.inMain=true
                }
            }
        }
    }

    function init(){
        visible=false
        attributePanel.upData()
    }
}
