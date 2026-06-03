import QtQuick 2.15
import "../components"

Weapon {
    id: rangedWeapon

    property bool _firstFireDone: false
    // 标记上一个 targetPoint 是否为 null，用于判断是否发生了"从无目标→锁定目标"的切换
    property bool _prevTargetWasNull: true

    onPausedChanged: {
        if(paused==true){
            fireTimer.pause()
        }else{
            fireTimer.resume()
        }
    }

    onTargetPointChanged: {
        if (targetPoint !== null) {
            if (_prevTargetWasNull) {
                // 从无目标→首次锁定目标：随机化初始开火延迟，避免多武器齐射
                var baseInterval = core.cooldown * 1000
                fireTimer.interval = baseInterval + Math.random() * baseInterval
                _firstFireDone = false
            }
            _prevTargetWasNull = false
        } else {
            _prevTargetWasNull = true
        }
    }

    TimerCanPause {
        id: fireTimer
        interval: rangedWeapon.core.cooldown*1000
        running: rangedWeapon.targetPoint!==null && rangedWeapon.active
        repeat: true
        onTriggered: {
            if(!rangedWeapon.isAiming && rangedWeapon.active) {
                rangedWeapon.fire()
                // 首次射击后恢复标准冷却间隔
                if (!rangedWeapon._firstFireDone) {
                    rangedWeapon._firstFireDone = true
                    fireTimer.interval = rangedWeapon.core.cooldown * 1000
                }
            }
        }
    }
}
