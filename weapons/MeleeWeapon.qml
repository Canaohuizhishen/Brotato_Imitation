import QtQuick 2.15
import singleton.PlayerData
import "../components"

Weapon {
    id: meleeWeapon
    property var meleeBullet
    property var componentCache: null

    onPausedChanged: {
        if(paused==true){
            fireTimer.pause()
        }else{
            fireTimer.resume()
        }
    }

    Component.onCompleted: {
        createMeleeBulletTimer.start()
    }

    onActiveChanged: {
        // 只在 active==true 且子弹不存在时创建，避免 addWeapon 设 binding 时误创建
        if (active && (!meleeBullet || meleeBullet.isDestroy)) {
            meleeWeapon.meleeBullet=meleeWeapon.createMeleeBullet()
        }
    }

    Timer {
        id: createMeleeBulletTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            meleeWeapon.meleeBullet=meleeWeapon.createMeleeBullet()
        }
    }

    TimerCanPause {
        id: fireTimer
        interval: meleeWeapon.core.cooldown*1000
        running: meleeWeapon.targetPoint!==null && meleeWeapon.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            meleeWeapon.inCoolDown=false
        }
    }

    TimerCanPause {
        id: checkFireTimer
        // 基于 attackTime 动态调整轮询粒度：慢速武器用满 150ms，快速武器自动收紧
        interval: Math.min(150, Math.max(30, meleeWeapon.core.attackTime * 750))
        running: meleeWeapon.targetPoint!==null && meleeWeapon.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(!meleeWeapon.inCoolDown && !meleeWeapon.inFire && !meleeWeapon.isAiming && meleeWeapon.rotation!==0 && meleeWeapon.rotation!==180){
                meleeWeapon.fire()
                meleeWeapon.inCoolDown=true
            }
        }
    }

    function createMeleeBullet(){
        if (!meleeWeapon.componentCache) return null
        // 先创建子弹（只传非 target 属性）
        var bullet = meleeWeapon.componentCache.createMeleeBullet(bulletsParent, {
            critical: core.critical,
            criticalDamageRate: core.criticalDamageRate,
            damage: core.damage
        })
        if (bullet) {
            // target 在 createObject 之后设置，此时子弹已完全初始化
            bullet.target = meleeWeapon
            // 燃烧属性（melee 也可以触发燃烧）
            bullet.burningRatePercentage = PlayerData.burningRatePercentage
            bullet.burningRate = PlayerData.burningRate
        } else {
            console.error("Error loading component: MeleeBullet.qml")
        }
        return bullet
    }
}
