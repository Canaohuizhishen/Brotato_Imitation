import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    objectName: "Fork"
    property string targetMonsterName
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool paused: false
    width: 70*scaleFactor
    height: 70*scaleFactor
    z: 0

    onPausedChanged: {
        if(paused)blink.pause()
        else blink.resume()
    }

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
        source: "/images/red_fork.png"
    }

    SequentialAnimation on opacity {
        id: blink
        running: true
        loops: Animation.Infinite
        PropertyAnimation { from: 0; to: 1; duration: 175 }  // 淡入
        PropertyAnimation { from: 1; to: 0; duration: 175 }  // 淡出
    }
}
