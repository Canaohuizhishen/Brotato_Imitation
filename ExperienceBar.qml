import QtQuick 2.15

Item {
    id: experienceBar
    width: 180
    height: 25
    property double maxXp: 100
    property double xp: 0
    property int level: 0
    property color backgroundColor: "gray"
    property color fillColor: "green"
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 45
    anchors.leftMargin: 40
    z: 10

    Rectangle {
        id: maxXp
        width: experienceBar.width
        height: experienceBar.height
        color: experienceBar.backgroundColor
        border.color: "black"
        border.width: 3

        Rectangle {
            id: xp
            width: maxXp.width*experienceBar.xp/experienceBar.maxXp-maxXp.border.width*2-0.7
            height: maxXp.height-maxXp.border.width*2-1
            color: experienceBar.fillColor
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: maxXp.border.width+0.5

        }

        Text {
            id: xpText
            text: "LV."+experienceBar.level
            color: "black"
            font.pixelSize: 18
            style: Text.Outline
            styleColor: "black"
            anchors.right: parent.right
            anchors.topMargin: maxXp.border.width+1
            anchors.rightMargin: maxXp.border.width
        }

        Text {
            text: xpText.text
            color: "white"
            font.pixelSize: xpText.font.pixelSize
            anchors.right: xpText.anchors.right
            anchors.topMargin: xpText.anchors.topMargin
            anchors.rightMargin: xpText.anchors.rightMargin
        }
    }
}
