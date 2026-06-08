import QtQuick 2.15
import singleton.PlayerData
import "../components"

MeleeWeapon {
    id: screwdriver
    weaponName: "screwdriver"
    property double mineInterval: 12000  // L1: 12秒，随等级减少

    onGradeChanged: {
        // 特殊效果：地图上每隔12/9/6/3秒产生一颗地雷
        var intervals = [12000, 9000, 6000, 3000]
        mineInterval = intervals[Math.min(grade - 1, 3)]
        mineTimer.interval = mineInterval
    }

    // 重写 createMeleeBullet 以加入 engineering 伤害加成
    function createMeleeBullet(){
        if (!screwdriver.componentCache) return null
        var bullet = screwdriver.componentCache.createMeleeBullet(bulletsParent, {
            critical: core.critical,
            criticalDamageRate: core.criticalDamageRate,
            damage: core.damage + Math.floor(PlayerData.engineering * 0.5)
        })
        if (bullet) {
            bullet.target = screwdriver
            bullet.burningRatePercentage = PlayerData.burningRatePercentage
            bullet.burningRate = PlayerData.burningRate
        }
        return bullet
    }

    // 定时产雷计时器
    TimerCanPause {
        id: mineTimer
        interval: screwdriver.mineInterval
        running: screwdriver.active && PlayerData.isInCombat
        repeat: true
        onTriggered: {
            if (!screwdriver.constructsContainer) return
            // 在玩家附近随机位置放置地雷
            var playerCenter = Qt.point(
                screwdriver.constructsContainer.gameArea.player.x + screwdriver.constructsContainer.gameArea.player.width / 2,
                screwdriver.constructsContainer.gameArea.player.y + screwdriver.constructsContainer.gameArea.player.height / 2
            )
            var angle = Math.random() * 2 * Math.PI
            var dist = 80 + Math.random() * 120  // 距玩家 80~200 像素
            var mx = playerCenter.x + Math.cos(angle) * dist
            var my = playerCenter.y + Math.sin(angle) * dist
            // 钳制到地图内
            var gameArea = screwdriver.constructsContainer.gameArea
            mx = Math.max(30, Math.min(gameArea.width - 30, mx))
            my = Math.max(30, Math.min(gameArea.height - 30, my))
            screwdriver.constructsContainer.placeConstruct("mine", mx, my)
        }
    }
}
