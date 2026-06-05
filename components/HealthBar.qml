import QtQuick 2.15

Item {
    id: healthBar
    width: 215*healthBar.scaleFactor
    height: 30*healthBar.scaleFactor
    property double scaleFactor: 1.0
    property int maxHp: 0
    property int hp: 0
    property color backgroundColor: "#454545"
    property color fillColor: Qt.rgba(0.7,0,0,1)
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 20*healthBar.scaleFactor
    anchors.leftMargin: 15*healthBar.scaleFactor
    z: 10

    Rectangle {
        id: maxHp
        width: healthBar.width
        height: healthBar.height
        color: healthBar.backgroundColor
        border.color: "black"
        border.width: 4*healthBar.scaleFactor
        radius: 3

        Rectangle {
            id: hp
            width: maxHp.width*healthBar.hp/healthBar.maxHp-maxHp.border.width*2
            height: maxHp.height-maxHp.border.width*2-1*healthBar.scaleFactor
            color: healthBar.fillColor
            anchors.verticalCenter: maxHp.verticalCenter
            anchors.left: maxHp.left
            anchors.leftMargin: maxHp.border.width
        }

        ScaledText {
            id: hpText
            text: healthBar.hp+"/"+healthBar.maxHp
            color: "white"
            basePixelSize: 18
            uiScale: healthBar.scaleFactor
            style: Text.Outline
            styleColor: "black"
            anchors.centerIn: parent
        }
    }
}
