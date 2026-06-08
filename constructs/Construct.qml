import QtQuick 2.15
import singleton.PlayerData

Item {
    id: construct
    objectName: "Construct"
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool paused: false
    property bool isDestroy: false
    property int constructHp: 10
    property int constructMaxHp: 10
    property int constructDamage: 5  // 基础伤害，由子类覆盖
    property double damageMultiplier: 1.0  // 工程学倍率，子类设置
    property var target: null  // 当前瞄准的怪物

    onConstructHpChanged: {
        if (constructHp <= 0) {
            isDestroy = true
            destroy()
        }
    }

    onPausedChanged: {
        // 子类可覆盖
    }

    // 由子类实现：每帧更新目标
    function updateTarget(monsterList) {
        // 默认实现：找最近的活怪物
        if (!monsterList || monsterList.length === 0) {
            target = null
            return
        }
        var nearest = null
        var minDist = Infinity
        var cx = x + width / 2
        var cy = y + height / 2
        for (var i = 0; i < monsterList.length; i++) {
            var m = monsterList[i]
            if (m.isDead || m.isDestroy) continue
            var dx = (m.x + m.width / 2) - cx
            var dy = (m.y + m.height / 2) - cy
            var d = dx * dx + dy * dy
            if (d < minDist) {
                minDist = d
                nearest = m
            }
        }
        target = nearest
    }

    // 计算最终伤害
    function calcDamage() {
        return Math.floor(Math.max(constructDamage + PlayerData.engineering * damageMultiplier, 1))
    }
}
