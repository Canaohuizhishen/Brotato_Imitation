import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 242
    height: 175
    color: "#000000"
    radius: 8

    // 可配置属性
    property string iconSource: ""
    property string title: ""
    property string subtitle: "升级"
    property string valueText: ""
    property string description: ""
    property color valueColor: "#00FF00"

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 18

        // 图标和标题行
        Row {
            spacing: 10
            anchors.left: parent.left

            Image {
                source: root.iconSource
                width: 70
                height: 70
                fillMode: Image.PreserveAspectFit
            }

            Column {
                Text {
                    text: root.title
                    color: "white"
                    font.pixelSize: 24
                }
                Text {
                    text: root.subtitle
                    color: "yellow"
                    font.pixelSize: 15
                }
            }
        }

        // 数值和描述行
        Row {
            anchors.left: parent.left
            spacing: 2
            Text {
                text: root.valueText
                color: root.valueColor
                font.pixelSize: 14
            }
            Text {
                text: root.description
                color: "white"
                font.pixelSize: 14
            }
        }

        // 选择按钮
        Button {
            text: "选择"
            font.pixelSize: 25
            height: 30
            anchors.left: parent.left
            anchors.right: parent.right
            background: Rectangle {
                id: buttonBg
                color: "#404040"
                radius: 5
            }

            // Text {
            //     text: parent.text
            //     color: "white"
            //     font.pixelSize: 25
            //     anchors.centerIn: parent
            // }

            hoverEnabled: true
            onHoveredChanged: {
                buttonBg.color = hovered ? "white" : "#404040"
                contentItem.color = hovered ? "black" : "white"
            }
            onClicked: {
                console.log("选择了:", root.title)
            }
        }
    }
}
