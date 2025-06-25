import QtQuick
import QtQuick.Controls

Item {
    id: root
    property double scaleFactor: 1.0
    property bool hovered: false
    width: 240*scaleFactor
    height: 16*scaleFactor

    // 可配置属性
    property string iconSource: ""
    property string detailImage: ""
    property string attribute: ""
    property int attributeValue: 0
    property color attributeColor: "white"
    property color valueColor: "white"
    property int fontSize: height
    property string detailDescription: ""
    property bool inUp: false
    property bool inLeft :true

    function getValueColor(val) {
        var num = parseFloat(val);
        if (num > 0) return "#00FF00";  // 绿色
        if (num < 0) return "#FF0000";  // 红色
        return "white";  // 零值保持原色
    }

    //检测悬停区域
    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
        onHoveredChanged: {
            if (root.detailDescription) {
                root.hovered = hovered
                hovered ? detailPopup.open() : detailPopup.close()
            }
        }
    }

    Image {
        id:attributeImage
        source: root.iconSource
        width: 20*root.scaleFactor
        height: 20*root.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 4*root.scaleFactor
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id:attributeText
        text: root.attribute
        color: root.getValueColor(root.attributeValue)
        font.pixelSize: root.fontSize
        anchors.left: parent.left
        anchors.leftMargin: root.iconSource=="" ? 0 : 30*root.scaleFactor
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: root.attributeValue
        color: root.getValueColor(root.attributeValue)
        font.pixelSize: root.fontSize
        anchors.right: parent.right
        anchors.rightMargin: 10*root.scaleFactor
        anchors.verticalCenter: parent.verticalCenter
    }
    Popup {
        id: detailPopup
        width: 350*root.scaleFactor
        height: 100*root.scaleFactor
        padding: 10*root.scaleFactor
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#000000"
            radius: 5*root.scaleFactor
        }

        x: attributeImage.x+(root.inLeft?(-width): root.width)
        y: attributeImage.y+(root.inUp?(-height-attributeImage.height/2): attributeImage.height+attributeImage.height/2)

        Row {
            id: contentColumn
            width: 350*root.scaleFactor
            height: 100*root.scaleFactor
            anchors.fill: parent
            spacing: 10*root.scaleFactor
            Image {
                id:poupImage
                source: root.detailImage
                width: 60*root.scaleFactor
                height: 60*root.scaleFactor
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                visible: root.detailImage
            }

            // 详细描述文本（始终显示）
            Column{
                width:240*root.scaleFactor
                spacing: 5*root.scaleFactor
                Text {
                    id:text1
                    width:100*root.scaleFactor
                    text:root.attribute
                    color: "white"
                    font.pixelSize: 14*root.scaleFactor
                }
                Text {
                    width:parent.width
                    text: root.detailDescription
                    color: "white"
                    wrapMode: Text.Wrap
                    font.pixelSize: 14*root.scaleFactor
                    visible: text !== ""
                }
            }
        }
    }


}
