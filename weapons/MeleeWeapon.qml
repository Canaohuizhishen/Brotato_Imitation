import QtQuick 2.15
import "../components"

Weapon {
    id: meleeWeapon
    property var meleeBullet

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
        if(!meleeBullet)meleeWeapon.meleeBullet=meleeWeapon.createMeleeBullet()
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
        interval: 150
        running: meleeWeapon.targetPoint!==null && meleeWeapon.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(!meleeWeapon.inCoolDown && !meleeWeapon.isAiming && meleeWeapon.rotation!==0 && meleeWeapon.rotation!==180){
                meleeWeapon.fire()
                meleeWeapon.inCoolDown=true
            }
        }
    }

    function createMeleeBullet(){
        var bulletComponent = Qt.createComponent("../bullets/MeleeBullet.qml")
        if (bulletComponent.status === Component.Ready) {
            var bullet = bulletComponent.createObject(bulletsParent);
            bullet.target=meleeWeapon
            bullet.critical=core.critical
            bullet.criticalDamageRate=core.criticalDamageRate
            bullet.damage=core.damage
        }else console.error("Error loading component:", bulletComponent.errorString())
        return bullet
    }
}
