import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../logic/ShopLogicHandler.js" as Controller
import "../logic/utils/color.js" as Color
import "../data/cores"
import singleton.PlayerData
import singleton.SettingsData
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Item {
    id: shopItem
    property double scaleFactor: 1.0
    property alias lockState: lockButton.isLocked
    property var itemData
    property string cionImage : "qrc:/images/material_icon.png"
    property var itemIndex
    property var wGrade

    WeaponCustomizationCore {
        id: weaponCore
    }

    function getCurPrice() {
        var basePrice
        if (itemData.type === "道具") {
            basePrice = itemData.basePrice
        } else {
            var w = Controller.getSpecificWeapon()
            basePrice = w ? w.basePrice : itemData.basePrice
        }
        return Math.ceil(basePrice * Math.pow(1.1, PlayerData.currentWaveNumber) * PlayerData.goodsDiscountRate)
    }

    function getTalentText() {
        if (itemData.type === "道具") {
            return itemData.talentText
        } else {
            var w = Controller.getSpecificWeapon()
            return w ? weaponCore.renderWeaponTalentText(w) : ""
        }
    }

    property int curPrice: getCurPrice()
    property string talentText: getTalentText()

    Rectangle {
        id: backGround
        color: itemData.type === "道具" ? Color.getBackgroundColor(itemData.grade)
                                      : Color.getBackgroundColor(wGrade)
        radius: 8*shopItem.scaleFactor
        border.color: itemData.type === "道具" ? Color.getBorderColor(itemData.grade)
                                             : Color.getBorderColor(wGrade)
        height: shopItem.height
        width: shopItem.width
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

                ScaledText {
                    id: goodsName
                    text: itemData.type === "道具" ? I18n.tr(itemData.propName, SettingsData.language) : I18n.tr(itemData.weaponName, SettingsData.language)
                    style: Text.Outline
                    color: itemData.type === "道具" ? ((itemData.grade === 1) ? "white" : Color.getBorderColor(itemData.grade))
                                                  : ((wGrade === 1) ? "white" : Color.getBorderColor(wGrade))
                    basePixelSize: 18
                    uiScale: shopItem.scaleFactor
                }

                ScaledText {
                    text: I18n.tr(itemData.type, SettingsData.language)
                    color: "#ffffc0"
                    basePixelSize: 16
                    uiScale: shopItem.scaleFactor
                }
            }


            //物品属性
            ScaledText {
                anchors.top: goodsImageBackground.bottom
                anchors.topMargin: 10*shopItem.scaleFactor
                anchors.left: goodsImageBackground.left
                text: I18n.translateRichText(talentText, SettingsData.language)
                basePixelSize: 15
                uiScale: shopItem.scaleFactor
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

                        ScaledText {
                            // text: "" + itemData.price
                            text: curPrice
                            color: PlayerData.materialsNumber < curPrice
                                   ? "red" : (buyButton.hovered ? "black" : "white")
                            basePixelSize: 22
                            uiScale: shopItem.scaleFactor
                            font.bold: true
                        }

                        Image {
                            source: cionImage
                            width: 24*shopItem.scaleFactor
                            height: 24*shopItem.scaleFactor
                        }
                    }
                }

                onReleased: {
                    if(PlayerData.materialsNumber >= curPrice) {
                        if(Controller.buyItem(itemIndex)) {
                            PlayerData.materialsNumber -= curPrice
                        }
                    }
                }

                onHoveredChanged: {
                    if(hovered) {
                        sound.playHoverSound1()
                    }
                }

                onClicked: {
                    sound.playClickSound()
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
        visible: SettingsData.lockItems

        property bool isLocked: false
        property color textColor: isLocked ? "black" : (hovered ? "black" : "white")

        contentItem: Item {
            anchors.centerIn: parent
            Row {
                anchors.centerIn: parent

                ScaledText {
                    id: lockTex
                    text: I18n.tr("锁定", SettingsData.language)
                    basePixelSize: 18
                    uiScale: shopItem.scaleFactor
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

        onClicked: {
            lockButton.isLocked = !lockButton.isLocked
            sound.playClickSound()
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
    }

    // 全局锁定关闭时，解锁所有商品
    Connections {
        target: SettingsData
        function onLockItemsChanged() {
            if (!SettingsData.lockItems) {
                lockButton.isLocked = false
            }
        }
    }
}
