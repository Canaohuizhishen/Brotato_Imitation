import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    width: 70
    height: 70
    objectName: "Fork"
    z: 0

    Image {
        id: fork
        anchors.centerIn: parent
        width: root.width
        height: root.height
        source: "/images/叉叉.png"
    }

    SequentialAnimation on opacity {
            loops: 1
            PropertyAnimation { from: 0; to: 1; duration: 350 }  // 淡出
            PropertyAnimation { from: 0; to: 1; duration: 350 }  // 淡入
    }
}
