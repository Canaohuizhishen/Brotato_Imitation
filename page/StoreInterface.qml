import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: storeInterface
    property double scaleFactor: 1.0
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100
    property Button goButton: go

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#353535"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#555555" }
            GradientStop { position: 0.5; color: "#353535" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }
    }

    Button{
        id: go
        text: "开始"
        width: storeInterface.width/15
        height: storeInterface.height/15
        anchors.bottom: storeInterface.bottom
        anchors.bottomMargin: storeInterface.height*10/32
        anchors.right: storeInterface.right
        anchors.rightMargin: storeInterface.width/20
        background: Rectangle {
            color: go.pressed || go.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: Text {
            text: go.text
            font.pixelSize: 23*storeInterface.scaleFactor
            color: go.pressed || go.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
