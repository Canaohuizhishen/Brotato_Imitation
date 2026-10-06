import QtQuick
import QtTest
import "../logic/utils/tool.js" as Tool

TestCase {
    name: "CreateTextTests"

    // createText 没有返回值，它是副作用式的（将 Text 加到 parent 下）
    property var checkItem: Item { id: ci; objectName: "checkParent" }
    property var checkItem2: Item { id: ci2; objectName: "checkParent2" }
    property var checkItem3: Item { id: ci3; objectName: "checkParent3" }
    property var doomedItem: Item { id: doomed; objectName: "doomedParent" }

    // 注意：文本池（Tool._textPool）是 .pragma library 的进程级共享状态，
    // 首个 createText 调用会一次性填充 30 个池对象并持续复用（复用时会重设 parent）。
    // 池对象随父对象销毁后，槽位在下次复用时自愈重建（文件末尾用例专门验证），
    // 因此本文件不清理子项，用例按池语义编写。

    function test_createText_poolFills() {
        // 回归用例：修复 _COMPONENT_READY/_COMPONENT_LOADING 常量错位后，池必须真正被填充
        Tool.createText(checkItem, "测试文本", 20, "#ff0000", 100, 200, 600, "black")
        tryVerify(function() { return Tool._textPool.length === 30 }, 5000)
    }

    function test_createText_reusesPool() {
        Tool.createText(checkItem, "Hello", 24, "#00ff00", 50, 60, 300, "white")
        Tool.createText(checkItem, "World", 24, "#00ff00", 70, 80, 300, "white")
        compare(Tool._textPool.length, 30, "复用期间池大小应保持 30 不发生增长")
        verify(checkItem.children.length > 0, "文本应挂在调用方 parent 下")
    }

    function test_createText_reparentPooledItem() {
        // 确保池已填充（与用例执行顺序无关）
        if (Tool._textPool.length < 30)
            Tool.createText(checkItem, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return Tool._textPool.length === 30 }, 5000)

        var idx = Tool._textPoolIndex
        Tool.createText(checkItem2, "屏幕坐标文本", 40, "#fff", 0, 0, 2000)
        compare(Tool._textPool[idx].parent, checkItem2, "复用时池对象应被重挂到新 parent 下")
    }

    function test_createText_multiple() {
        // 连续创建多个不崩溃
        Tool.createText(checkItem, "A", 12, "#fff", 0, 0, 100, "black")
        Tool.createText(checkItem, "B", 14, "#fff", 10, 10, 200, "black")
        Tool.createText(checkItem, "C", 16, "#fff", 20, 20, 300, "black")
        verify(true, "多次 createText 不应崩溃")
    }

    function test_createText_defaultDuration() {
        // 不传 duration 和 outlineColor
        Tool.createText(checkItem, "默认参数", 16, "#fff", 0, 0)
        verify(true, "默认参数不应崩溃")
    }

    function test_createText_qmlEscape() {
        // 包含特殊字符的文本
        Tool.createText(checkItem, '他说"你好"\n新行', 18, "#f00", 10, 10)
        verify(true, "含引号和换行的文本不应崩溃")
    }

    function test_createText_poolSelfHealsAfterParentDestroy() {
        // 回归：销毁后的池对象引用仍为 truthy、方法调用会抛 TypeError。
        // 先把所有存活池对象重挂到专用父 doomedItem，销毁它即可确定性地让全部槽位失效。
        // （用例按函数名字母序执行，不能碰 checkItem/checkItem2——字母序靠后的用例还要用）
        if (Tool._textPool.length < 30)
            Tool.createText(doomedItem, "warmup", 12, "#fff", 0, 0)
        tryVerify(function() { return Tool._textPool.length === 30 }, 5000)
        for (var i = 0; i < Tool._textPool.length; i++) {
            if (Tool._textPool[i])
                Tool._textPool[i].parent = doomedItem
        }
        doomedItem.destroy()
        wait(200)   // 等待 deleteLater 生效

        var firstIdx = Tool._textPoolIndex
        Tool.createText(checkItem3, "回收文本 A", 20, "#fff", 0, 0)
        Tool.createText(checkItem3, "回收文本 B", 20, "#fff", 0, 0)
        verify(checkItem3.children.length >= 2, "父销毁后两次 createText 均应正常挂载（池自愈，不抛错）")
        verify(!!Tool._textPool[firstIdx] && Tool._textPool[firstIdx].parent === checkItem3,
               "失效槽位应被重建为新池对象并挂到当前 parent")
    }
}
