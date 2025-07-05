import QtQuick
import QtQuick.Controls

Item {
    id: root
    property double scaleFactor: 1.0
    width:420*root.scaleFactor
    height: 45*root.scaleFactor

    // 可配置属性
    property string label: "Label"
    property bool checked: false
    property int fontSize: 30*root.scaleFactor

    // 信号
    signal toggled(bool checked)

    Rectangle {
        width: parent.width
        height: parent.height
        color: root.checked ? "#000000" : (hoverHandler.hovered ? "white" : "#000000")
        radius: 5*root.scaleFactor

        // 悬停检测
        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
        }
        // 点击检测
        TapHandler {
            onTapped: switchControl.toggle()
        }

        Row {
            anchors.verticalCenter:  parent.verticalCenter
            anchors.leftMargin: 10*root.scaleFactor
            anchors.left: parent.left
            spacing: parent.width - labelText.implicitWidth - switchControl.width-5*root.scaleFactor

            Text {
                id: labelText
                text: root.label
                color: root.checked ? "white" : (hoverHandler.hovered ? "black" : "white")
                font.pixelSize: root.fontSize
                verticalAlignment: Text.AlignVCenter
            }

            Switch {
                id: switchControl
                checked: root.checked
                indicator: Rectangle {
                    implicitWidth: 50*root.scaleFactor
                    implicitHeight: 20*root.scaleFactor
                    y: parent.height/2 - height/2
                    radius: 0
                    color: switchControl.checked ? "#afafaf" : "#252525"
                    border.color: "#000000"
                    border.width: 3*root.scaleFactor

                    Rectangle {
                        x: switchControl.checked ? parent.width - width : 0
                        y: parent.height/2 - height/2
                        width: 20*root.scaleFactor
                        height: 26*root.scaleFactor
                        radius: 0
                        color: switchControl.checked ? "#dbdbdb" : "#656565"
                        border.color: "#000000"
                        border.width: 3*root.scaleFactor
                    }
                }

                onCheckedChanged: {
                    root.checked = checked
                    root.toggled(checked)
                }
            }
        }
    }
}
