import QtQuick 2.15
import singleton.PlayerData
import "../logic/utils/tool.js" as Tool
import "../components"

Construct {
    id: turret
    objectName: "TurretConstruct"
    width: 40 * scaleFactor
    height: 40 * scaleFactor
    constructDamage: 8
    damageMultiplier: 1.5
    constructMaxHp: 5
    constructHp: constructMaxHp

    property int fireRange: 400
    property double fireInterval: 1000  // ms
    property var bulletsParent: null
    property var componentCache: null

    // 炮台外观
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#4488cc"
        border.color: "#2266aa"
        border.width: 2
        opacity: 0.9

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.35
            height: parent.height * 0.35
            radius: width / 2
            color: "#aaddff"
        }
    }

    // 血条
    Rectangle {
        anchors.bottom: parent.top
        anchors.bottomMargin: 2 * scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 4 * scaleFactor
        color: "#333"
        radius: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 1
            width: (parent.width - 2) * (constructHp / constructMaxHp)
            color: "#44cc44"
            radius: 1
        }
    }

    // 射击定时器
    TimerCanPause {
        id: fireTimer
        interval: turret.fireInterval
        running: target !== null && !paused
        repeat: true
        onTriggered: {
            if (!target || target.isDead || target.isDestroy) return
            if (!componentCache || !bulletsParent) return

            // 创建子弹
            var bullet = componentCache.createRoundMovingBullet(bulletsParent, {})
            if (!bullet) return

            var cx = x + width / 2
            var cy = y + height / 2
            var tx = target.x + target.width / 2
            var ty = target.y + target.height / 2
            var dx = tx - cx
            var dy = ty - cy
            var dist = Math.sqrt(dx * dx + dy * dy)
            if (dist < 1) return

            var angle = Math.atan2(-dy, dx) * (180 / Math.PI)

            bullet.scaleFactor = scaleFactor
            bullet.width = 20 * scaleFactor
            bullet.height = bullet.width * 0.28
            bullet.x = cx - bullet.width / 2
            bullet.y = cy - bullet.height / 2
            bullet.originPoint = Qt.point(cx - bullet.width / 2, cy - bullet.height / 2)
            bullet.color = Qt.rgba(0.3, 0.7, 1.0, 1)
            bullet.damage = calcDamage()
            bullet.fireRate = dist / (fireRange / 1000)
            bullet.fireRange = dist
            bullet.shootAngle = angle
        }
    }

    onPausedChanged: {
        if (paused) fireTimer.pause()
        else if (target !== null) fireTimer.resume()
    }
}
