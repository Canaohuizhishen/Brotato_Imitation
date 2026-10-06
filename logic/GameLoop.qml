import QtQuick

Item {
    id: gameLoop

    property bool active: false
    property bool paused: false
    property double deltaTime: 0.016
    property double realDeltaTime: 0.016  // 未 cap 的原始 deltaTime，用于 FPS 计算
    property int frameCount: 0

    // 各频率回调注册表（注册点：GameArea.qml 注册块、Monsters.qml 的 registerMonsterCallbacks）
    property var perFrameCallbacks: []       // 每帧：玩家/怪物移动、网格重建、怪物/子弹碰撞、瞄准、构筑物、磁吸
    property var per100msCallbacks: []       // 约 100ms：预留（暂无注册）
    property var per200msCallbacks: []       // 约 200ms：掉落拾取；子类怪物行为（Charger 距离/Sprayer/Summoner/Pursuer）
    property var per500msCallbacks: []       // 约 500ms：预留（暂无注册）
    property var per1000msCallbacks: []      // 约 1000ms：Prayer 存在时间计数
    property var per2000msCallbacks: []      // 约 2000ms：预留（暂无注册）
    property var per3000msCallbacks: []      // 约 3000ms：波次出怪；Prayer 攻击、Scavenger 换向

    property double _lastTime: 0

    // 帧驱动触发：跟随渲染帧节奏（而非自由跑的 16ms Timer）。
    // 自由跑的 Timer 在部分系统上会与 vsync 相位互锁：进入战斗约十秒后
    // 锁定在 30 FPS（33.3ms/帧）且清场后也不再恢复，帧驱动无此问题。
    FrameAnimation {
        id: tickTimer
        running: gameLoop.active && !gameLoop.paused
        onRunningChanged: {
            if (!running) gameLoop._lastTime = 0
        }
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
                perFrameCallbacks[i].func.call(perFrameCallbacks[i].target, gameLoop.deltaTime)
            }

            // -- 约 100ms (每 ~6 帧) --
            if (frameCount % 6 === 0) {
                for (i = 0; i < per100msCallbacks.length; i++) {
                    per100msCallbacks[i].func.call(per100msCallbacks[i].target)
                }
            }

            // -- 约 200ms (每 ~12 帧) --
            if (frameCount % 12 === 0) {
                for (i = 0; i < per200msCallbacks.length; i++) {
                    per200msCallbacks[i].func.call(per200msCallbacks[i].target)
                }
            }

            // -- 约 500ms (每 ~31 帧) --
            if (frameCount % 31 === 0) {
                for (i = 0; i < per500msCallbacks.length; i++) {
                    per500msCallbacks[i].func.call(per500msCallbacks[i].target)
                }
            }

            // -- 约 1000ms (每 ~62 帧) --
            if (frameCount % 62 === 0) {
                for (i = 0; i < per1000msCallbacks.length; i++) {
                    per1000msCallbacks[i].func.call(per1000msCallbacks[i].target)
                }
            }

            // -- 约 2000ms (每 ~125 帧) --
            if (frameCount % 125 === 0) {
                for (i = 0; i < per2000msCallbacks.length; i++) {
                    per2000msCallbacks[i].func.call(per2000msCallbacks[i].target)
                }
            }

            // -- 约 3000ms (每 ~187 帧) --
            if (frameCount % 187 === 0) {
                for (i = 0; i < per3000msCallbacks.length; i++) {
                    per3000msCallbacks[i].func.call(per3000msCallbacks[i].target)
                }
            }
        }
    }

    // ---- 注册/注销接口 ----
    // 重载：registerPerXxx(target, func) — 上下文感知模式
    //       registerPerXxx(func)          — 传统模式（向前兼容）
    // 同一 {target, func} 重复注册会被去重，防止调用方重复注册导致一份回调被调用两次
    function _pushCallback(list, target_or_func, func_or_undefined) {
        var target = func_or_undefined !== undefined ? target_or_func : null
        var func = func_or_undefined !== undefined ? func_or_undefined : target_or_func
        for (var i = 0; i < list.length; i++) {
            if (list[i].target === target && list[i].func === func) return
        }
        list.push({ target: target, func: func })
    }
    function registerPerFrame(a, b)         { _pushCallback(perFrameCallbacks, a, b) }
    function registerPer100ms(a, b)         { _pushCallback(per100msCallbacks, a, b) }
    function registerPer200ms(a, b)         { _pushCallback(per200msCallbacks, a, b) }
    function registerPer500ms(a, b)         { _pushCallback(per500msCallbacks, a, b) }
    function registerPer1000ms(a, b)        { _pushCallback(per1000msCallbacks, a, b) }
    function registerPer2000ms(a, b)        { _pushCallback(per2000msCallbacks, a, b) }
    function registerPer3000ms(a, b)        { _pushCallback(per3000msCallbacks, a, b) }

    // 重载：removePerXxx(target, func) — 按目标+函数对移除
    //       removePerXxx(func)          — 传统函数引用移除（向前兼容）
    // 删除所有匹配项（含历史遗留的重复注册），避免悬空回调残留
    function _removeCallback(list, a, b) {
        for (var i = list.length - 1; i >= 0; i--) {
            if (b !== undefined) {
                if (list[i].target === a && list[i].func === b) list.splice(i, 1)
            } else {
                if (list[i].func === a) list.splice(i, 1)
            }
        }
    }
    function removePerFrame(a, b)           { _removeCallback(perFrameCallbacks, a, b) }
    function removePer100ms(a, b)           { _removeCallback(per100msCallbacks, a, b) }
    function removePer200ms(a, b)           { _removeCallback(per200msCallbacks, a, b) }
    function removePer500ms(a, b)           { _removeCallback(per500msCallbacks, a, b) }
    function removePer1000ms(a, b)          { _removeCallback(per1000msCallbacks, a, b) }
    function removePer2000ms(a, b)          { _removeCallback(per2000msCallbacks, a, b) }
    function removePer3000ms(a, b)          { _removeCallback(per3000msCallbacks, a, b) }

    // ---- 重置 ----
    function reset() {
        _lastTime = 0
        frameCount = 0
        deltaTime = 0.016
    }
}
