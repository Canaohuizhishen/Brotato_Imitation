import QtQuick
import QtQuick.Controls
import "../color.js" as Color

Item {
    id: root

    property var itemData
    property int propNum : 1

    Rectangle {
        id: propImageBackground
        width: parent.width
        height: parent.height
        color: propImageBackground.hovered ? "white" : Color.getBackgroundColor(itemData.grade)
        radius: 6

        property bool hovered: false


        Image {
            id: propImage
            source: "qrc:/images/prop-" + itemData.objectName + ".png"
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
        }

        Text {
            visible: propNum >= 2
            text: "X" + count
            color: "white"
            font.pixelSize: 22
            style: Text.Outline
            styleColor: "black"
            font.weight: Font.DemiBold
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
        }

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
            onHoveredChanged: {
                propImageBackground.hovered = hovered
                if (hovered) {
                    infoPopup.open()
                } else {
                    infoPopup.close()
                }
            }
        }

        TapHandler {
            onTapped: {
                infoPopup.open()
            }
        }
    }

    Popup {
        id: infoPopup

        width: 245
        height: 160

        closePolicy: Popup.NoAutoClose
        x: propImage.mapToItem(root,0,0).x
        y: propImage.mapToItem(root,0,-165).y

        background: Rectangle {
            anchors.fill: parent
            color: Color.getBackgroundColor(itemData.grade)
            radius: 5
            border.color: Color.getBorderColor(itemData.grade)
        }

        contentItem: Item {
            id: info
            // anchors.fill: parent
            anchors.top: parent.top
            anchors.margins: 8
            anchors.left: parent.left
            anchors.leftMargin: 8
            // width: parent.width
            // height: parent.height
            // color: "black"

            Rectangle {
                id: popupImageBackground
                width: 63
                height: 63
                color: Color.getImageBackgroundColor(itemData.grade)
                radius: 6

                Image {
                    id: popupImage
                    source: "qrc:/images/prop-" + itemData.objectName + ".png"
                    width: 63
                    height: 63
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.left: popupImageBackground.right
                anchors.leftMargin: 5
                anchors.top: popupImageBackground.top

                Text {
                    id: popupName
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

            Text {
                anchors.top: popupImageBackground.bottom
                anchors.topMargin: 5
                anchors.left: popupImageBackground.left
                text: itemData.talentText
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

        }
    }
}
