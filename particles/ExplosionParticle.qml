import QtQuick 2.15

/**
 * ExplosionParticle — 爆炸环形扩散粒子组件
 *
 * 用于爆炸属性伤害命中时的视觉反馈。
 * 由 ParticlePool 的 explosion 池循环复用。
 *
 * 用法（由 ParticlePool.explode() 内部调用）：
 *   particle.showExplosion(x, y, radius)
 */
Item {
    id: root

    property real particleRadius: 30
    property bool _running: false

    visible: false
    z: 50

    // 外圈 — 扩散环
    Rectangle {
        id: outerRing
        width: 0
        height: 0
        radius: width / 2
        color: "transparent"
        border.color: "#FF6600"
        border.width: 3
        anchors.centerIn: parent
    }

    // 闪光 — 中心亮斑
    Rectangle {
        id: flash
        width: particleRadius * 2
        height: particleRadius * 2
        radius: width / 2
        color: Qt.rgba(1, 0.8, 0.2, 0.8)
        anchors.centerIn: parent
        visible: false
    }

    // 粒子碎片（4 个随机方向的小块）
    Repeater {
        id: debris
        model: 6
        Rectangle {
            id: debrisItem
            x: root.width / 2 - width / 2
            y: root.height / 2 - height / 2
            width: Math.random() * 6 + 3
            height: width
            radius: width / 2
            color: ["#FF6600", "#FFAA00", "#FF4400", "#FFFF44", "#FF8800", "#FFCC00"][index]
            visible: false
        }
    }

    function showExplosion(x, y, radius) {
        root.x = x - radius
        root.y = y - radius
        root.width = radius * 2
        root.height = radius * 2
        root.particleRadius = radius
        root.visible = true
        root._running = true
        explodeAnim.restart()
    }

    SequentialAnimation {
        id: explodeAnim
        running: false
        loops: 1

        // 阶段1：外圈扩散 + 闪光
        ParallelAnimation {
            PropertyAnimation {
                target: outerRing
                property: "width"
                from: 0
                to: particleRadius * 2
                duration: 150
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: outerRing
                property: "height"
                from: 0
                to: particleRadius * 2
                duration: 150
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: outerRing
                property: "border.width"
                from: 6
                to: 1
                duration: 150
            }
            PropertyAction {
                target: flash
                property: "visible"
                value: true
            }
            PropertyAnimation {
                target: flash
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
            ScriptAction {
                script: {
                    // 激活碎片
                    for (var i = 0; i < debris.model; i++) {
                        var d = debris.itemAt(i)
                        if (d) {
                            d.visible = true
                            var angle = Math.random() * 2 * 3.14159
                            var dist = Math.random() * particleRadius * 0.8
                            d.x = root.width / 2 - d.width / 2 + Math.cos(angle) * dist
                            d.y = root.height / 2 - d.height / 2 + Math.sin(angle) * dist
                        }
                    }
                }
            }
        }

        // 阶段2：外圈淡出 + 碎片飞出
        ParallelAnimation {
            PropertyAnimation {
                target: outerRing
                property: "opacity"
                from: 1
                to: 0
                duration: 250
            }
            PropertyAnimation {
                target: flash
                property: "opacity"
                from: 0
                to: 0
                duration: 250
            }
            PropertyAnimation {
                target: flash
                property: "visible"
                to: false
                duration: 0
            }
            ScriptAction {
                script: {
                    for (var i = 0; i < debris.model; i++) {
                        var d = debris.itemAt(i)
                        if (d) {
                            var angle2 = Math.random() * 2 * 3.14159
                            var dist2 = Math.random() * particleRadius * 1.2
                            d.x = root.width / 2 - d.width / 2 + Math.cos(angle2) * dist2
                            d.y = root.height / 2 - d.height / 2 + Math.sin(angle2) * dist2
                            d.opacity = 0
                        }
                    }
                }
            }
        }

        onStopped: {
            root.visible = false
            root._running = false
            // 重置所有子项
            outerRing.width = 0
            outerRing.height = 0
            outerRing.opacity = 1
            outerRing.border.width = 3
            flash.visible = false
            flash.opacity = 1
            for (var i = 0; i < debris.model; i++) {
                var d = debris.itemAt(i)
                if (d) {
                    d.visible = false
                    d.opacity = 1
                }
            }
        }
    }
}
