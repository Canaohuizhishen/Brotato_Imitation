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
    property double k: 1.1

    function lightenColor(hexColor, factor) {
        // 解析十六进制颜色
        const r = parseInt(hexColor.substr(1, 2), 16)
        const g = parseInt(hexColor.substr(3, 2), 16)
        const b = parseInt(hexColor.substr(5, 2), 16)

        // 调整 RGB 值
        const lighten = (c) => Math.min(255, Math.floor(c * factor))

        const rLightened = lighten(r)
        const gLightened = lighten(g)
        const bLightened = lighten(b)

        // 转换回十六进制
        const toHex = (c) => c.toString(16).padStart(2, '0')

        return `#${toHex(rLightened)}${toHex(gLightened)}${toHex(bLightened)}`
    }

    function getOptionColor(grade) {
        const colors = {
            1: "#000000",
            2: "#52ADE8",
            3: "#974FDD",
            4: "#E73535"
        }
        return lightenColor(colors[grade] || "#000000", k)
    }

    function getButtonColor(grade) {
        const colors = {
            1: "#191919",
            2: "#27363D",
            3: "#272231",
            4: "#392121"
        }
        return lightenColor(colors[grade] || "#000000", k)
    }

    function getBackgroundColor(grade) {
        const colors = {
            1: "#000000",
            2: "#0F2028",
            3: "#100A18",
            4: "#240909"
        }
        return lightenColor(colors[grade] || "#000000", k)
    }

    function getImageBackgroundColor(grade) {
        const colors = {
            1: "#323232",
            2: "#3E4C52",
            3: "#3F3A48",
            4: "#4F3939"
        }
        return lightenColor(colors[grade] || "#000000", k)
    }

    function numberToText(grade){
        switch(grade){
        case 1: return ""
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
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
        color: root.getBackgroundColor(root.grade)
        radius: 5*root.scaleFactor
        opacity:1
        anchors.centerIn: root
    }


    Column {
        anchors.fill: parent
        anchors.margins: 15*root.scaleFactor
        spacing: 15*root.scaleFactor

        // 图标和标题行
        Row {
            spacing: 10*root.scaleFactor
            anchors.left: parent.left

            Rectangle {
                id: imageContainer
                width: 70 * root.scaleFactor
                height: 70 * root.scaleFactor
                radius: 5
                color: root.getImageBackgroundColor(root.grade)  // 背景颜色

                Image {
                    anchors.centerIn: parent
                    source: root.iconSource
                    width: 70 * root.scaleFactor
                    height: 70 * root.scaleFactor
                    fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                Text {
                    text: root.title+" "+root.numberToText(root.grade)
                    color:root.color=="#000000" ? "white" : root.color
                    font.pixelSize: 24*root.scaleFactor
                }
                Text {
                    text: root.subtitle
                    color: "#ffffc0"
                    font.pixelSize: 15*root.scaleFactor
                }
            }
        }

        // 数值和描述行
        TextEdit {
            text: root.talentText
            height:15*root.scaleFactor
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
                color: root.getButtonColor(root.grade)
                radius: 7*root.scaleFactor
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
                buttonBg.color = hovered ? "white" :root.getButtonColor(root.grade)
                contentItem.color = hovered ? "root.getButtonColor(root.grade)" : "white"
            }
            onClicked: {
                core.getUpgradeOption(root.grade,root.optionName).choose()
            }
        }
    }
}
