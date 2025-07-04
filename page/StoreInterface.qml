import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../data"
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import singleton.PlayerData

Item {
    id: storeInterface
    z: 150
    anchors.fill: parent
    property double scaleFactor: 1.0
    property string cionImage : "qrc:/images/material_icon.png"
    property Button startButton : startButton
    // property var shopContext: QtObject {
    //     property var _purchasedPropsModel: ListModel {}
    //     property var _duplicatePropsCountModel: ListModel {}
    //     property var _purchasedWeaponsModel: ListModel {}
    // }//实现向js文件传递模型数据

    function init()
    {
        visible = false
    }

    //重新加载整个商店界面的各个组件
    function reload() {
        Controller.initPropBar()
        Controller.initWeaponBar()
        Controller.refreshShop()
        attributeBar.upData()
        Controller.resetRefreshTimes()
        refreshButton.currentRefreshPrice = Controller.refreshPrice(PlayerData.currentWaveNumber)
    }

    onVisibleChanged: {
        if (visible) {
               reload()
           }
    }

    //主背景
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#353535"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#555555" }
            GradientStop { position: 0.5; color: "#353535" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }
    }

    //商店+波数+货币数量+刷新
    Item {
        id: topBar
        anchors.top: parent.top
        width: parent.width * 0.77
        height: 50*storeInterface.scaleFactor

        Text {
            id: shopTitle
            text: qsTr("商店(第") + PlayerData.currentWaveNumber + qsTr("波)")
            color: "white"
            font.pixelSize: 30*storeInterface.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 28*storeInterface.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 15*storeInterface.scaleFactor
        }

        //货币数量
        Rectangle {
            id: currencyRow

            anchors.left: shopTitle.right
            anchors.leftMargin: (parent.width - 30*storeInterface.scaleFactor - shopTitle.width - refreshButton.width) / 2 - 30*storeInterface.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 30*storeInterface.scaleFactor

            Image {
                id: coinimage
                width: 30*storeInterface.scaleFactor
                height: 30*storeInterface.scaleFactor
                source: cionImage
                // anchors.top: parent.top
                // anchors.topMargin: 1*storeInterface.scaleFactor
            }

            Text {
                anchors.left: coinimage.right
                anchors.leftMargin: 3*storeInterface.scaleFactor
                text: PlayerData.materialsNumber
                font.pixelSize: 24*storeInterface.scaleFactor
                color: "white"
                font.weight: 650
            }
        }

        Button {
            id: refreshButton
            width: 170*storeInterface.scaleFactor
            height: 55*storeInterface.scaleFactor

            property bool isHovered: false
            property int currentRefreshPrice: Controller.refreshPrice(PlayerData.currentWaveNumber)

            anchors.top: parent.top
            anchors.topMargin: 17*storeInterface.scaleFactor
            anchors.right: parent.right
            anchors.rightMargin: 9*storeInterface.scaleFactor

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
                currentRefreshPrice = Controller.refreshPrice(PlayerData.currentWaveNumber)
                // }
            }

            contentItem: Item {
                anchors.fill: parent

                Row {
                    anchors.centerIn: parent
                    spacing: 5*storeInterface.scaleFactor
                    Text {
                        id: refreshText
                        // text: qsTr("刷新") + Controller.refreshPrice(waveNumberText.text)
                        text: "刷新-" + refreshButton.currentRefreshPrice
                        font.pixelSize: 24*storeInterface.scaleFactor
                        color: PlayerData.materialsNumber >= refreshButton.currentRefreshPrice
                               ? (refreshButton.isHovered ? "black" : "white")
                               : "red"
                    }

                    Image {
                        source: cionImage
                        width: 30*storeInterface.scaleFactor
                        height: 30*storeInterface.scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            background: Rectangle {
                id: buttonBg
                radius: 10*storeInterface.scaleFactor
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
            anchors.top: parent.top
            anchors.topMargin: 55*storeInterface.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 15*storeInterface.scaleFactor
            property int columns : 4
            property int cellW: 235*storeInterface.scaleFactor
            property int cellH: 315*storeInterface.scaleFactor
            width:  4 * (cellW + 8)*storeInterface.scaleFactor
            height: cellH + 45*storeInterface.scaleFactor
            cellWidth: cellW + 7*storeInterface.scaleFactor
            cellHeight: cellH
            interactive: false
            flickableDirection: Flickable.AutoFlickDirection
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            flow: GridView.FlowLeftToRight
            model: shopModel
            delegate: GoodsCard {
                id: card
                scaleFactor: storeInterface.scaleFactor
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
            radius: 8*storeInterface.scaleFactor
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
        anchors.bottom: storeInterface.bottom
        anchors.bottomMargin: 185*storeInterface.scaleFactor
        anchors.left: topBar.left
        // anchors.leftMargin: 15*storeInterface.scaleFactor
        anchors.right: topBar.right
        // anchors.rightMargin: 15*storeInterface.scaleFactor

        //道具栏
        PurchasedPropsBar {
            scaleFactor: storeInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15*storeInterface.scaleFactor
            purchasedPropsModel: PlayerData.shopContext._purchasedPropsModel
            duplicatePropsCountModel: PlayerData.shopContext._duplicatePropsCountModel

        }

        //武器栏
        PurchasedWeaponsBar {
            scaleFactor: storeInterface.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 215*storeInterface.scaleFactor
            purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel

        }
    }

    //最右边的一栏 属性面板 + 出发按钮
    Item {
        id: rightPanel
        anchors.top: storeInterface.top
        anchors.left: topBar.right
        anchors.right: storeInterface.right
        anchors.bottom: storeInterface.bottom

        AttributePanel {
            id: attributeBar
            scaleFactor: storeInterface.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 15*storeInterface.scaleFactor
            anchors.right: parent.right
            anchors.rightMargin: 15*storeInterface.scaleFactor
        }

        Button {
            id: startButton
            height: 50*storeInterface.scaleFactor
            width: attributeBar.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20*storeInterface.scaleFactor
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
                Controller.setPlayerProps(PlayerData)
                Controller.setPlayerWeapons(PlayerData)
                // Controller.startNextWave()
                storeInterface.visible = false
                waveCountdown.start()
            }

            property bool isHovered: false

            background: Rectangle {
                radius: 10*storeInterface.scaleFactor
                color: startButton.isHovered ? "white" : "black"
            }

            contentItem: Item {
                anchors.fill: parent

                Text {
                    anchors.centerIn: parent
                    text: "出发(第" + (PlayerData.currentWaveNumber + 1) + "波)"
                    color: startButton.isHovered ? "black" : "white"
                    font.pixelSize: 32*storeInterface.scaleFactor
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



