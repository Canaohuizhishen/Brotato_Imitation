import QtQuick
import QtQuick.Controls
import "../color.js" as Color

Item {
    id: root
    property double scaleFactor: 1.0
    property var itemData
    property int propNum : 1
    property bool inUp: true
    property bool inLeft: true

    Rectangle {
        id: propImageBackground
        width: parent.width
        height: parent.height
        color: propImageBackground.hovered ? "white" : Color.getBackgroundColor(itemData.grade)
        radius: 6*root.scaleFactor
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
            font.pixelSize: 22*root.scaleFactor
            style: Text.Outline
            styleColor: "black"
            font.weight: Font.DemiBold
            anchors.right: parent.right
            anchors.rightMargin: 2*root.scaleFactor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2*root.scaleFactor
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
        width: root.width*3.8
        height: Math.max(root.width*2.5,popupImageBackground.height+talentText.height+30*root.scaleFactor)
        closePolicy: Popup.NoAutoClose
        x: root.inLeft ? propImageBackground.width-width : 0
        y: root.inUp ? -height-5*root.scaleFactor : propImageBackground.height+5*root.scaleFactor

        background: Rectangle {
            anchors.fill: parent
            color: Color.getBackgroundColor(itemData.grade)
            radius: 5*root.scaleFactor
            border.color: Color.getBorderColor(itemData.grade)
        }

        contentItem: Item {
            id: info
            // anchors.fill: parent
            anchors.top: parent.top
            anchors.topMargin: 10*root.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 10*root.scaleFactor
            // width: parent.width
            // height: parent.height
            // color: "black"

            Rectangle {
                id: popupImageBackground
                width: root.width
                height: root.height
                color: Color.getImageBackgroundColor(itemData.grade)
                radius: 6*root.scaleFactor

                Image {
                    id: popupImage
                    source: "qrc:/images/prop-" + itemData.objectName + ".png"
                    width: root.width
                    height: root.height
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.left: popupImageBackground.right
                anchors.leftMargin: 5*root.scaleFactor
                anchors.top: popupImageBackground.top

                Text {
                    id: popupName
                    text: itemData.propName
                    color: "white"
                    font.pixelSize: 18*root.scaleFactor
                }

                Text {
                    text: itemData.type
                    color: "#ffffc0"
                    font.pixelSize: 15*root.scaleFactor
                }
            }

            Text {
                id: talentText
                text: itemData.talentText
                font.pixelSize: 13*root.scaleFactor
                font.weight: Font.DemiBold
                anchors.top: popupImageBackground.bottom
                anchors.topMargin: 10*root.scaleFactor
                anchors.left: popupImageBackground.left
            }

        }
    }
}
