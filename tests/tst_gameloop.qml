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
}
