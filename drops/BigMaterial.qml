import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../tool.js" as Tool
import "../logic/ParticlePool.js" as ParticlePool

/**
 * BigMaterial — 由多个小材料合并而成的大材料
 *
 * 等级定义：
 *   Tier 1: 5合1, 尺寸 ×1.5
 *   Tier 2: 10合1, 尺寸 ×2.2
 *   Tier 3: 20合1, 尺寸 ×3.0
 */
Item {
    id: bigMaterial
    objectName: "大材料"
    property int tier: 1                         // 1/2/3
    property int totalValue: 0                   // 被合并材料 value 之和
    property bool isGeted: false
    property bool isDestroy: false
    property double scaleFactor: 1

    // 等级参数表
    readonly property var sizeMultiplier: [1.3, 1.8, 2.4]

    // value 直接给 totalValue，Player.getMaterial(material) 使用 material.value
    readonly property int value: totalValue

    width: 30 * scaleFactor * sizeMultiplier[tier - 1]
    height: width
    z: y + height

    // 弹出动画
    PropertyAnimation {
        id: popInAnimation
        target: bigMaterial
        property: "scale"
        from: 0
        to: 1
        duration: 300
        easing.type: Easing.OutBack
        running: true
    }

    Component.onCompleted: {
        var array = materialImageAspectRatioArray
        materialImage.rotation = Math.random() * 360
        var index = Math.floor(Math.random() * array.length)
        materialImage.source = "qrc:/images/material" + (index + 1) + ".png"
        var k = 1 / array[index]
        materialImage.width = Qt.binding(function() {
            return bigMaterial.width * k / Math.sqrt(k * k + 1) * 0.85
        })
        materialImage.height = Qt.binding(function() {
            return bigMaterial.width / k * 0.85
        })
    }

    // ---- 与 Material.qml 一致的图片资源表 ----
    property var materialImageAspectRatioArray: [0.643, 0.905, 0.681, 0.886, 0.93, 0.415, 0.623, 0.906]

    function toBag(point) {
        toBagAnimation.targetPoint = point
        toBagAnimation.start()
    }

    function beGetedTo(target) {
        bigMaterial.isGeted = true
        beGetedAnimation.target = target
        beGetedAnimation.start()
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_material.wav"
        volume: 0.6
    }

    Image {
        id: materialImage
        anchors.centerIn: bigMaterial
        z: 1
    }

    // 光晕（与小材料一致的标准绿色发光）
    Canvas {
        id: flame
        width: bigMaterial.width * 1.5
        height: width
        anchors.centerIn: bigMaterial
        z: 0
        onPaint: {
            var ctx = getContext("2d")
            var gradient = ctx.createRadialGradient(
                        width / 2, height / 2, 0,
                        width / 2, height / 2, width / 2
                        )
            gradient.addColorStop(0, Qt.rgba(0, 0.8, 0, 1))
            gradient.addColorStop(1, Qt.rgba(0, 1, 0, 0))
            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2)
            ctx.fill()
        }
    }

    // ---- 飞向背包栏 ----
    ParallelAnimation {
        id: toBagAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(0, 0)

        PropertyAnimation {
            id: xtoBagAnimation
            target: bigMaterial
            property: "x"
            from: bigMaterial.x
            to: toBagAnimation.targetPoint.x - bigMaterial.width / 2
            duration: Tool.getDistance(
                          Qt.point(bigMaterial.x + bigMaterial.width / 2,
                                   bigMaterial.y + bigMaterial.height / 2),
                          toBagAnimation.targetPoint)
            easing.type: Easing.OutQuart
        }

        PropertyAnimation {
            id: ytoBagAnimation
            target: xtoBagAnimation.target
            property: "y"
            from: bigMaterial.y
            to: toBagAnimation.targetPoint.y - bigMaterial.height / 2
            duration: xtoBagAnimation.duration
            easing.type: xtoBagAnimation.easing.type
        }

        onStopped: {
            // 大材料进袋 = 其 totalValue 对应的材料数
            PlayerData.remainingMaterialsNumber += totalValue
            bigMaterial.visible = false
            bigMaterial.destroy(700)
        }
    }

    // ---- 飞向玩家 ----
    ParallelAnimation {
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: Qt.point(0, 0)

        PropertyAnimation {
            id: xbeGetedAnimation
            target: bigMaterial
            property: "x"
            from: bigMaterial.x
            to: beGetedAnimation.target.x + beGetedAnimation.target.width / 2 - bigMaterial.width / 2
            duration: Tool.getDistance(
                          Qt.point(bigMaterial.x, bigMaterial.y),
                          Qt.point(beGetedAnimation.target.x, beGetedAnimation.target.y)) * 1
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: xbeGetedAnimation.target
            property: "y"
            from: bigMaterial.y
            to: beGetedAnimation.target.y - bigMaterial.height / 2
            duration: xbeGetedAnimation.duration
            easing.type: xbeGetedAnimation.easing.type
        }

        onStopped: {
            getSound.play()
            // 残渣掉落动画（数量随 tier 增加）
            var particleCount = 6 + (bigMaterial.tier - 1) * 4
            for (var i = 0; i < particleCount; i++) {
                var radius = 13 * bigMaterial.scaleFactor
                var angle = Math.random() * 2 * 3.14159
                var dx = Math.cos(angle) * (Math.random() * bigMaterial.width * 4 - bigMaterial.width * 2)
                var dy = Math.sin(angle) * (Math.random() * bigMaterial.width * 4 - bigMaterial.width * 2) + bigMaterial.width * 1.5
                bigMaterial.makeResidue(
                            target.x + target.width / 2, target.y,
                            dx, dy, radius, gameArea)
            }
            target.getMaterial(bigMaterial)
            bigMaterial.visible = false
            bigMaterial.destroy(700)
        }
    }

    function makeResidue(x, y, dx, dy, width, parent) {
        ParticlePool.spawnDebris(x, y, dx, dy, width, parent)
    }
}
