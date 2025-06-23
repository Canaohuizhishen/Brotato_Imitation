import QtQuick
import QtQuick.Controls

Button {
    id: root
    height: 50

    property color normalColor: "#000000"
    property color hoverColor: "white"
    property color textNormalColor: "white"
    property color textHoverColor: "#000000"
    property int textSize: 30

    background: Rectangle {
        id: buttonBg
        radius: 5
        color: root.hovered ? root.hoverColor : root.normalColor
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
        text: root.text
        color: root.hovered ? root.textHoverColor : root.textNormalColor
        font.pixelSize: root.textSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
