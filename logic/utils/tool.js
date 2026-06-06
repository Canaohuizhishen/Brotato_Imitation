.pragma library

var _COMPONENT_READY = 2   // Component.Ready (enum value 2) — QML JS 引擎不暴露 Component 枚举
var _COMPONENT_LOADING = 1 // Component.Loading

function getDistance(p1,p2){
    var dx=p1.x-p2.x
    var dy=p1.y-p2.y
    return Math.sqrt(dx*dx+dy*dy)
}

function reduceAbs(n,reduction){
    if(n>0)return n-Math.abs(reduction)
    else return n+Math.abs(reduction)
}

function getQuadrant(angle){
    while(angle<0)angle+=360
    if(angle%360<90)return 1
    else if(angle%360<180)return 2
    else if(angle%360<270)return 3
    else return 4
}

function approximatelyEqual(a, b, epsilon = 1e-6) {
    return Math.abs(a - b) < epsilon;
}

function getMirrorX(x,targetX){
    var newX=x+(targetX-x)*2
    return newX
}

// ---- 文本对象池 ----
var _textPool = []
var _textPoolSize = 30
var _textPoolIndex = 0
var _textComp = null

function _ensureTextPool(parent) {
    if (_textComp === null) {
        _textComp = Qt.createComponent("../../particles/DamageText.qml")
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
            console.error("Tool: failed to load DamageText:", _textComp.errorString())
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

// 内联创建文本的后备方案（对象池不可用时使用）
// 字符串转义防止 QML 注入
function _qmlEscape(str) {
    return String(str).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r')
}

function createText(parent, text, size, color, _x, _y, duration, OutlineColor) {
    _ensureTextPool(parent)
    var t = _textPool[_textPoolIndex]
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
            "inlineDamageText"
        )
    }
}
