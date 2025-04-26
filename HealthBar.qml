import QtQuick 2.15

Item {
    id: healthBar
    width: 180
    height: 25
    property double maxHp: 0
    property double hp: 0
    property color backgroundColor: "gray"
    property color fillColor: "red"
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 15
    anchors.leftMargin: 40
    z: 10

    Rectangle {
        id: maxHp
        width: healthBar.width
        height: healthBar.height
        color: healthBar.backgroundColor
        border.color: "black"
        border.width: 3


        Rectangle {
            id: hp
            width: maxHp.width*healthBar.hp/healthBar.maxHp-maxHp.border.width*2-0.7
            height: maxHp.height-maxHp.border.width*2-1
            color: healthBar.fillColor
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: maxHp.border.width+0.5

        }

        Text {
            id: hpText
            text: healthBar.hp+"/"+healthBar.maxHp
            color: "black"
            font.pixelSize: 18
            style: Text.Outline
            styleColor: "black"
            anchors.centerIn: parent
        }

        Text {
            text: hpText.text
            color: "white"
            font.pixelSize: hpText.font.pixelSize
            anchors.centerIn: hpText.anchors.centerIn
        }
    }
}
