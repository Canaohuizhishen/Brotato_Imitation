import QtQuick
import QtQuick.Controls
import "../color.js" as Color
import singleton.SettingsData
import "../data/i18n.js" as I18n

Item {
    id: root
    property double scaleFactor: 1.0
    property var itemName
    property var itemData: ({ grade: 1, objectName: "", propName: "", type: "", talentText: "" })
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

        ScaledText {
            visible: propNum >= 2
            text: "X" + propNum
            color: "white"
            basePixelSize: 22
            uiScale: root.scaleFactor
            style: Text.Outline
            styleColor: "black"
            font.weight: Font.DemiBold
            anchors.right: parent.right
            anchors.rightMargin: 2*root.scaleFactor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2*root.scaleFactor
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                propImageBackground.hovered = true
                infoPopup.open()
                sound.playHoverSound()
            }
            onExited: {
                propImageBackground.hovered = false
                infoPopup.close()
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

                ScaledText {
                    id: popupName
                    text: I18n.tr(itemData.propName, SettingsData.language)
                    color: "white"
                    basePixelSize: 18
                    uiScale: root.scaleFactor
                }

                ScaledText {
                    text: I18n.tr(itemData.type, SettingsData.language)
                    color: "#ffffc0"
                    basePixelSize: 15
                    uiScale: root.scaleFactor
                }
            }

            ScaledText {
                id: talentText
                text: I18n.translateRichText(itemData.talentText, SettingsData.language)
                basePixelSize: 13
                uiScale: root.scaleFactor
                font.weight: Font.DemiBold
                anchors.top: popupImageBackground.bottom
                anchors.topMargin: 10*root.scaleFactor
                anchors.left: popupImageBackground.left
            }

        }
    }
}
