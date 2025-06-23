import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import singleton.PlayerData

Item {
    id:shopItem

    property alias lockState: lockButton.isLocked
    property var itemData
    property string cionImage : "qrc:/images/material_icon.png"
    property var itemIndex

    //点击购买时发出的信号
    signal buyRequested(int index)
    signal locked(int index)

    // function getOptionColor(grade){
    //     switch(grade){
    //     case 1: return "#000000"
    //     case 2: return "#1E90FF"
    //     case 3: return "#BA55D3"
    //     case 4: return "#FF0000"
    //     default: console.log("不正确的等级: ",grade)
    //     }
    // }

    Rectangle {
        id: backGround
        color: Color.getBackgroundColor(itemData.grade)
        radius: 8
        border.color: Color.getOptionColor(itemData.grade)
        height: shopItem.height
        width: shopItem.width
        // anchors.centerIn: shopItem
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Item {
            id: root
            anchors.fill: parent
            // anchors.top: parent
            anchors.margins: 8

            Rectangle {
                id: goodsImageBackground
                width: 63
                height: 63
                color: Color.getImageBackgroundColor(itemData.grade)
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.left: parent.left
                anchors.leftMargin: 3
                radius: 6

                Image {
                    id: goodsImage
                    source: "/images/prop-" + itemData.objectName + ".png"
                    width: 63
                    height: 63
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.left: goodsImageBackground.right
                anchors.leftMargin: 5
                // anchors.top: parent.top
                // anchors.topMargin: 5
                anchors.top: goodsImageBackground.top

                Text {
                    id: goodsName
                    text: itemData.propName
                    color: "white"
                    font.pixelSize: 18
                }

                Text {
                    text: itemData.type
                    color: "gold"
                    font.pixelSize: 14
                }
            }

            //物品属性
            Text {
                anchors.top: goodsImageBackground.bottom
                anchors.topMargin: 5
                anchors.left: goodsImageBackground.left
                text: itemData.talentText
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }


            Button {
                id: buyButton
                anchors.horizontalCenter: root.horizontalCenter
                anchors.bottom: root.bottom
                anchors.bottomMargin: 5
                width: parent.width * 0.44
                height: width * 0.44
                hoverEnabled: true
                // enable: //需要完善 当剩余的钱币<当前商品的价格 按钮应为disable

                background: Rectangle {
                    id: buttonBg
                    radius: 10
                    color: buyButton.hovered ? "white" : Color.getButtonColor(itemData.grade)
                }

                contentItem: Item {
                    anchors.fill: parent
                    Row {
                        spacing: 8
                        anchors.centerIn: parent

                        Text {
                            // text: "" + itemData.price
                            text: "123"
                            // color:  //需要完善 当剩余的钱币<当前商品的价格 颜色为红色 反之为白色
                            color: buyButton.hovered ? "black" : "white"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Image {
                            source: cionImage
                            width: 24
                            height: 24
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
                    Controller.buyItem(itemIndex)
                    Controller.purchaseDeduction(itemIndex)
                    // console.log("buy ", itemIndex, "item")
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
        width: 67
        height: 35
        anchors.top: backGround.bottom
        anchors.topMargin: 7
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
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: lockButton.isLocked ? "black" : (lockButton.hovered ? "black": "white")
                }
            }
        }

        background: Rectangle {
            id: buttonBg1
            radius: 10
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
