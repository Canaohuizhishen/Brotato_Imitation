import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import "../data"
import singleton.PlayerData

Item {
    id: shopItem
    property double scaleFactor: 1.0
    property alias lockState: lockButton.isLocked
    property var itemData
    property string cionImage : "qrc:/images/material_icon.png"
    property var itemIndex
    property var wGrade
    // property var specificWeapon : itemData.type === "道具" ? "" : weaponCore.getWeapon(itemData.objectName, wGrade)

    //点击购买时发出的信号
    // signal buyRequested(int index)
    // signal locked(int index)

    WeaponCustomizationCore {
        id: weaponCore
    }

    Rectangle {
        id: backGround
        color: itemData.type === "道具" ? Color.getBackgroundColor(itemData.grade)
                                      : Color.getBackgroundColor(wGrade)
        radius: 8*shopItem.scaleFactor
        border.color: itemData.type === "道具" ? Color.getBorderColor(itemData.grade)
                                             : Color.getBorderColor(wGrade)
        height: shopItem.height
        width: shopItem.width
        // anchors.centerIn: shopItem
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Item {
            id: root
            anchors.fill: parent
            // anchors.top: parent
            anchors.margins: 8*shopItem.scaleFactor

            Rectangle {
                id: goodsImageBackground
                width: 63*shopItem.scaleFactor
                height: 63*shopItem.scaleFactor
                color: itemData.type === "道具" ? Color.getImageBackgroundColor(itemData.grade)
                                              : Color.getImageBackgroundColor(wGrade)
                anchors.top: parent.top
                anchors.topMargin: 3*shopItem.scaleFactor
                anchors.left: parent.left
                anchors.leftMargin: 3*shopItem.scaleFactor
                radius: 6*shopItem.scaleFactor

                Image {
                    id: goodsImage
                    source: itemData.type === "道具" ? "qrc:/images/prop-" + itemData.objectName + ".png"
                                                   : "qrc:/images/weapon-" + itemData.objectName + ".png"
                    width: 63*shopItem.scaleFactor
                    height: 63*shopItem.scaleFactor
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.left: goodsImageBackground.right
                anchors.leftMargin: 10*shopItem.scaleFactor
                anchors.top: goodsImageBackground.top

                Text {
                    id: goodsName
                    text: itemData.type === "道具" ? itemData.propName  : itemData.weaponName
                    style: Text.Outline
                    color: itemData.type === "道具" ? ((itemData.grade === 1) ? "white" : Color.getBorderColor(itemData.grade))
                                                  : ((wGrade === 1) ? "white" : Color.getBorderColor(wGrade))
                    font.pixelSize: 18*shopItem.scaleFactor
                }

                Text {
                    text: itemData.type
                    color: "#ffffc0"
                    font.pixelSize: 16*shopItem.scaleFactor
                }
            }


            //物品属性
            Text {
                anchors.top: goodsImageBackground.bottom
                anchors.topMargin: 10*shopItem.scaleFactor
                anchors.left: goodsImageBackground.left
                text: itemData.type === "道具" ? itemData.talentText
                                             : Controller.getSpecificWeapon().talentText
                font.pixelSize: 15*shopItem.scaleFactor
            }


            Button {
                id: buyButton
                anchors.horizontalCenter: root.horizontalCenter
                anchors.bottom: root.bottom
                anchors.bottomMargin: 5*shopItem.scaleFactor
                width: parent.width * 0.44
                height: width * 0.44
                hoverEnabled: true
                // enable: //需要完善 当剩余的钱币<当前商品的价格 按钮应为disable

                background: Rectangle {
                    id: buttonBg
                    radius: 10*shopItem.scaleFactor
                    color: buyButton.hovered ? "white" : (itemData.type === "道具"
                                                          ? Color.getButtonColor(itemData.grade)
                                                        : Color.getButtonColor(wGrade))
                }

                contentItem: Item {
                    anchors.fill: parent
                    Row {
                        spacing: 8*shopItem.scaleFactor
                        anchors.centerIn: parent

                        Text {
                            // text: "" + itemData.price
                            text: itemData.type === "道具"
                                  ? itemData.curPrice
                                : Controller.getSpecificWeapon().curPrice
                            // color:  //需要完善 当剩余的钱币<当前商品的价格 颜色为红色 反之为白色
                            color: ((Controller.getSpecificWeapon() && PlayerData.materialsNumber < Controller.getSpecificWeapon().curPrice)
                                    || PlayerData.materialsNumber < itemData.curPrice)
                                   ? "red" : (buyButton.hovered ? "black" : "white")
                            font.pixelSize: 22*shopItem.scaleFactor
                            font.bold: true
                        }

                        Image {
                            source: cionImage
                            width: 24*shopItem.scaleFactor
                            height: 24*shopItem.scaleFactor
                        }
                    }
                }

                transform: Scale {
                    id: buttonScale
                    origin {
                        x: buyButton.width / 2
                        y: buyButton.height / 2
                    }
                }

                onPressed: {
                    shrinkAnimation.start()

                }

                onReleased: {
                    restoreAnimation.start()
                    if(PlayerData.materialsNumber >= itemData.curPrice) {
                        // Controller.buyItem(itemIndex)

                    if(itemData.type === "道具") {
                        if(Controller.buyItem(itemIndex)) {
                            PlayerData.materialsNumber -= itemData.curPrice
                        }
                    } else {
                        if(Controller.buyItem(itemIndex)) {
                            PlayerData.materialsNumber -= Controller.getSpecificWeapon().curPrice
                        }
                    }
                        // shopItem.visible = false
                    }

                }

                PropertyAnimation {
                    id: shrinkAnimation
                    target: buttonScale
                    properties: "xScale, yScale"
                    to: 0.95
                    duration: 100
                }

                PropertyAnimation {
                    id: restoreAnimation
                    target: buttonScale
                    properties: "xScale, yScale"
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }
        }
    }

    //锁定按钮
    Button {
        id: lockButton
        width: 55*shopItem.scaleFactor
        height: 35*shopItem.scaleFactor
        anchors.top: backGround.bottom
        anchors.topMargin: 7*shopItem.scaleFactor
        anchors.horizontalCenter: backGround.horizontalCenter
        hoverEnabled: true

        property bool isLocked: false
        property color textColor: isLocked ? "black" : (hovered ? "black" : "white")

        contentItem: Item {
            // anchors.fill: parent
            anchors.centerIn: parent
            Row {
                anchors.centerIn: parent

                Text {
                    id: lockTex
                    text: qsTr("锁定")
                    font.pixelSize: 18*shopItem.scaleFactor
                    font.weight: Font.DemiBold
                    color: lockButton.isLocked ? "black" : (lockButton.hovered ? "black": "white")
                }
            }
        }

        background: Rectangle {
            id: buttonBg1
            radius: 10*shopItem.scaleFactor
            color: lockButton.isLocked ? "white" : (lockButton.hovered ? "white" : "black")
        }

        transform: Scale {
            id: buttonScale1
            origin {
                x: lockButton.width / 2
                y: lockButton.height / 2
            }
        }

        onPressed: {
            shrinkAnimation1.start()
        }

        onReleased: {
            restoreAnimation1.start()
        }

        onClicked: {
            lockButton.isLocked = !lockButton.isLocked
            // console.log("第" + itemData.index + "项锁定:", lockButton.isLocked)
        }

        PropertyAnimation {
            id: shrinkAnimation1
            target: buttonScale1
            properties: "xScale, yScale"
            to: 0.95
            duration: 100
        }

        PropertyAnimation {
            id: restoreAnimation1
            target: buttonScale1
            properties: "xScale, yScale"
            to: 1.0
            duration: 150
            easing.type: Easing.OutBack
        }

        SequentialAnimation {
            id: stateChangeAnimation1
            running: false
            PropertyAnimation {
                target: buttonScale1
                properties: "xScale, yScale"
                to: 1.1
                duration: 100
            }
            PropertyAnimation {
                target: buttonScale1
                properties: "xScale, yScale"
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }
}
