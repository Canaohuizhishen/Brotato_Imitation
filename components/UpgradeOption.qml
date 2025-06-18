import QtQuick 2.15
import QtQuick.Controls 2.15
import "../data"

Rectangle {
    id: root
    width: 242
    height: 175
    color: "#000000"
    radius: 8

    // 可配置属性
    property string iconSource: ""
    property string optionName
    property int grade:1
    property string title: ""
    property string subtitle: "升级"
    property string talentText: ""
    property color valueColor: "#00FF00"

    UpgradeOptionCustomizationCore{
        id:core
    }

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
        TextEdit {
            text: root.talentText
            font.pixelSize: height
            height:14
            readOnly: true
            textFormat: TextEdit.RichText
            anchors.left: parent.left
        }


        // 选择按钮
        Button {
            text: "选择"
            height: 30
            anchors.left: parent.left
            anchors.right: parent.right
            background: Rectangle {
                id: buttonBg
                color: "#404040"
                radius: 5
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 26
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            hoverEnabled: true
            onHoveredChanged: {
                buttonBg.color = hovered ? "white" : "#404040"
                contentItem.color = hovered ? "black" : "white"
            }
            onClicked: {
                core.getUpgradeOption(root.grade,optionName).choose()
            }
        }
    }
}
