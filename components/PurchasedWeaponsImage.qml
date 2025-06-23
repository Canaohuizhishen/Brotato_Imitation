import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../logic/ShopLogicHandler.js" as Controller
import "../color.js" as Color

Item {
    id: root

    property var itemData
    property int wIndex
    property bool popupActive: false

    Rectangle {
        id: weaponImageBackground
        width: parent.width
        height: parent.height
        radius: 6
        color: weaponImageBackground.hovered ? "white" : Color.getImageBackgroundColor(itemData.grade)
        // border.color:

        property bool hovered: false

        Image {
            id: weaponImage
            // source: "/images/weapon-" + itemData.objectName + ".png"
            source: "/images/prop-" + itemData.objectName + ".png"
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
            color: Color.getBackgroundColor(itemData.grade)
            // border.color:
            radius: 5
        }

        contentItem: ColumnLayout {
            id: contentLayout
            width: parent.width

            RowLayout {
                // Layout.preferredWidth: 150

                Rectangle {
                    id: background
                    color: Color.getImageBackgroundColor(itemData.grade)
                    radius: 6
                    Layout.minimumWidth: 63
                    Layout.minimumHeight: 63
                    Layout.leftMargin: 8
                    Layout.topMargin: 8

                    Image {
                        id: image
                        // source: "/images/weapon-" + itemData.objectName + ".png"
                        source: "/images/prop-" + itemData.objectName + ".png"
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
                        text: itemData.objectName
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
                text: itemData.talentText
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
                        color: compositeButton.isHovered ? "white" : Color.getButtonColor(itemData.grade)
                    }
                }

                // 回收按钮
                Button {
                    id: recycleButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    property bool isHovered: false

                    HoverHandler {
                        onHoveredChanged: recycleButton.isHovered = hovered
                    }

                    onClicked:  {
                        infoPopup.close()
                        Controller.recycleWeapons(wIndex)
                    }

                    contentItem: Text {
                        text: "回收(" + Controller.recycledPrice(wIndex) + ")"
                        font.pixelSize: 18
                        color: recycleButton.isHovered ? "#444444" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                    }

                    background: Rectangle {
                        radius: 10
                        color: recycleButton.isHovered ? "white" : Color.getButtonColor(itemData.grade)
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
                        color: cancelButton.isHovered ? "white" : Color.getButtonColor(itemData.grade)
                    }
                }
            }
        }

    }


}
