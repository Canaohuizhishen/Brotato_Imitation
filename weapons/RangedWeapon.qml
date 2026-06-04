import QtQuick 2.15
import "../components"

Weapon {
    id: rangedWeapon

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
            }
            _prevTargetWasNull = false
            // 坐标去重：只有位置真正变化 (超过 2px 阈值) 才重新瞄准
            if (!_lastTargetPoint
                || Math.abs(targetPoint.x - _lastTargetPoint.x) > 2
                || Math.abs(targetPoint.y - _lastTargetPoint.y) > 2) {
                if (inFire) {
                    _snapRotation()
                } else {
                    aimToTarget()
                }
                _lastTargetPoint = Qt.point(targetPoint.x, targetPoint.y)
            }
        } else {
            _prevTargetWasNull = true
            if (!inFire) {
                _lastTargetPoint = null
                rotationReset()
            }
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
                // 从 core 中读取当前冷却，确保攻速变化后即时生效
                fireTimer.interval = rangedWeapon.core.cooldown * 1000
            }
        }
    }
}
