import QtQuick 2.15

Item {
    id: root
    property double scaleFactor: 1.0
    width: 240*scaleFactor
    height: 12*scaleFactor

    // 可配置属性
    property string iconSource: ""
    property string attribute: ""
    property int attributeValue:0
    property color attributeColor: "white"
    property color valueColor: "white"
    property int fontSize: 16*scaleFactor

    function getValueColor(val) {
        var num = parseFloat(val);
        if (num > 0) return "#00FF00";  // 绿色
        if (num < 0) return "#FF0000";  // 红色
        return "white";  // 零值保持原色
    }

    Image {
        source: root.iconSource
        width: 20*root.scaleFactor
        height: 20*root.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 4*root.scaleFactor
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: root.attribute
        color: root.getValueColor(root.attributeValue)
        font.pixelSize: root.fontSize
        anchors.left: parent.left
        anchors.leftMargin: 30*root.scaleFactor
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
}
