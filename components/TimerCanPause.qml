import QtQuick 2.15

//interval太小时不能使用
Item {
    id: pauseableTimer

    property int interval: 1000
    property bool running: false
    property bool repeat: false
    property bool triggeredOnStart: false

    property bool paused: false
    property int remaining: interval
    property int startTimestamp: 0        // 上次（开始/继续）时记录的时间戳
    property bool showDebugInfo: false
    signal triggered()

    onRunningChanged: {
        if (running) {
            if (paused) resume()
            else start()
        } else {
            stop()
        }
    }

    onRemainingChanged: {
        if(remaining<0)remaining=10
    }

    Timer {
        id: timer
        interval: pauseableTimer.interval
        running: false
        repeat: pauseableTimer.repeat
        triggeredOnStart: pauseableTimer.triggeredOnStart
        onTriggered: {
            pauseableTimer.triggered()

            // 重置暂停状态（不设置 running = false，否则会破坏外部 binding）
            pauseableTimer.paused  = false
            pauseableTimer.remaining = pauseableTimer.interval
            // resume() 会破坏 timer.interval 的绑定，每次触发后恢复为正确间隔
            // 否则暂停/继续循环会导致 interval 递归缩小 → 飞速倒计时
            timer.interval = pauseableTimer.interval
            if(pauseableTimer.showDebugInfo)console.log("Timer 触发，重置为初始状态")
            // 让 QML Timer 自身的 repeat 机制处理重复触发
            // 不要手动调用 start() 或设置 running = false（会破坏绑定以及导致无法停止）
        }
    }

    function start() {
        if (timer.running) return
        remaining = interval
        startTimestamp = Date.now()
        timer.interval = interval
        timer.start()
        timer.running = true
        paused  = false
        if(showDebugInfo)console.log("Timer 开始倒计时，时长:", interval, "ms")
    }

    function pause() {
        if (!timer.running || paused) return
        // 计算已过时间，更新 remaining
        var elapsed = Date.now() - startTimestamp
        remaining = timer.interval - elapsed
        timer.stop()
        timer.running = false
        paused = true
        if(showDebugInfo)console.log("Timer 已暂停，剩余:", remaining, "ms")
    }

    function resume() {
        if (!paused) return
        // 将剩余时间设为下一轮的 interval
        timer.interval = remaining
        startTimestamp = Date.now()
        timer.start()
        timer.running = true
        paused = false
        if(showDebugInfo)console.log("Timer 继续倒计时，还剩:", remaining, "ms")
    }

    function stop() {
        timer.stop()
        timer.running = false
        paused = false
        remaining = interval
        if(showDebugInfo)console.log("Timer 已停止，重置剩余时间为初始值")
    }

    function getRemainingTime() {
        if (timer.running) {
            var elapsed = Date.now() - startTimestamp
            // 保险起见，保证不小于 0
            remaining = Math.max(timer.interval - elapsed, 0)
            if(showDebugInfo)console.log("当前剩余时间:", remaining, "ms")
            return remaining
        }
        if(showDebugInfo)console.log("Timer 当前未运行（可能已暂停或已停止）")
        return remaining
    }
}
