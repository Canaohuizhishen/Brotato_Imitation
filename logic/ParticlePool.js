.pragma library

var _COMPONENT_READY = 1  // Component.Ready — QML JS 引擎不暴露 Component 枚举

/**
 * ParticlePool — 血花 + 残渣粒子对象池
 *
 * 预创建 N 个 BloodParticle 和 M 个 DebrisParticle 组件，循环复用。
 * 避免运行时重复调用 Qt.createQmlObject（每次 ~0.5-3ms 编译 + GC 压力）。
 *
 * 用法：
 *   import "../logic/ParticlePool.js" as ParticlePool
 *
 *   // 血花（怪物受击）
 *   ParticlePool.spawn(x, y, dx, dy, width, gameArea)
 *
 *   // 残渣（材料拾取）
 *   ParticlePool.spawnDebris(x, y, dx, dy, width, gameArea)
 */

// ---- 血花粒子池 ----
var _bloodPoolSize = 50
var _bloodPool = []
var _bloodIndex = 0
var _bloodInitialized = false
var _bloodComponent = null

function init(parent) {
    if (_bloodInitialized) return
    _bloodComponent = Qt.createComponent("../particles/BloodParticle.qml")
    for (var i = 0; i < _bloodPoolSize; i++) {
        var particle = _createBloodParticle(parent)
        if (particle) {
            particle.visible = false
            _bloodPool.push(particle)
        }
    }
    _bloodInitialized = true
    // 同时初始化残渣池
    _initDebris(parent)
}

function _createBloodParticle(parent) {
    if (!_bloodComponent || _bloodComponent.status !== _COMPONENT_READY) {
        _bloodComponent = Qt.createComponent("../particles/BloodParticle.qml")
    }
    if (_bloodComponent.status === _COMPONENT_READY)
        return _bloodComponent.createObject(parent)
    console.error("ParticlePool: failed to load BloodParticle.qml")
    return null
}

function spawn(x, y, dx, dy, width, parent) {
    if (!_bloodInitialized) init(parent)
    if (_bloodPool.length === 0) return

    var particle = _bloodPool[_bloodIndex]

    if (!particle) {
        particle = _createBloodParticle(parent)
        if (!particle) return
        _bloodPool[_bloodIndex] = particle
    }

    _bloodIndex = (_bloodIndex + 1) % _bloodPool.length

    if (particle.visible) {
        particle.visible = false
    }

    particle.x = x - width / 2
    particle.y = y - width / 2
    particle.particleWidth = width
    particle.targetDx = dx
    particle.targetDy = dy
    particle.restartAnimation()
}

// ---- 残渣粒子池（材料拾取） ----
var _debrisPoolSize = 30
var _debrisPool = []
var _debrisIndex = 0
var _debrisInitialized = false
var _debrisComponent = null

function _initDebris(parent) {
    if (_debrisInitialized) return
    _debrisComponent = Qt.createComponent("../particles/DebrisParticle.qml")
    for (var i = 0; i < _debrisPoolSize; i++) {
        var debris = _createDebrisParticle(parent)
        if (debris) {
            debris.visible = false
            _debrisPool.push(debris)
        }
    }
    _debrisInitialized = true
}

function _createDebrisParticle(parent) {
    if (!_debrisComponent || _debrisComponent.status !== _COMPONENT_READY) {
        _debrisComponent = Qt.createComponent("../particles/DebrisParticle.qml")
    }
    if (_debrisComponent.status === _COMPONENT_READY)
        return _debrisComponent.createObject(parent)
    console.error("ParticlePool: failed to load DebrisParticle.qml")
    return null
}

function spawnDebris(x, y, dx, dy, width, parent) {
    if (!_debrisInitialized) {
        if (_bloodInitialized) _initDebris(parent)
        else init(parent)
    }
    if (_debrisPool.length === 0) return

    var debris = _debrisPool[_debrisIndex]

    if (!debris) {
        debris = _createDebrisParticle(parent)
        if (!debris) return
        _debrisPool[_debrisIndex] = debris
    }

    _debrisIndex = (_debrisIndex + 1) % _debrisPool.length

    if (debris.visible) {
        debris.visible = false
    }

    debris.x = x - width / 2
    debris.y = y - width / 2
    debris.particleWidth = width
    debris.targetDx = dx
    debris.targetDy = dy
    debris.restartAnimation()
}
