import QtQuick 2.15
import "../components"

Weapon {
    id: rangedWeapon

    onPausedChanged: {
        if(paused==true){
            fireTimer.pause()
        }else{
            fireTimer.resume()
        }
    }

    TimerCanPause {
        id: fireTimer
        interval: rangedWeapon.core.cooldown*1000
        running: rangedWeapon.targetPoint!==null && rangedWeapon.active
        repeat: true
        onTriggered: {
            if(!rangedWeapon.isAiming && rangedWeapon.active)rangedWeapon.fire()
        }
    }
}
