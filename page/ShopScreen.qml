import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../data"
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import singleton.PlayerData

Item {
    id: shopscreen

    property string cionImage : "qrc:/images/material_icon.png"
    property var shopContext: QtObject {
        property var _purchasedPropsModel
        property var _duplicatePropsCountModel
        property var _purchasedWeaponsModel
    } //实现向js文件传递模型数据


    //主背景
    Rectangle {
        anchors.fill: parent
        color: "#333333"
    }

    //商店+波数+货币数量+刷新
    Item {
        id: topBar
        anchors.top: parent.top
        width: parent.width * 0.77
        height: 50

        Text {
            id: shopTitle
            text: qsTr("商店(第") + waveNumberText.text + qsTr("波)")
            color: "white"
            font.pixelSize: 30
            anchors.top: parent.top
            anchors.topMargin: 28
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        //货币数量
        Rectangle {
            id: currencyRow

            anchors.left: shopTitle.right
            anchors.leftMargin: (parent.width - 30 - shopTitle.width - refreshButton.width) / 2 - 30
            anchors.top: parent.top
            anchors.topMargin: 30

            Image {
                id: coinimage
                width: 30
                height: 30
                source: cionImage
                // anchors.top: parent.top
                // anchors.topMargin: 1
            }

            Text {
                anchors.left: coinimage.right
                anchors.leftMargin: 3
                text: PlayerData.materialsNumber
                font.pixelSize: 24
                color: "white"
                font.weight: 650
            }
        }

        Button {
            id: refreshButton
            width: 170
            height: 55

            property bool isHovered: false
            property int currentRefreshPrice: Controller.refreshPrice(waveNumberText.text)

            anchors.top: parent.top
            anchors.topMargin: 17
            anchors.right: parent.right
            anchors.rightMargin: 9

            hoverEnabled: true

            onHoveredChanged: {
                isHovered = hovered
            }

            onPressedChanged: {
                if (pressed) {
                    shrinkAnimation.start()
                } else {
                    restoreAnimation.start()
                }
            }

            onClicked: {
                // if(PlayerData.materialsNumber >= refreshButton.currentRefreshPrice) {
                Controller.refreshShop()
                PlayerData.materialsNumber -= currentRefreshPrice
                currentRefreshPrice = Controller.refreshPrice(waveNumberText.text)
                // }
            }

            contentItem: Item {
                anchors.fill: parent

                Row {
                    anchors.centerIn: parent
                    spacing: 5
                    Text {
                        id: refreshText
                        // text: qsTr("刷新") + Controller.refreshPrice(waveNumberText.text)
                        text: "刷新-" + refreshButton.currentRefreshPrice
                        font.pixelSize: 24
                        color: PlayerData.materialsNumber >= refreshButton.currentRefreshPrice
                                ? (refreshButton.isHovered ? "black" : "white")
                                : "red"
                    }

                    Image {
                        source: cionImage
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            background: Rectangle {
                id: buttonBg
                radius: 10
                color: refreshButton.isHovered ? "white" : "black"
            }

            transform: Scale {
                id: buttonScale
                origin {
                    x: refreshButton.width / 2
                    y: refreshButton.height / 2
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

            // enabled: 需要完善判断：剩余的货币数>=本次刷新所需的货币数
        }
    }

    // 商品列表
    Item {
        id: shopArea
        anchors.top: topBar.bottom
        // anchors.topMargin: 30
        anchors.left: topBar.left

        ListModel {
            id: shopModel
        }

        GridView {
            id: shopView

            property int columns : 4
            property int cellW: 235
            property int cellH: 315

            anchors.top: parent.top
            anchors.topMargin: 55
            anchors.left: parent.left
            anchors.leftMargin: 15


            width:  4 * (cellW + 8)
            height: cellH + 45
            cellWidth: cellW + 7
            cellHeight: cellH

            interactive: false
            flickableDirection: Flickable.AutoFlickDirection
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            flow: GridView.FlowLeftToRight

            model: shopModel

            delegate: GoodsCard {
                id: card

                Component.onCompleted: {
                    card.lockState = isLockedModel
                }

                onLockStateChanged: {
                    if (index >= 0 && index < shopModel.count) {
                        shopModel.setProperty(index, "isLockedModel", lockState)

                    }
                }
                itemData: goods
                itemIndex: index
                wGrade: weaponGrade
                visible: index < shopView.columns


                width: shopView.cellW
                height: shopView.cellH
            }
        }

        // 网格背景
        Rectangle {
            anchors.fill: parent
            color: "#222222"
            radius: 8
            z: -1
        }

        PropCustomizationCore {
            id: propCore
        }

        WeaponCustomizationCore {
            id: weaponCore
        }

        Component.onCompleted: {
            Controller.refreshShop()
        }
    }

    //道具和武器栏
    Item {
        anchors.bottom: shopscreen.bottom
        anchors.bottomMargin: 185
        anchors.left: topBar.left
        // anchors.leftMargin: 15
        anchors.right: topBar.right
        // anchors.rightMargin: 15

        //道具栏
        PurchasedPropsBar {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15
        }


        //武器栏
        PurchasedWeaponsBar {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 215
        }
    }

    //最右边的一栏 属性面板 + 出发按钮
    Item {
        id: rightPanel
        anchors.top: shopscreen.top
        anchors.left: topBar.right
        anchors.right: shopscreen.right
        anchors.bottom: shopscreen.bottom

        AttributePanel {
            id: attributeBar
            anchors.top: parent.top
            anchors.topMargin: 15
            // anchors.left: parent.left
            // anchors.leftMargin: 6
            anchors.right: parent.right
            anchors.rightMargin: 15
            // height: parent.height * 0.7
        }

        Button {
            id: startButton
            height: 50
            width: attributeBar.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            hoverEnabled: true

            onHoveredChanged: {
                isHovered = hovered
            }

            onPressedChanged: {
                if (pressed) {
                    startButtonHhrinkAnimation.start()
                } else {
                    startButtonRestoreAnimation.start()
                }
            }

            onClicked: {
                Controller.startNextWave()
            }

            property bool isHovered: false

            background: Rectangle {
                radius: 10
                color: startButton.isHovered ? "white" : "black"
            }

            contentItem: Item {
                anchors.fill: parent

                Text {
                    anchors.centerIn: parent
                    text: qsTr("出发(第%1波)") //需要完善下一波的计数
                    color: startButton.isHovered ? "black" : "white"
                    font.pixelSize: 32
                    font.bold: true
                }
            }

            transform: Scale {
                id: startButtonButtonScale
                origin {
                    x: startButton.width / 2
                    y: startButton.height / 2
                }
            }

            PropertyAnimation {
                id: startButtonHhrinkAnimation
                target: startButtonButtonScale
                properties: "xScale, yScale"
                to: 0.95
                duration: 100
            }

            PropertyAnimation {
                id: startButtonRestoreAnimation
                target: startButtonButtonScale
                properties: "xScale, yScale"
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }
}



