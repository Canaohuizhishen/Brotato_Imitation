import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    width: 20
    height: 20
    objectName: "Fork"
    z: 0

    Shape {
        id: fork
        anchors.centerIn: parent
        clip: true
        property double centerX: root.width/2+15
        property double centerY: root.height/2+15

        ShapePath {
            id: bian1
            strokeWidth: 20
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX-root.width/2
            startY: fork.centerY-root.height/2
            PathLine { x: bian1.startX+root.width; y: bian1.startY+root.height }
        }
        ShapePath {
            id: bian2
            strokeWidth: 20
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX-root.width/2
            startY: fork.centerY+root.height/2
            PathLine { x: fork.centerX+root.height/2; y: fork.centerY-root.width/2 }
        }
        ShapePath {
            id: line1
            strokeWidth: 14
            strokeColor: "red"
            fillColor: "transparent"
            startX: fork.centerX-root.width/2
            startY: fork.centerY-root.height/2
            PathLine { x: bian1.startX+root.width; y: bian1.startY+root.height }
        }
        ShapePath {
            id: line2
            strokeWidth: 14
            strokeColor: "red"
            fillColor: "transparent"
            startX: fork.centerX-root.width/2
            startY: fork.centerY+root.height/2
            PathLine { x: fork.centerX+root.width/2; y: fork.centerY-root.height/2 }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX-root.width/4
            startY: fork.centerY-root.width/4
            PathLine { x: fork.centerX-root.width/1.5; y: fork.centerY-root.height/1.5 }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX+root.width/4
            startY: fork.centerY+root.width/4
            PathLine { x: fork.centerX+root.width/1.5; y: fork.centerY+root.height/1.5 }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX-root.width/4
            startY: fork.centerY+root.height/4
            PathLine { x: fork.centerX-root.height/1.5; y: fork.centerY+root.width/1.5 }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX+root.width/4
            startY: fork.centerY-root.height/4
            PathLine { x: fork.centerX+root.height/1.5; y: fork.centerY-root.width/1.5 }
        }
        ShapePath {
            strokeWidth: 1.5
            strokeColor: "black"
            fillColor: "transparent"
            startX: fork.centerX-0.1
            startY: fork.centerY
            PathLine { x: fork.centerX+0.1; y: fork.centerY }
        }
    }

    SequentialAnimation on opacity {
            loops: 1
            PropertyAnimation { from: 0; to: 1; duration: 350 }  // 淡出
            PropertyAnimation { from: 0; to: 1; duration: 350 }  // 淡入
    }
}
