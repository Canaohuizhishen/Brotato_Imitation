import QtQuick 2.15
import "../components"

Weapon {
    id: meleeWeapon

    onPausedChanged: {
        if(paused==true){
            fireTimer.pause()
        }else{
            fireTimer.resume()
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
}
