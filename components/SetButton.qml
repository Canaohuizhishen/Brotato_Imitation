import QtQuick
import QtQuick.Controls

Button {
    id: root
    property double scaleFactor: 1.0
    height: 50*root.scaleFactor

    property color normalColor: "#000000"
    property color hoverColor: "white"
    property color textNormalColor: "white"
    property color textHoverColor: "#000000"
    property int textSize: height*3/5

    background: Rectangle {
        id: buttonBg
        radius: 10*root.scaleFactor
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

    onHoveredChanged: {
        if(hovered) {
            sound.playHoverSound1()
        }
    }
    onClicked: {
        sound.playClickSound()
    }
}
