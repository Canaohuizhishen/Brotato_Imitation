import QtQuick
import QtTest

TestCase {
    name: "GameLoopTests"

    // 用 Loader 按文件路径加载 GameLoop，避免 import "../logic" 需要 qmldir
    Loader {
        id: gameLoopLoader
        source: "../logic/GameLoop.qml"
        asynchronous: false
    }

    // 每个测试后清理 GameLoop 状态，防止测试间泄漏
    function cleanup() {
        var gl = gameLoopLoader.item
        if (gl) {
            gl.active = false
            gl.paused = false
            gl.reset()
        }
    }

    function test_initState() {
        var gl = gameLoopLoader.item
        // 初始状态：不活跃，deltaTime 为默认值
        compare(gl.active, false)
        compare(gl.frameCount, 0)
        compare(gl.deltaTime, 0.016)
    }

    function test_registerAndTick() {
        var gl = gameLoopLoader.item
        var calledCount = 0
        var capturedDt = -1

        gl.registerPerFrame(function(dt) {
            calledCount++
            capturedDt = dt
        })

        // 激活 GameLoop，等待至少触发一帧
        gl.active = true
        tryVerify(function() { return calledCount > 0; })

        gl.active = false
        verify(capturedDt > 0, "deltaTime 应 > 0")
    }

    function test_removePerFrame() {
        var gl = gameLoopLoader.item
        var calledCount = 0

        var cb = function() { calledCount++ }
        gl.registerPerFrame(cb)
        gl.removePerFrame(cb)

        gl.active = true
        wait(50)
        gl.active = false

        compare(calledCount, 0, "移除后回调不应再被调用")
    }

    function test_registerWithTarget() {
        var gl = gameLoopLoader.item
        var target = this
        var calledOnTarget = false

        gl.registerPerFrame(target, function() {
            calledOnTarget = true
        })

        gl.active = true
        tryVerify(function() { return calledOnTarget; })
        gl.active = false
    }

    function test_pause() {
        var gl = gameLoopLoader.item
        var calledWhilePaused = 0

        gl.registerPerFrame(function() { calledWhilePaused++ })

        gl.active = true
        tryVerify(function() { return calledWhilePaused > 0; })

        gl.paused = true
        var before = calledWhilePaused
        wait(50)
        var after = calledWhilePaused

        gl.active = false
        gl.paused = false

        // 暂停期间 calledWhilePaused 不应增加
        compare(before, after, "暂停期间回调不应触发")
    }

    function test_reset() {
        var gl = gameLoopLoader.item
        gl.registerPerFrame(function() {})
        gl.active = true
        tryVerify(function() { return gl.frameCount > 0; })
        gl.active = false

        gl.reset()
        compare(gl.frameCount, 0)
        compare(gl.deltaTime, 0.016)
    }

    function test_duplicateRegistrationDeduped() {
        var gl = gameLoopLoader.item
        var before = gl.perFrameCallbacks.length
        var cb = function() {}
        gl.registerPerFrame(this, cb)
        gl.registerPerFrame(this, cb)
        compare(gl.perFrameCallbacks.length, before + 1, "重复注册同一 target+func 应被去重")
        gl.removePerFrame(this, cb)
    }

    function test_unregisterRemovesAllCopies() {
        var gl = gameLoopLoader.item
        var calledCount = 0
        var cb = function() { calledCount++ }
        gl.registerPerFrame(this, cb)
        gl.registerPerFrame(this, cb)
        gl.removePerFrame(this, cb)

        gl.active = true
        wait(80)
        gl.active = false

        compare(calledCount, 0, "一次注销后不应再有回调触发（无重复/悬空残留）")
    }

    // ---- 分频桶时间语义（确定性驱动 advanceBuckets，不经真实帧时钟） ----

    function test_advanceBuckets_1000ms_3000ms_cadence() {
        var gl = gameLoopLoader.item
        gl.reset()
        var c1000 = 0, c3000 = 0
        gl.registerPer1000ms(function() { c1000++ })
        gl.registerPer3000ms(function() { c3000++ })
        // 模拟 6 秒：0.1s × 60 帧 → 1000ms 桶 6 次、3000ms 桶 2 次
        for (var i = 0; i < 60; i++) gl.advanceBuckets(0.1)
        compare(c1000, 6, "1000ms 桶：6s 内应触发 6 次")
        compare(c3000, 2, "3000ms 桶：6s 内应触发 2 次")
    }

    function test_advanceBuckets_100ms_200ms_cadence() {
        var gl = gameLoopLoader.item
        gl.reset()
        var c100 = 0, c200 = 0
        gl.registerPer100ms(function() { c100++ })
        gl.registerPer200ms(function() { c200++ })
        // 模拟 2 秒：0.1s × 20 帧 → 100ms 桶 20 次、200ms 桶 10 次
        for (var i = 0; i < 20; i++) gl.advanceBuckets(0.1)
        compare(c100, 20, "100ms 桶：2s 内应触发 20 次")
        compare(c200, 10, "200ms 桶：2s 内应触发 10 次")
    }

    function test_advanceBuckets_frameRateIndependent() {
        var gl = gameLoopLoader.item
        // 同一总时长 1 秒，两种“帧率”（0.1s/帧 vs 0.05s/帧）触发次数必须一致
        gl.reset()
        var c500 = 0
        gl.registerPer500ms(function() { c500++ })
        for (var i = 0; i < 10; i++) gl.advanceBuckets(0.1)
        var firesLowFps = c500
        gl.reset()
        c500 = 0   // 计数器归零：只比较第二段（0.05s 步长）的增量
        for (var j = 0; j < 20; j++) gl.advanceBuckets(0.05)
        compare(c500, firesLowFps, "500ms 桶触发次数应与模拟帧率无关")
        compare(firesLowFps, 2, "1s 内 500ms 桶应触发 2 次")
    }

    function test_advanceBuckets_resetClears() {
        var gl = gameLoopLoader.item
        gl.reset()
        var c500 = 0
        gl.registerPer500ms(function() { c500++ })
        // 先累积 0.45s（不足 0.5s，不应触发）
        for (var i = 0; i < 9; i++) gl.advanceBuckets(0.05)
        compare(c500, 0)
        // reset 清零余数：再累积 0.1s 仍不应触发（若余数未清则 0.45+0.1 已跨拍）
        gl.reset()
        gl.advanceBuckets(0.1)
        compare(c500, 0, "reset() 应清零分频桶余数")
    }

    // ---- resetSpawnPhase：整波重开专用（仅清 3000ms 出怪桶相位；其他分频刻意保留） ----

    function test_resetSpawnPhase_clearsOnly3000Bucket() {
        var gl = gameLoopLoader.item
        gl.reset()
        var c1000 = 0, c3000 = 0
        gl.registerPer1000ms(function() { c1000++ })
        gl.registerPer3000ms(function() { c3000++ })
        // 累积到 2.9s：3000ms 桶差一步未触发；1000ms 桶已触发 2 次
        for (var i = 0; i < 29; i++) gl.advanceBuckets(0.1)
        compare(c3000, 0, "2.9s 未满 3s 不应触发出怪桶")
        compare(c1000, 2, "2.9s 内 1000ms 桶应触发 2 次")
        // 复位出怪桶相位
        gl.resetSpawnPhase()
        gl.advanceBuckets(0.1)   // 未复位时 2.9s+0.1s 本应触发——复位后不得瞬刷
        compare(c3000, 0, "复位后不得瞬刷")
        compare(c1000, 3, "1000ms 桶相位不受复位影响")
        // 复位后累计再满 3s → 恰好触发一次
        for (i = 0; i < 29; i++) gl.advanceBuckets(0.1)
        compare(c3000, 1, "复位后满 3 秒整拍触发一次")
        compare(c1000, 5, "1000ms 桶继续正常节拍")
    }

    function test_bucketFiresInRealLoop() {
        var gl = gameLoopLoader.item
        gl.reset()
        var c200 = 0
        gl.registerPer200ms(function() { c200++ })
        // 真实 FrameAnimation 驱动（offscreen 下仍按渲染帧推进）：
        // 200ms 桶应在 2s 内至少触发一次（捕捉 advanceBuckets 未接入 onTriggered 的接线错误）
        gl.active = true
        tryVerify(function() { return c200 > 0; }, 2000)
        gl.active = false
    }
}
