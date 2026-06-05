import QtQuick 2.15

/**
 * BloodParticle — 血花粒子组件
 *
 * 用于怪物受击时的血液飞溅效果。
 * 通过 ParticlePool 对象池循环复用，避免运行时创建/销毁开销。
 *
 * 属性由 ParticlePool.spawn() 填充后调用 restartAnimation()。
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

    // 内部红色圆
    Rectangle {
        width: parent.width / 1.6
        height: width * 1.2
        anchors.centerIn: parent
        color: "#AB0000"
        visible: parent.visible
        radius: width / 2
    }

    function restartAnimation() {
        // 重置位置
        scale = 1.0
        visible = true
        // 设置动画目标（每次复用重新计算）
        animX.from = x
        animX.to = x + targetDx
        animY.from = y
        animY.to = y + targetDy
        // 启动动画
        bloodAnimation.restart()
    }

    SequentialAnimation {
        id: bloodAnimation
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
                to: 0.7
                duration: 350
                easing.type: Easing.OutQuad
            }
        }

        onStopped: {
            root.visible = false
        }
    }
}
