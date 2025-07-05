import QtQuick 2.15

Item {
    id: experienceBar
    width: 215*experienceBar.scaleFactor
    height: 30*experienceBar.scaleFactor
    property double scaleFactor: 1.0
    property double maxXp: 100
    property double xp: 0
    property int level: 0
    property color backgroundColor: "#454545"
    property color fillColor: Qt.rgba(0,0.7,0,1)
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 55*experienceBar.scaleFactor
    anchors.leftMargin: 15*experienceBar.scaleFactor
    z: 10

    Rectangle {
        id: maxXp
        width: experienceBar.width
        height: experienceBar.height
        color: experienceBar.backgroundColor
        border.color: "black"
        border.width: 4*experienceBar.scaleFactor
        radius: 3

        Rectangle {
            id: xp
            width: maxXp.width*experienceBar.xp/experienceBar.maxXp-maxXp.border.width*2
            height: maxXp.height-maxXp.border.width*2-1*experienceBar.scaleFactor
            color: experienceBar.fillColor
            anchors.verticalCenter: maxXp.verticalCenter
            anchors.left: maxXp.left
            anchors.leftMargin: maxXp.border.width

        }

        Text {
            id: xpText
            text: "LV."+experienceBar.level
            color: "white"
            font.pixelSize: 18*experienceBar.scaleFactor
            style: Text.Outline
            styleColor: "black"
            anchors.right: parent.right
            anchors.rightMargin: maxXp.border.width
            anchors.verticalCenter: maxXp.verticalCenter
        }
    }
}
