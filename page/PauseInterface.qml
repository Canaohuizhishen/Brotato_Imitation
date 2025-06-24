import QtQuick
import QtQuick.Controls
import"../components"

Rectangle {
    width: 1280
    height: 720
    color: Qt.rgba(0,0,0,0.7)
    visible: true
    focus: true
    // Keys.onPressed: {
    //     if (event.key === Qt.Key_Escape) {
    //         pause.visible = !pause.visible  // 切换暂停界面显示状态
    //         event.accepted = true  // 阻止事件继续传递
    //     }
    // }
    property alias backMainMenuButton: backMainMenuButton
    property alias continueButton: continueButton
    property alias restartButton: restartButton
    property alias settingButton: settingButton


    Item {
        anchors.left: parent.left
        anchors.leftMargin: 100
        id:pause
        width: 300
        height: 200
        y: 260

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            SetButton {
                id:continueButton
                text: "继续"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                }
            }
            SetButton {
                id:restartButton
                text: "重新开始"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: console.log("重新开始按钮被点击")
            }

            SetButton {
                id:settingButton
               text: "设置"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    // settingsPopup.visible = true
                    // pause.visible = false
                    console.log("设置按钮被点击")
                }
            }
            SetButton {
                text: "返回主菜单"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pause.visible = false
                    backmenu.visible = true
                    console.log("返回主菜单按钮被点击")
                }
            }
        }
    }

    Item {
        id: backmenu
        width: 300
        height: 200
        visible: false
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "是否返回主菜单?"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 30
            }

            SetButton {
                id:backMainMenuButton
                text: "是"
                width: parent.width
                onClicked: {
                    // backmenu.visible = true
                    // console.log("游戏操作被点击")

                }
            }

            SetButton {
                text: "否"
                width: parent.width
                onClicked: {
                    backmenu.visible = false
                    pause.visible = true
                    console.log("游戏操作被点击")
                }
            }
        }
    }
    AttributePanel{
        id: attributePanel
        inLeft: true
        scaleFactor: chestOpeningInterface.scaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.verticalCenter: parent.verticalCenter
    }

}
