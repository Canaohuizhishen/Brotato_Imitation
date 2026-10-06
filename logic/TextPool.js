.pragma library

// 浮动文本对象池 — 30 个 FloatingText 环形复用（伤害数字/回血/闪避/拾取提示/波次大字）
// 由 logic/utils/tool.js 拆分而来：池是有状态的资源管理，与无状态数学工具职责分离。
//
// 注意：池对象若随其父对象被销毁，QML 中残留的 JS 引用仍为 truthy，
// 但方法读取为 undefined、调用会抛 TypeError（Qt 6 实测）。
// 复用前用 typeof 探测活性，失效槽位即时重建（自愈）。

// Component.Status 枚举：Null=0, Ready=1, Loading=2, Error=3
// （QML JS 引擎不暴露 Component 枚举，故手写数值；tst_createText 的池填充用例钉住语义）
var _COMPONENT_READY = 1
var _COMPONENT_LOADING = 2

var _textPool = []
var _textPoolSize = 30
var _textPoolIndex = 0
var _textComp = null

function _ensureTextPool(parent) {
    if (_textComp === null) {
        _textComp = Qt.createComponent("../particles/FloatingText.qml")
        // 异步加载可能未完成，由 statusChanged 回调填充池子
        if (_textComp.status === _COMPONENT_LOADING) {
            _textComp.statusChanged.connect(function() {
                if (_textComp.status === _COMPONENT_READY) {
                    _fillTextPool(parent)
                }
            })
            return
        }
        if (_textComp.status !== _COMPONENT_READY) {
            console.error("TextPool: failed to load FloatingText:", _textComp.errorString())
            _textComp = null
            return
        }
        _fillTextPool(parent)
    }
}

function _fillTextPool(parent) {
    var maxAttempts = _textPoolSize
    while (_textPool.length < _textPoolSize && maxAttempts-- > 0) {
        var t = _textComp.createObject(parent)
        if (t) {
            t.visible = false
            _textPool.push(t)
        } else {
            break
        }
    }
}

// 在当前槽位新建一个池对象并占用（供空缺/失效槽位自愈）；组件不可用或创建失败时返回 null
function _createPoolItem(parent) {
    if (_textComp === null || _textComp.status !== _COMPONENT_READY) return null
    var t = _textComp.createObject(parent)
    if (!t) return null
    t.visible = false
    _textPool[_textPoolIndex] = t
    return t
}

// 内联创建文本的后备方案（对象池不可用时使用）
// 字符串转义防止 QML 注入
function _qmlEscape(str) {
    return String(str).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r')
}

function createText(parent, text, size, color, _x, _y, duration, OutlineColor) {
    _ensureTextPool(parent)
    var t = _textPool[_textPoolIndex]
    // 池对象可能已随其父对象被销毁：销毁后的引用仍为 truthy，
    // 但方法调用会抛 TypeError（Qt 6 实测），先探测活性，失效槽位置空
    if (t && typeof t.showText !== "function") {
        _textPool[_textPoolIndex] = null
        t = null
    }
    // 槽位空缺（池未填充/组件加载中）或刚失效：尝试即时重建当前槽位（池自愈）
    if (!t)
        t = _createPoolItem(parent)
    if (t) {
        _textPoolIndex = (_textPoolIndex + 1) % _textPoolSize
        // 重设父对象为当前调用者：
        // - 伤害数字/拾取文字以 monsters 为父（世界坐标定位）
        // - 通过/胜利/战败文字以 gameWindow 为父（屏幕坐标定位）
        // 如果不重设，首次 createText 调用时父对象被固化到对象池中
        // 导致所有复用文本的坐标空间与预期不符
        t.parent = parent
        t.showText(text, size, color, _x, _y, duration || 600, OutlineColor || "black")
    } else {
        // 对象池未就绪 → 内联创建（保证通过/胜利/战败文字即时显示）
        var safeText = _qmlEscape(text)
        var safeColor = _qmlEscape(color)
        var safeOutline = _qmlEscape(OutlineColor || "black")
        var dur = Math.floor(duration || 600)
        var fs = Math.floor(size)
        var posX = Math.floor(_x)
        var posY = Math.floor(_y)
        var inlineText = Qt.createQmlObject(
            "import QtQuick 2.15;\
            Text {\
                id: rt;\
                text: \"" + safeText + "\";\
                font.pixelSize: " + fs + ";\
                font.bold: true;\
                color: \"" + safeColor + "\";\
                x: " + posX + ";\
                y: " + posY + ";\
                style: Text.Outline;\
                styleColor: \"" + safeOutline + "\";\
                z: 10000;\
                opacity: 0;\
                visible: true;\
                SequentialAnimation {\
                    loops: 1; running: true;\
                    OpacityAnimator { target: rt; from: 0; to: 0.8; duration: " + (dur/2) + "; }\
                    OpacityAnimator { target: rt; from: 0.8; to: 0; duration: " + (dur/2) + "; }\
                    onStopped: rt.destroy();\
                }\
            }",
            parent,
            "inlineFloatingText"
        )
    }
}

// ---- 重置 ----
// 场景卸载（回主菜单）时调用：销毁全部池对象并复位（对齐 ParticlePool.release 语义）。
// 死引用槽位（QObject 父已销毁）按活性探测跳过，保证任何槽位状态下 release 都不中断。
// 调用后池为空，下一次 createText 会惰性重新填充。
function release() {
    for (var i = 0; i < _textPool.length; i++) {
        if (_textPool[i] && typeof _textPool[i].destroy === "function")
            _textPool[i].destroy()
    }
    _textPool = []
    _textPoolIndex = 0
    _textComp = null
}
