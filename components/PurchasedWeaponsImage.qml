import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color
import "../data"
import singleton.PlayerData

Item {
    id: root

    property var itemData
    property int wIndex
    property int wGrade
    property bool popupActive: false
    // property var specificWeapon : itemData.type === "道具" ? "" : weaponCore.getWeapon(itemData.objectName, wGrade)

    WeaponCustomizationCore {
        id: weaponCore
    }

    Rectangle {
        id: weaponImageBackground
        width: parent.width
        height: parent.height
        radius: 6
        color: weaponImageBackground.hovered ? "white" : Color.getImageBackgroundColor(wGrade)

        property bool hovered: false

        Image {
            id: weaponImage
            source: "qrc:/images/weapon-" + itemData.objectName + ".png"
            // source: "qrc:/images/prop-" + itemData.objectName + ".png"
            // source: "qrc:/images/smg_icon.png"
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
        }

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
            onHoveredChanged: {
                weaponImageBackground.hovered = hovered
                if (popupActive) return
                if (hovered) {
                    infoPopup.open()
                } else {
                    infoPopup.close()
                }
            }
        }

        TapHandler {
            onTapped: {
                popupActive = true
                infoPopup.modal = true
                infoPopup.open()
            }
        }
    }

    Popup {
        id: infoPopup

        modal: false
        closePolicy: Popup.NoAutoClose

        width: 220
        implicitHeight: contentLayout.implicitHeight + 30
        x: weaponImageBackground.mapToItem(root,
                                           weaponImageBackground.width - width,
                                           -contentLayout.implicitHeight - 35).x
        y: weaponImageBackground.mapToItem(root,
                                           weaponImageBackground.width - width,
                                           -contentLayout.implicitHeight - 35).y

        Overlay.modal: Rectangle {
            color: popupActive ? "#80000000" : "transparent"
            visible: popupActive
        }


        onClosed: {
            popupActive = false
            modal = false
            weaponImageBackground.hovered = false
        }

        background: Rectangle {
            anchors.fill: parent
            color: Color.getBackgroundColor(wGrade)
            radius: 5
            border.color: Color.getBorderColor(wGrade)
        }

        contentItem: ColumnLayout {
            id: contentLayout
            width: parent.width

            RowLayout {
                // Layout.preferredWidth: 150

                Rectangle {
                    id: background
                    color: Color.getImageBackgroundColor(wGrade)
                    radius: 6
                    Layout.minimumWidth: 63
                    Layout.minimumHeight: 63
                    Layout.leftMargin: 8
                    Layout.topMargin: 8
                    // border.color: Color.getBorderColor()

                    Image {
                        id: image
                        source: "qrc:/images/weapon-" + itemData.objectName + ".png"
                        // source: "qrc:/images/prop-" + itemData.objectName + ".png"
                        width: 63
                        height: 63
                        fillMode: Image.PreserveAspectFit
                        // anchors.centerIn: parent
                        anchors.fill: parent
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 8
                    spacing: 1

                    Text {
                        id: text
                        // text: itemData.weaponName
                        text: itemData.weaponName
                        color: "white"
                        font.pixelSize: 18
                    }

                    Text {
                        text: itemData.type
                        color: "gold"
                        font.pixelSize: 14
                    }
                }
            }

            Text {
                //不直接使用text: Controller.getSpecificWeapon().talentText是因为防止循环绑定报错
                property var specificWeapon: {
                    if (itemData && itemData.type !== "道具") {
                        return weaponCore.getWeapon(itemData.objectName, wGrade)
                    }
                    return null
                }
                // text: Controller.getSpecificWeapon().talentText
                text: specificWeapon ? specificWeapon.talentText : ""
                font.pixelSize: 12
                font.weight: Font.DemiBold

                Layout.topMargin: 5
                Layout.leftMargin: 8
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 10
                Layout.bottomMargin: 8
                columns: 1
                rowSpacing: 5

                // 合成按钮
                Button {
                    id: compositeButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    visible: Controller.isCompositeVisible(wIndex) //有能够与其合成的武器时可见，否则不可见

                    property bool isHovered: false

                    HoverHandler {
                        onHoveredChanged: compositeButton.isHovered = hovered
                    }

                    onClicked: {
                        infoPopup.close()
                        Controller.compositeWeapon(wIndex)
                    }

                    contentItem: Text {
                        text: "合成"
                        font.pixelSize: 18
                        color: compositeButton.isHovered ? "#444444" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }

                    background: Rectangle {
                        radius: 10
                        color: compositeButton.isHovered ? "white" : Color.getButtonColor(wGrade)
                    }
                }

                // 回收按钮
                Button {
                    id: recycleButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    property bool isHovered: false
                    property int recycleValue: 0

                    //这样做的原因是：如果直接使用text: "回收(+" + Controller.recycledPrice(wIndex,wGrade) + ")" 会导致循环绑定的报错
                    //当弹出框打开时更新回收值
                    Connections {
                        target: infoPopup
                        function onOpened() {
                            recycleButton.updateRecycleValue()
                        }
                    }

                    function updateRecycleValue() {
                        recycleValue = Controller.recycledPrice(wIndex, wGrade) || 0 //或0是因为：recycledPrice判断存在性为否时会返回空，避免一个空值赋值给recycleValue
                    }

                    HoverHandler {
                        onHoveredChanged: recycleButton.isHovered = hovered
                    }

                    onClicked:  {
                        infoPopup.close()
                        PlayerData.materialsNumber += Controller.recycledPrice(wIndex,wGrade)
                        Controller.recycleWeapons(wIndex)
                    }

                    contentItem: Text {
                        // text: "回收(+" + Controller.recycledPrice(wIndex,wGrade) + ")"
                        text: "回收(+" + recycleButton.recycleValue + ")"
                        font.pixelSize: 18
                        color: recycleButton.isHovered ? "#444444" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }

                    background: Rectangle {
                        radius: 10
                        color: recycleButton.isHovered ? "white" : Color.getButtonColor(wGrade)
                    }
                }

                // 取消按钮
                Button {
                    id: cancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    property bool isHovered: false

                    HoverHandler {
                        onHoveredChanged: cancelButton.isHovered = hovered
                    }

                    onClicked: infoPopup.close()

                    contentItem: Text {
                        text: "取消"
                        font.pixelSize: 18
                        color: cancelButton.isHovered ? "#444444" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }

                    background: Rectangle {
                        radius: 10
                        color: cancelButton.isHovered ? "white" : Color.getButtonColor(wGrade)
                    }
                }
            }
        }

    }


}
