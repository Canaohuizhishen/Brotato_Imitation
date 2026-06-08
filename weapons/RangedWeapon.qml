import QtQuick 2.15
import "../components"

Weapon {
    id: rangedWeapon

    // 标记上一个 targetPoint 是否为 null，用于判断是否发生了"从无目标→锁定目标"的切换
    property bool _prevTargetWasNull: true

    // 最大瞄准耗时估计（ms）：180° 旋转 × 0.5ms/deg × aimSpeedMultiplier
    // 用于首次锁定时的初始延迟，替代冷却时间作为第一枪等待时长
    readonly property double _maxAimMs: 90.0 * (aimSpeedMultiplier || 1.0)

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
                // 从无目标→首次锁定目标：以瞄准耗时替代冷却耗时作为初始延迟
                // 确保长冷却武器（冰锥等）第一枪不干等 1 秒多，同时保留随机化避免齐射
                var baseMs = Math.min(_maxAimMs, core.cooldown * 1000 * 0.5)
                fireTimer.interval = baseMs + Math.random() * baseMs * 0.5
                // stop + start 使新 interval 立即生效
                // TimerCanPause 的 start() 会断开 binding 用当前 interval 启动内部定时器
                fireTimer.stop()
                fireTimer.start()
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
        // 初始 interval 用瞄准耗时而非冷却：确保第一枪和重新锁定时快速响应
        interval: Math.min(rangedWeapon._maxAimMs, rangedWeapon.core.cooldown * 1000 * 0.5)
        running: rangedWeapon.targetPoint!==null && rangedWeapon.active
        repeat: true
        onTriggered: {
            if (!rangedWeapon.isAiming && rangedWeapon.active) {
                if (rangedWeapon.inFire) {
                    // 前一次 fire() 动画尚未结束，这是 QML Timer 的重复触发
                    // 只修正间隔，不开枪，避免双发
                    fireTimer.interval = rangedWeapon.core.cooldown * 1000
                    return
                }
                fireTimer.interval = rangedWeapon.core.cooldown * 1000
                rangedWeapon.fire()
            } else if (rangedWeapon.isAiming && rangedWeapon.active) {
                // 瞄准中：以瞄准耗时的一半作重试间隔
                // 确保翻转完成后快速开火，不等完整冷却间隔
                fireTimer.interval = Math.max(16, rangedWeapon._maxAimMs * 0.5)
            }
        }
    }
}
