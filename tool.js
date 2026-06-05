.pragma library

var _COMPONENT_READY = 1  // Component.Ready — QML JS 引擎不暴露 Component 枚举

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
        _textComp = Qt.createComponent("particles/DamageText.qml")
        if (_textComp.status !== _COMPONENT_READY) {
            _textComp = Qt.createComponent("../particles/DamageText.qml")
        }
    }
    while (_textPool.length < _textPoolSize) {
        var t = _textComp.createObject(parent)
        if (t) {
            t.visible = false
            _textPool.push(t)
        }
    }
}

function createText(parent, text, size, color, _x, _y, duration, OutlineColor) {
    _ensureTextPool(parent)
    var t = _textPool[_textPoolIndex]
    _textPoolIndex = (_textPoolIndex + 1) % _textPoolSize
    if (t) {
        t.showText(text, size, color, _x, _y, duration || 600, OutlineColor || "black")
    }
}
