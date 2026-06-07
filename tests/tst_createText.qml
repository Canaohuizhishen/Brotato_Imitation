import QtQuick
import QtTest
import "../logic/utils/tool.js" as Tool

TestCase {
    name: "CreateTextTests"

    // createText 没有返回值，它是副作用式的（将 Text 加到 parent 下）
    property var checkItem: Item { id: ci; objectName: "checkParent" }

    // 每个测试后清理子项，防止累积影响后续测试
    function cleanup() {
        for (var i = checkItem.children.length - 1; i >= 0; i--) {
            checkItem.children[i].destroy()
        }
    }

    function test_createText_doesNotCrash() {
        // 最基本：不崩溃
        Tool.createText(checkItem, "测试文本", 20, "#ff0000", 100, 200, 600, "black")
        verify(true, "createText 不应崩溃")
    }

    function test_createText_addsChild() {
        var before = checkItem.children.length
        Tool.createText(checkItem, "Hello", 24, "#00ff00", 50, 60, 300, "white")
        // 应有一个 Text 子项被加到 parent
        verify(checkItem.children.length > before, "createText 应在 parent 下添加子项")
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
}
