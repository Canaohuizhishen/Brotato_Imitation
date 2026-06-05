import QtQuick 2.15

/**
 * DebrisParticle — 材料拾取残渣粒子组件
 *
 * 与 BloodParticle 类似，但颜色为绿色，缩放动画缩至 0，
 * 模拟材料被拾取时的碎片飞散效果。
 *
 * 通过 ParticlePool 的 debris 池循环复用。
 */
Rectangle {
    id: root

    // 由 ParticlePool 设置的属性
    property real targetDx: 0
    property real targetDy: 0
    property real particleWidth: 10

    width: particleWidth
    height: width * 1.1
    color: "black"
    visible: false
    radius: width / 2
    rotation: -30
    z: 3

    // 内部绿色圆
    Rectangle {
        width: parent.width / 1.6
        height: width * 1.2
        anchors.centerIn: parent
        color: Qt.rgba(0, 1, 0, 1)
        visible: parent.visible
        radius: width / 2
    }

    function restartAnimation() {
        scale = 1.0
        visible = true
        // 设置动画目标
        animX.from = x
        animX.to = x + targetDx
        animY.from = y
        animY.to = y + targetDy
        debrisAnimation.restart()
    }

    SequentialAnimation {
        id: debrisAnimation
        running: false

        ParallelAnimation {
            PropertyAnimation {
                id: animX
                target: root
                property: "x"
                duration: 350
                easing.type: Easing.Linear
            }
            PropertyAnimation {
                id: animY
                target: root
                property: "y"
                duration: 350
                easing.type: Easing.Linear
            }
            PropertyAnimation {
                target: root
                property: "scale"
                from: 1
                to: 0
                duration: 550
                easing.type: Easing.Linear
            }
        }

        onStopped: {
            root.visible = false
        }
    }
}
