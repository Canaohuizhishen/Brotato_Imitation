import QtQuick
import QtTest
import "../page"

// PageManager 栈 API 单测（M0：行为零变化批次新增；-input 目录自动发现，免改 CMake）
// 覆盖：栈序、z 重算、onEnter/onExit 调用与次序、「不写下层 visible」不变量、防御分支
TestCase {
    name: "PageManagerTests"

    PageManager { id: pm }

    // ── 桩页面（普通 Item；A/B/C 带钩子，raw 无钩子验证可选性）──
    Item {
        id: stubA
        property int visibleChangedCount: 0
        property int enterCount: 0
        property int exitCount: 0
        property bool enterSawVisible: true
        onVisibleChanged: visibleChangedCount++
        function onEnter() { enterCount++; enterSawVisible = visible }
        function onExit() { exitCount++ }
    }
    Item {
        id: stubB
        property int visibleChangedCount: 0
        property int enterCount: 0
        property int exitCount: 0
        property bool enterSawVisible: true
        onVisibleChanged: visibleChangedCount++
        function onEnter() { enterCount++; enterSawVisible = visible }
        function onExit() { exitCount++ }
    }
    Item {
        id: stubC
        property int visibleChangedCount: 0
        property int enterCount: 0
        property int exitCount: 0
        property bool enterSawVisible: true
        onVisibleChanged: visibleChangedCount++
        function onEnter() { enterCount++; enterSawVisible = visible }
        function onExit() { exitCount++ }
    }
    Item {
        id: stubRaw
        property int visibleChangedCount: 0
        onVisibleChanged: visibleChangedCount++
    }

    function init() {
        // 每个用例前重置管理器与桩状态
        // Qt6 的 visible 读取含父级级联：qmltestrunner 根对象默认不可见，
        // 须显式置可见，否则所有子项 visible 一律读回 false（写入本身不受影响）
        visible = true
        pm.stack = []
        pm.pages = ({})
        pm.currentPage = ""
        var stubs = [["a", stubA], ["b", stubB], ["c", stubC], ["raw", stubRaw]]
        for (var i = 0; i < stubs.length; i++) {
            var s = stubs[i][1]
            s.visible = false          // 先落隐藏，再清零计数（避免上次用例残留触发计数）
            s.z = 0
            s.visibleChangedCount = 0
            if (s.enterCount !== undefined) {
                s.enterCount = 0
                s.exitCount = 0
                s.enterSawVisible = true
            }
            pm.register(stubs[i][0], s)
        }
    }

    function test_push_sets_visible_z_top() {
        pm.push("a")
        compare(stubA.visible, true)
        compare(stubA.z, 500)
        compare(pm.topId(), "a")
        compare(pm.isTop("a"), true)
        compare(pm.currentPage, "a")
    }

    function test_push_order_onEnter_before_visible() {
        pm.push("a")
        compare(stubA.enterCount, 1)
        compare(stubA.enterSawVisible, false)   // onEnter 执行时页面尚未可见（对齐 init→show 顺序）
        compare(stubA.visible, true)
    }

    function test_push_duplicate_ignored() {
        pm.push("a")
        pm.push("a")
        compare(pm.stack.length, 1)
    }

    function test_push_unregistered_ignored() {
        pm.push("nope")
        compare(pm.stack.length, 0)
    }

    function test_pop_hides_top_and_reveals_lower() {
        pm.push("a")
        pm.push("b")
        compare(stubB.z, 510)
        pm.pop()
        compare(stubB.visible, false)
        compare(stubB.exitCount, 1)
        compare(pm.topId(), "a")
        compare(stubA.visible, true)
    }

    function test_push_pop_not_write_lower_visible() {
        pm.push("a")                              // A: false→true（+1）
        pm.push("b")                              // A 不得被写
        compare(stubA.visibleChangedCount, 1)
        pm.pop()                                  // 揭开 A；A 仍为 true，不得产生 visible 变化
        compare(stubA.visibleChangedCount, 1)
        compare(stubB.visibleChangedCount, 2)     // B: false→true→false
    }

    function test_replace() {
        pm.push("a")
        pm.replace("b")
        compare(pm.stack.length, 1)
        compare(pm.topId(), "b")
        compare(stubA.visible, false)
        compare(stubB.visible, true)
        compare(stubB.z, 500)                     // replace 后序号归 0，z 重算
    }

    function test_clear_to_base() {
        pm.push("a"); pm.push("b"); pm.push("c")
        compare(stubC.z, 520)
        pm.clearToBase()
        compare(pm.stack.length, 0)
        compare(stubA.visible, false)
        compare(stubB.visible, false)
        compare(stubC.visible, false)
        compare(stubA.exitCount, 1)
        compare(stubB.exitCount, 1)
        compare(stubC.exitCount, 1)
        compare(pm.topId(), "")
        compare(pm.currentPage, "gameArea")
    }

    function test_z_recalc_after_pop() {
        pm.push("a"); pm.push("b"); pm.push("c")
        pm.pop()
        compare(stubC.visible, false)
        compare(stubA.z, 500)
        compare(stubB.z, 510)
    }

    function test_no_hooks_page_ok() {
        pm.push("raw")
        compare(stubRaw.visible, true)
        pm.pop()
        compare(stubRaw.visible, false)
        compare(pm.stack.length, 0)
    }

    function test_pop_empty_warns_no_crash() {
        pm.pop()
        compare(pm.stack.length, 0)
    }
}
