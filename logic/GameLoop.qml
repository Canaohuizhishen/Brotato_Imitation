import QtQuick 2.15

Item {
    id: gameLoop

    property bool active: false
    property bool paused: false
    property double deltaTime: 0.016
    property double realDeltaTime: 0.016  // 未 cap 的原始 deltaTime，用于 FPS 计算
    property int frameCount: 0

    // 各频率回调注册表
    property var perFrameCallbacks: []       // 每帧：怪物移动、子弹移动、玩家移动
    property var per100msCallbacks: []       // 约 100ms：武器瞄准
    property var per200msCallbacks: []       // 约 200ms：掉落拾取、怪物间碰撞
    property var per500msCallbacks: []       // 约 500ms：怪物生成决策
    property var per1000msCallbacks: []      // 约 1000ms：Prayer 存在时间计数
    property var per2000msCallbacks: []      // 约 2000ms：Scavenger 随机移动、Pursuer 加速
    property var per3000msCallbacks: []      // 约 3000ms：波次怪物生成

    property double _lastTime: 0

    Timer {
        id: tickTimer
        interval: 16  // ~62.5 FPS
        running: gameLoop.active && !gameLoop.paused
        repeat: true
        onTriggered: {
            var now = Date.now()
            var rawDt = gameLoop._lastTime > 0 ? (now - gameLoop._lastTime) / 1000.0 : 0.016
            gameLoop.realDeltaTime = rawDt
            gameLoop.deltaTime = Math.min(rawDt, 0.1)  // cap at 100ms to avoid spiral
            gameLoop._lastTime = now
            gameLoop.frameCount++

            // -- 每帧回调 --
            var i
            for (i = 0; i < perFrameCallbacks.length; i++) {
                perFrameCallbacks[i](gameLoop.deltaTime)
            }

            // -- 约 100ms (每 ~6 帧) --
            if (frameCount % 6 === 0) {
                for (i = 0; i < per100msCallbacks.length; i++) {
                    per100msCallbacks[i]()
                }
            }

            // -- 约 200ms (每 ~12 帧) --
            if (frameCount % 12 === 0) {
                for (i = 0; i < per200msCallbacks.length; i++) {
                    per200msCallbacks[i]()
                }
            }

            // -- 约 500ms (每 ~31 帧) --
            if (frameCount % 31 === 0) {
                for (i = 0; i < per500msCallbacks.length; i++) {
                    per500msCallbacks[i]()
                }
            }

            // -- 约 1000ms (每 ~62 帧) --
            if (frameCount % 62 === 0) {
                for (i = 0; i < per1000msCallbacks.length; i++) {
                    per1000msCallbacks[i]()
                }
            }

            // -- 约 2000ms (每 ~125 帧) --
            if (frameCount % 125 === 0) {
                for (i = 0; i < per2000msCallbacks.length; i++) {
                    per2000msCallbacks[i]()
                }
            }

            // -- 约 3000ms (每 ~187 帧) --
            if (frameCount % 187 === 0) {
                for (i = 0; i < per3000msCallbacks.length; i++) {
                    per3000msCallbacks[i]()
                }
            }
        }
    }

    // ---- 注册/注销接口 ----
    function registerPerFrame(callback)     { perFrameCallbacks.push(callback) }
    function registerPer100ms(callback)     { per100msCallbacks.push(callback) }
    function registerPer200ms(callback)     { per200msCallbacks.push(callback) }
    function registerPer500ms(callback)     { per500msCallbacks.push(callback) }
    function registerPer1000ms(callback)    { per1000msCallbacks.push(callback) }
    function registerPer2000ms(callback)    { per2000msCallbacks.push(callback) }
    function registerPer3000ms(callback)    { per3000msCallbacks.push(callback) }

    function removePerFrame(callback) {
        var idx = perFrameCallbacks.indexOf(callback)
        if (idx >= 0) perFrameCallbacks.splice(idx, 1)
    }
    function removePer100ms(callback) {
        var idx = per100msCallbacks.indexOf(callback)
        if (idx >= 0) per100msCallbacks.splice(idx, 1)
    }
    function removePer200ms(callback) {
        var idx = per200msCallbacks.indexOf(callback)
        if (idx >= 0) per200msCallbacks.splice(idx, 1)
    }
    function removePer500ms(callback) {
        var idx = per500msCallbacks.indexOf(callback)
        if (idx >= 0) per500msCallbacks.splice(idx, 1)
    }
    function removePer1000ms(callback) {
        var idx = per1000msCallbacks.indexOf(callback)
        if (idx >= 0) per1000msCallbacks.splice(idx, 1)
    }
    function removePer2000ms(callback) {
        var idx = per2000msCallbacks.indexOf(callback)
        if (idx >= 0) per2000msCallbacks.splice(idx, 1)
    }
    function removePer3000ms(callback) {
        var idx = per3000msCallbacks.indexOf(callback)
        if (idx >= 0) per3000msCallbacks.splice(idx, 1)
    }

    // ---- 重置 ----
    function reset() {
        _lastTime = 0
        frameCount = 0
        deltaTime = 0.016
    }
}
