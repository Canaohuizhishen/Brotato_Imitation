import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../data"
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import singleton.PlayerData
import singleton.SettingsData
import "../data/i18n.js" as I18n

Item {
    id: storeInterface
    z: 150
    anchors.fill: parent
    property double scaleFactor: 1.0
    property string cionImage : "qrc:/images/material_icon.png"
    property Button startButton : startButton
    property bool isContinue: false

    function init()
    {
        visible = false
    }

    function hideComponents(){
        topBar.visible=false
        shopView.visible=false
        bars.visible=false
        rightPanel.visible=false
    }

    function unhideComponents(){
        topBar.visible=true
        shopView.visible=true
        bars.visible=true
        rightPanel.visible=true
    }

    //重新加载整个商店界面的各个组件
    function reload() {
        Controller.refreshShop()
        attributeBar.upData()
        Controller.resetRefreshTimes()
        refreshButton.currentRefreshPrice = Controller.refreshPrice(PlayerData.currentWaveNumber)
    }

    onVisibleChanged: {
        if(isContinue) {
            isContinue = false
            reload()
        } else if(visible) {
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

    PropCustomizationCore {
        id: propCore
    }

    WeaponCustomizationCore {
        id: weaponCore
    }

    //商店+波数+货币数量+刷新
    Item {
        id: topBar
        width: shopView.width-shopView.spacing
        height: refreshButton.height
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: shopView.left

        ScaledText {
            id: shopTitle
            text: I18n.tr("商店(", SettingsData.language) + PlayerData.currentWaveNumber + I18n.tr("波)", SettingsData.language)
            color: "white"
            basePixelSize: 30
            uiScale: storeInterface.scaleFactor
            anchors.left: topBar.left
            anchors.verticalCenter: topBar.verticalCenter
        }

        //货币数量
        MaterialsBar{
            id: materialsBar
            scaleFactor: storeInterface.scaleFactor
            height: 30*storeInterface.scaleFactor
            number: PlayerData.materialsNumber
            anchors.centerIn: topBar
        }

        Button {
            id: refreshButton
            width: 170*storeInterface.scaleFactor
            height: 55*storeInterface.scaleFactor
            property bool isHovered: false
            property int currentRefreshPrice: Controller.refreshPrice(PlayerData.currentWaveNumber)
            hoverEnabled: true
            anchors.right: topBar.right
            anchors.verticalCenter: topBar.verticalCenter
            contentItem: Item {
                anchors.fill: parent

                Row {
                    anchors.centerIn: parent
                    spacing: 5*storeInterface.scaleFactor
                    ScaledText {
                        id: refreshText
                        // text: qsTr("刷新") + Controller.refreshPrice(waveNumberText.text)
                        text: I18n.tr("刷新-", SettingsData.language) + refreshButton.currentRefreshPrice
                        basePixelSize: 24
                        uiScale: storeInterface.scaleFactor
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

            onHoveredChanged: {
                isHovered = hovered
                if(hovered) {
                    sound.playHoverSound1()
                }
            }

            onClicked: {
                if(PlayerData.materialsNumber >= refreshButton.currentRefreshPrice) {
                    Controller.refreshShop()
                    PlayerData.materialsNumber -= currentRefreshPrice
                    currentRefreshPrice = Controller.refreshPrice(PlayerData.currentWaveNumber)
                    sound.playClickSound()
                }
            }
        }
    }

    // 商品列表
    GridView {
        id: shopView
        anchors.top: storeInterface.top
        anchors.topMargin: 105*storeInterface.scaleFactor
        anchors.left: storeInterface.left
        anchors.leftMargin: 20*storeInterface.scaleFactor
        property int columns : 4
        property int cellW: 235*storeInterface.scaleFactor
        property int cellH: 320*storeInterface.scaleFactor
        property int spacing: 8*storeInterface.scaleFactor
        width:  4*(cellW+spacing)
        height: cellH + 45*storeInterface.scaleFactor
        cellWidth: cellW + spacing
        cellHeight: cellH
        interactive: false
        flickableDirection: Flickable.AutoFlickDirection
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        flow: GridView.FlowLeftToRight
        model: ListModel {
            id: shopModel
        }
        delegate: GoodsCard {
            id: card
            scaleFactor: storeInterface.scaleFactor
            Component.onCompleted: {
                card.lockState = isLockedModel
            }
            onLockStateChanged: {
                if (index >= 0 && index < shopModel.count) {
                    shopModel.setProperty(index, "isLockedModel", lockState)
                    PlayerData.lastStoreGoods.setProperty(index, "isLockedModel", lockState)
                }
            }
            itemData: goods
            itemIndex: index
            wGrade: weaponGrade
            // visible: index < shopView.columns
            visible: !isPurchased
            width: shopView.cellW
            height: shopView.cellH
        }
    }

    //道具和武器栏
    Item {
        id: bars
        width: shopView.width-shopView.spacing
        anchors.top: shopView.bottom
        anchors.topMargin: 40*storeInterface.scaleFactor
        anchors.left: shopView.left

        //道具栏
        PropsBar {
            scaleFactor: storeInterface.scaleFactor
            anchors.left: parent.left
            // purchasedPropsModel: PlayerData.shopContext._purchasedPropsModel
            // duplicatePropsCountModel: PlayerData.shopContext._duplicatePropsCountModel
            inUp: true
            inLeft: false
        }

        //武器栏
        WeaponsBar {
            scaleFactor: storeInterface.scaleFactor
            anchors.right: parent.right
            // purchasedWeaponsModel: PlayerData.shopContext._purchasedWeaponsModel
            inUp: true
            inLeft: true
        }
    }

    //最右边的一栏 属性面板 + 出发按钮
    Item {
        id: rightPanel
        width: attributeBar.width
        anchors.top: storeInterface.top
        anchors.topMargin: 20*storeInterface.scaleFactor
        anchors.bottom: storeInterface.bottom
        anchors.bottomMargin: 20*storeInterface.scaleFactor
        anchors.right: storeInterface.right
        anchors.rightMargin: 15*storeInterface.scaleFactor

        AttributePanel {
            id: attributeBar
            width: 270*storeInterface.scaleFactor
            scaleFactor: storeInterface.scaleFactor
            autoChangeHight: true
            anchors.top: parent.top
        }

        Button {
            id: startButton
            height: 50*storeInterface.scaleFactor
            width: attributeBar.width
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            hoverEnabled: true

            onHoveredChanged: {
                isHovered = hovered
                if(hovered) {
                    sound.playHoverSound1()
                }
            }

            onClicked: {
                sound.playClickSound()
            }

            property bool isHovered: false

            background: Rectangle {
                radius: 10*storeInterface.scaleFactor
                color: startButton.isHovered ? "white" : "black"
            }

            contentItem: Item {
                anchors.fill: parent

                ScaledText {
                    anchors.centerIn: parent
                    text: I18n.tr("出发(第", SettingsData.language) + PlayerData.currentWaveNumber + I18n.tr("波)", SettingsData.language)
                    color: startButton.isHovered ? "black" : "white"
                    basePixelSize: 32
                    uiScale: storeInterface.scaleFactor
                    font.bold: true
                }
            }
        }
    }
}



