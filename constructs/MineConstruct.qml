import QtQuick 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../logic/ParticlePool.js" as ParticlePool
import "../logic/utils/collision.js" as Collision

Construct {
    id: mine
    objectName: "MineConstruct"
    width: 30 * scaleFactor
    height: 30 * scaleFactor
    constructDamage: 15
    damageMultiplier: 3.0
    constructMaxHp: 1  // 一触即炸
    constructHp: constructMaxHp

    property bool isTriggered: false
    property int explosionRadius: 50
    property var gameArea: null

    // 地雷外观
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#884422"
        border.color: "#663311"
        border.width: 2
        opacity: 0.85

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.height * 0.5
            radius: width / 2
            color: "#cc6644"
        }
    }

    // 检测与怪物的碰撞（由 Constructs.qml 每帧调用）
    function checkMonsterCollision(monster) {
        if (isTriggered || isDestroy) return false
        if (monster.isDead || monster.isDestroy) return false

        // AABB 碰撞检测
        if (Collision.aabbCollide(this, monster)) {
            triggerExplosion(monster)
            return true
        }
        return false
    }

    function triggerExplosion(monster) {
        if (isTriggered) return
        isTriggered = true

        // 对触发怪物造成伤害
        var dmg = calcDamage()
        monster.monsterData.hp -= dmg
        if (SettingsData.showDamageNumbers) {
            var Tool = Qt.createQmlObject("import '../logic/utils/tool.js' as Tool; QtObject {}", mine)
        }

        // 爆炸视觉
        var expRadius = explosionRadius * scaleFactor
        if (gameArea && SettingsData.explosionEffect) {
            ParticlePool.spawnExplosion(x + width / 2, y + height / 2, expRadius, gameArea, SettingsData.explosionEffect)
        }

        // 对爆炸范围内的其他怪物造成伤害
        if (monster.owner && monster.owner.children) {
            var children = monster.owner.children
            for (var i = 0; i < children.length; i++) {
                var other = children[i]
                if (other === monster || other.isDead || other.isDestroy || other.objectName !== "Monster") continue
                var dx = (other.x + other.width / 2) - (x + width / 2)
                var dy = (other.y + other.height / 2) - (y + height / 2)
                var dist = Math.sqrt(dx * dx + dy * dy)
                if (dist < expRadius) {
                    other.monsterData.hp -= Math.floor(dmg * 0.5)  // 溅射 50%
                }
            }
        }

        // 销毁自己
        isDestroy = true
        destroy()
    }

    onPausedChanged: {
        // mine 不需要 pause 特殊处理
    }
}
