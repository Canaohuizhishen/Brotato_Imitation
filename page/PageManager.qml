import QtQuick 2.15

// PageManager（阶段 B：覆盖语义页面栈 — 最终版）
// ── 栈 API（覆盖语义的关键不变量：栈操作只触碰被 push/pop 的页面，绝不写下层的 visible）──
//   push(id)     → 校验注册/重复 → 入栈 → z 重算 → onEnter?() → visible = true
//   pop()        → 取栈顶 → onExit?() → visible = false → 出栈 → z 重算 → 新栈顶 forceActiveFocus()
//   replace(id)  → pop() + push(id)（同一帧内完成，等价于现行「hide A → show B」序列）
//   clearToBase() → 循环出栈；期间不做焦点操作（回到基座后由相位/调用方管理）
//   topId() / isTop(id) / isInStack(id) → 栈查询（调试/执行用；勿在声明式绑定内调用，见下方警告）
// 动态 z：z = 500 + 栈内序号×10，每次栈变更全体重算（高于基座层与非页层，低于 FPS 1000）
// 注意：pages/stack 是普通 JS 对象/数组，只做命令式读写，不参与声明式绑定
//       （QML 中数组元素改动不触发绑定更新，故 topId 等一律用函数而非绑定属性）
// ⚠ 切勿在 binding 中调用 topId() 等读取 stack 的函数：push/pop 原地改数组，不会触发绑定重算
//   （GameWindow 的 Esc 守卫曾因此冻结失效；守卫已改用可通知的 settingInterface.visible）
QtObject {
    id: pageManager

    property string currentPage: "start"
    property var pages: ({})
    property var stack: []

    function register(id, page) {
        if (pages[id]) {
            console.warn("PageManager: 重复注册页面 '" + id + "'")
        }
        pages[id] = page
    }

    function visibleNames() {
        var out = []
        for (var id in pages) {
            if (pages[id].visible) out.push(id)
        }
        return out.join(", ")
    }

    // ── v2 栈 API ──
    function topId() {
        return stack.length ? stack[stack.length - 1].id : ""
    }

    function isInStack(id) {
        for (var i = 0; i < stack.length; i++) {
            if (stack[i].id === id) return true
        }
        return false
    }

    function isTop(id) {
        return stack.length > 0 && stack[stack.length - 1].id === id
    }

    function push(id) {
        var p = pages[id]
        if (!p) {
            console.warn("PageManager.push: 页面未注册 '" + id + "'")
            return
        }
        if (isInStack(id)) {
            console.warn("PageManager.push: 页面已在栈内 '" + id + "'，忽略")
            return
        }
        stack.push({ id: id, page: p })
        recalcZ()
        if (p.onEnter) p.onEnter()
        p.visible = true
        currentPage = id
    }

    function pop() {
        if (!stack.length) {
            console.warn("PageManager.pop: 栈为空，忽略")
            return
        }
        var top = stack.pop()
        if (top.page.onExit) top.page.onExit()
        top.page.visible = false
        recalcZ()
        if (stack.length) {
            stack[stack.length - 1].page.forceActiveFocus()
        }
        currentPage = stack.length ? topId() : "gameArea"
    }

    function replace(id) {
        pop()
        push(id)
    }

    function clearToBase() {
        while (stack.length) {
            var top = stack.pop()
            if (top.page.onExit) top.page.onExit()
            top.page.visible = false
        }
        currentPage = "gameArea"
    }

    function recalcZ() {
        for (var i = 0; i < stack.length; i++) {
            stack[i].page.z = 500 + i * 10
        }
    }
}
