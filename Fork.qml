import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    objectName: "Fork"
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    width: 70*scaleFactor
    height: 70*scaleFactor
    z: 0

    onScaleFactorChanged: {
        root.x = root.x*scaleFactor/lastScaleFactor;
        root.y = root.y*scaleFactor/lastScaleFactor;
        lastScaleFactor=scaleFactor
    }

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
