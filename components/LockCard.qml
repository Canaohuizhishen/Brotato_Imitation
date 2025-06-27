import QtQuick 2.15

Rectangle {
    id: lockCard
    property double scaleFactor: 1.0
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4

    Image {
        source: "qrc:/images/lock3.png"
        width: 45*lockCard.scaleFactor
        height: width*1.3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 65*lockCard.scaleFactor
    }

    Text{
        text: "敬请期待"
        color: "white"
        font.pixelSize: 18*lockCard.scaleFactor
        anchors.centerIn: parent
    }
}
