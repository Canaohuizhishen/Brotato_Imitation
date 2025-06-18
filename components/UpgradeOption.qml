import QtQuick 2.15
import QtQuick.Controls 2.15
import "../data"

Rectangle {
    id: root
    property double scaleFactor: 1.0
    width: 242*scaleFactor
    height: 175*scaleFactor
    color: root.getOptionColor(root.grade)
    radius: 8*scaleFactor
    property alias chooseButton:chooseButton

    // 可配置属性
    property string iconSource: ""
    property string optionName
    property int grade: 1
    property string title: ""
    property string subtitle: "升级"
    property string talentText: ""
    property color valueColor: "#00FF00"

    function getOptionColor(grade){
        switch(grade){
        case 1: return "#000000"
        case 2: return "#1E90FF"
        case 3: return "#4B0082"
        case 4: return "#FF0000"
        default: console.log("不正确的等级: ",grade)
        }
    }

    UpgradeOptionCustomizationCore{
        id:core
    }

    Rectangle{
        id: background
        width: root.width-6
        height: root.height-6
        color: "black"
        radius: 5*root.scaleFactor
        opacity: 0.7
        anchors.centerIn: root
    }


    Column {
        anchors.fill: parent
        anchors.margins: 10*root.scaleFactor
        spacing: 18*root.scaleFactor

        // 图标和标题行
        Row {
            spacing: 10*root.scaleFactor
            anchors.left: parent.left

            Image {
                source: root.iconSource
                width: 70*root.scaleFactor
                height: 70*root.scaleFactor
                fillMode: Image.PreserveAspectFit
            }

            Column {
                Text {
                    text: root.title
                    color: "white"
                    font.pixelSize: 24*root.scaleFactor
                }
                Text {
                    text: root.subtitle
                    color: "yellow"
                    font.pixelSize: 15*root.scaleFactor
                }
            }
        }

        // 数值和描述行
        TextEdit {
            text: root.talentText
            height:14*root.scaleFactor
            font.pixelSize: height
            readOnly: true
            textFormat: TextEdit.RichText
            anchors.left: parent.left
        }

        // 选择按钮
        Button {
            id: chooseButton
            text: "选择"
            height: 30*root.scaleFactor
            anchors.left: parent.left
            anchors.right: parent.right
            background: Rectangle {
                id: buttonBg
                color: "#404040"
                radius: 5*root.scaleFactor
            }

            contentItem: Text {
                text: chooseButton.text
                color: "white"
                font.pixelSize: 26*root.scaleFactor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            hoverEnabled: true
            onHoveredChanged: {
                buttonBg.color = hovered ? "white" : "#404040"
                contentItem.color = hovered ? "black" : "white"
            }
            onClicked: {
                core.getUpgradeOption(root.grade,root.optionName).choose()
            }
        }
    }
}
