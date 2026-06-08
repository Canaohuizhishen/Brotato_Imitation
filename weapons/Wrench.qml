import QtQuick 2.15
import singleton.PlayerData
import "../components"

MeleeWeapon {
    id: wrench
    weaponName: "wrench"

    // 重写 createMeleeBullet：攻击时同时放置炮塔
    function createMeleeBullet(){
        if (!wrench.componentCache) return null
        var bullet = wrench.componentCache.createMeleeBullet(bulletsParent, {
            critical: core.critical,
            criticalDamageRate: core.criticalDamageRate,
            damage: core.damage
        })
        if (bullet) {
            bullet.target = wrench
            bullet.burningRatePercentage = PlayerData.burningRatePercentage
            bullet.burningRate = PlayerData.burningRate
        }

        // 特殊效果：在目标位置放置炮塔
        if (wrench.constructsContainer && wrench.targetPoint) {
            wrench.constructsContainer.placeConstruct("turret",
                wrench.targetPoint.x + wrench.parent.x,
                wrench.targetPoint.y + wrench.parent.y)
        }

        return bullet
    }
}
