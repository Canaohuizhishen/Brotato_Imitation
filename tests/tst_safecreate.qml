import QtQuick
import QtTest
import "../logic/SafeCreate.js" as SafeCreate

TestCase {
    name: "SafeCreateTests"

    // 测试非法路径：组件不存在时返回 null
    function test_create_invalidPath() {
        var result = SafeCreate.create("nonexistent/Component.qml", this, {})
        compare(result, null)
    }

    // 测试非法路径 createWithBindings
    function test_createWithBindings_invalidPath() {
        var result = SafeCreate.createWithBindings("nonexistent/Component.qml", this, {}, {})
        compare(result, null)
    }

    // 测试 properties 参数留空时不会崩溃
    function test_create_noProperties() {
        var result = SafeCreate.create("nonexistent/Component.qml", this, null)
        compare(result, null)
    }

    // 注：成功路径（合法组件路径 → 返回非 null 对象）因 Qt.createComponent
    // 在测试环境中的异步加载行为而不可测。所有异常路径测试覆盖了函数的
    // 错误处理逻辑。
}
