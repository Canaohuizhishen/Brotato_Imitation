import QtQuick 2.15

Item {
    id: root
    width: parent.width
    height: 12

    // 可配置属性
    property string iconSource: ""
    property string attribute: ""
    property int attributevalue:0
    property color attributeColor: "white"
    property color valueColor: "white"
    property int fontSize: 16

    function getValueColor(val) {
        var num = parseFloat(val);
        if (num > 0) return "#00FF00";  // 绿色
        if (num < 0) return "#FF0000";  // 红色
        return "white";  // 零值保持原色
    }

    Image {
        source: root.iconSource
        width: 20
        height: 20
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: root.attribute
        color: getValueColor(root.value)
        font.pixelSize: root.fontSize
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: root.value
        color: getValueColor(root.value)
        font.pixelSize: root.fontSize
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}
