import QtQuick
import QtTest
import "../logic/TextPool.js" as TextPool

TestCase {
    name: "CreateTextTests"

    // createText 没有返回值，它是副作用式的（将 Text 加到 parent 下）
    property var checkItem: Item { id: ci; objectName: "checkParent" }
    property var checkItem2: Item { id: ci2; objectName: "checkParent2" }
    property var checkItem3: Item { id: ci3; objectName: "checkParent3" }
    property var doomedItem: Item { id: doomed; objectName: "doomedParent" }
    property var doomedItem2: Item { id: doomed2; objectName: "doomedParent2" }

    // 注意：文本池（TextPool._textPool）是 .pragma library 的进程级共享状态，
    // 首个 createText 调用会一次性填充 30 个池对象并持续复用（复用时会重设 parent）。
    // 池对象的 QObject 父 = 填充时的 parent（复用重挂只改视觉父级）：QObject 父销毁后
    // 槽位成为死引用，由活性探测在复用/释放时自愈或跳过（文件内用例专门验证），
    // 因此本文件不清理子项，用例按池语义编写。

    function test_createText_poolFills() {
        // 回归用例：修复 _COMPONENT_READY/_COMPONENT_LOADING 常量错位后，池必须真正被填充
        TextPool.createText(checkItem, "测试文本", 20, "#ff0000", 100, 200, 600, "black")
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)
    }

    function test_createText_reusesPool() {
        TextPool.createText(checkItem, "Hello", 24, "#00ff00", 50, 60, 300, "white")
        TextPool.createText(checkItem, "World", 24, "#00ff00", 70, 80, 300, "white")
        compare(TextPool._textPool.length, 30, "复用期间池大小应保持 30 不发生增长")
        verify(checkItem.children.length > 0, "文本应挂在调用方 parent 下")
    }

    function test_createText_reparentPooledItem() {
        // 确保池已填充（与用例执行顺序无关）
        if (TextPool._textPool.length < 30)
            TextPool.createText(checkItem, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)

        var idx = TextPool._textPoolIndex
        TextPool.createText(checkItem2, "屏幕坐标文本", 40, "#fff", 0, 0, 2000)
        compare(TextPool._textPool[idx].parent, checkItem2, "复用时池对象应被重挂到新 parent 下")
    }

    function test_createText_multiple() {
        // 连续创建多个不崩溃
        TextPool.createText(checkItem, "A", 12, "#fff", 0, 0, 100, "black")
        TextPool.createText(checkItem, "B", 14, "#fff", 10, 10, 200, "black")
        TextPool.createText(checkItem, "C", 16, "#fff", 20, 20, 300, "black")
        verify(true, "多次 createText 不应崩溃")
    }

    function test_createText_defaultDuration() {
        // 不传 duration 和 outlineColor
        TextPool.createText(checkItem, "默认参数", 16, "#fff", 0, 0)
        verify(true, "默认参数不应崩溃")
    }

    function test_createText_qmlEscape() {
        // 包含特殊字符的文本
        TextPool.createText(checkItem, '他说"你好"\n新行', 18, "#f00", 10, 10)
        verify(true, "含引号和换行的文本不应崩溃")
    }

    function test_createText_releaseResetsPool() {
        // release 语义（回主菜单接线依赖）：清空并复位状态 → 下次 createText 惰性重建
        if (TextPool._textPool.length < 30)
            TextPool.createText(checkItem, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)

        TextPool.release()
        compare(TextPool._textPool.length, 0, "release 后池应为空")
        compare(TextPool._textPoolIndex, 0, "索引应归零")
        compare(TextPool._textComp, null, "组件引用应复位，下次惰性重建")

        // release 后仍可正常使用（惰性重建）
        TextPool.createText(checkItem, "释放后重建", 20, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)
        verify(checkItem.children.length > 0, "重建的池对象应挂在调用方 parent 下")
    }

    function test_createText_releaseWithDeadRefs() {
        // 守卫回归：死引用槽位下 release() 必须不中断、池完整复位。
        // （修复前：对死引用调用 .destroy() 抛 TypeError，循环中断、池残留不清）
        TextPool.release()   // 自包含：先清掉上例可能残留的混合状态
        TextPool.createText(doomedItem2, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)
        doomedItem2.destroy()
        wait(300)   // 等 deleteLater 生效
        verify(typeof TextPool._textPool[0].showText === "undefined",
               "前置：以 doomedItem2 为填充父重建的槽位应为死引用")

        TextPool.release()   // 目标：死引用下不抛错、不中断
        compare(TextPool._textPool.length, 0, "死引用下 release 仍应清空池")
        compare(TextPool._textPoolIndex, 0, "索引应归零")
        compare(TextPool._textComp, null, "组件引用应复位")

        // 复位后仍可正常惰性重建并复用
        TextPool.createText(checkItem3, "释放后重建", 20, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)
    }

    function test_createText_poolSelfHealsAfterParentDestroy() {
        // 回归：池对象的 QObject 父（= 填充时的 parent）销毁后，槽位引用仍为 truthy、
        // 方法读取为 undefined（typeof 判活性的依据）。构造真实死引用的可靠方式：
        // release 清空后以 doomedItem 为 parent 惰性重建，再销毁该父——仅重挂 parent
        // 只改视觉父级、不转移 QObject 所有权（实测），重挂式构造产生不了死引用。
        // （用例按函数名字母序执行，不能碰 checkItem/checkItem2——字母序靠后的用例还要用）
        TextPool.release()
        TextPool.createText(doomedItem, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return TextPool._textPool.length === 30 }, 5000)
        doomedItem.destroy()
        wait(300)   // 等 deleteLater 生效

        verify(typeof TextPool._textPool[0].showText === "undefined",
               "前置：以 doomedItem 为填充父重建的槽位应为死引用")

        var firstIdx = TextPool._textPoolIndex
        TextPool.createText(checkItem3, "回收文本 A", 20, "#fff", 0, 0)
        TextPool.createText(checkItem3, "回收文本 B", 20, "#fff", 0, 0)
        verify(checkItem3.children.length >= 2, "父销毁后两次 createText 均应正常挂载（池自愈，不抛错）")
        verify(!!TextPool._textPool[firstIdx] && TextPool._textPool[firstIdx].parent === checkItem3,
               "失效槽位应被重建为新池对象并挂到当前 parent")
    }
}
