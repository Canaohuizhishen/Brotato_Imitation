import QtQuick
import QtQuick.Controls
import"../components"
import singleton.PlayerData
import "../logic/ShopLogicHandler.js" as Controller

Rectangle {
    id: root
    anchors.fill: parent
    color: Qt.rgba(0,0,0,0.85)
    visible: true
    focus: true
    z: 400
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



    Row {
        id: pause
        anchors.centerIn: root
        spacing: 80*root.scaleFactor

        Column {
            id:set
            anchors.verticalCenter: parent.verticalCenter
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
        }

        Column {
            width: Math.max(weaponBar.width,propBar.width)
            height: weaponBar.height+spacing+propBar.height
            anchors.top: parent.top
            anchors.topMargin: 50*root.scaleFactor
            spacing: 30*root.scaleFactor

            //武器栏
            WeaponsBar {
                id: weaponBar
                columns: 6
                scaleFactor: root.scaleFactor
                showButton: false
                inUp: false
                inLeft: false
            }

            //道具栏
            PropsBar {
                id: propBar
                scaleFactor: root.scaleFactor
                columns: 6
                inUp: true
                inLeft: false
            }
        }

        AttributePanel{
            id: attributePanel
            inLeft: true
            scaleFactor: root.scaleFactor
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
