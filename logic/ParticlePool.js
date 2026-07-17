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
 *   ParticlePool.spawn(x, y, dx, dy, width, gameArea, enabled)
 *
 *   // 残渣（材料拾取）
 *   ParticlePool.spawnDebris(x, y, dx, dy, width, gameArea, enabled)
 *
 *   enabled — 是否实际生成粒子（用于 SettingsData.visualEffects 控制）
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

function spawn(x, y, dx, dy, width, parent, enabled) {
    if (enabled === false) return
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

function spawnDebris(x, y, dx, dy, width, parent, enabled) {
    if (enabled === false) return
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

// ---- 爆炸粒子池 ----
var _explosionPoolSize = 10
var _explosionPool = []
var _explosionIndex = 0
var _explosionInitialized = false
var _explosionComponent = null

function _initExplosion(parent) {
    if (_explosionInitialized) return
    _explosionComponent = Qt.createComponent("../particles/ExplosionParticle.qml")
    for (var i = 0; i < _explosionPoolSize; i++) {
        var exp = _createExplosionParticle(parent)
        if (exp) {
            exp.visible = false
            _explosionPool.push(exp)
        }
    }
    _explosionInitialized = true
}

function _createExplosionParticle(parent) {
    if (!_explosionComponent || _explosionComponent.status !== _COMPONENT_READY) {
        _explosionComponent = Qt.createComponent("../particles/ExplosionParticle.qml")
    }
    if (_explosionComponent.status === _COMPONENT_READY)
        return _explosionComponent.createObject(parent)
    console.error("ParticlePool: failed to load ExplosionParticle.qml")
    return null
}

function spawnExplosion(x, y, radius, parent, enabled) {
    if (enabled === false) return
    if (!_explosionInitialized) {
        if (_debrisInitialized || _bloodInitialized) _initExplosion(parent)
        else init(parent)
    }
    if (_explosionPool.length === 0) return

    var exp = _explosionPool[_explosionIndex]

    if (!exp) {
        exp = _createExplosionParticle(parent)
        if (!exp) return
        _explosionPool[_explosionIndex] = exp
    }

    _explosionIndex = (_explosionIndex + 1) % _explosionPool.length

    if (exp.visible) {
        exp.visible = false
    }

    exp.showExplosion(x, y, radius)
}

/**
 * release — 清理所有池中粒子，重置状态
 *
 * 在场景卸载时调用（如返回主菜单），防止粒子对象残留。
 * 调用后池为空，再次调用 init(parent) 会重新创建。
 */
function release() {
    // 血花池
    for (var i = 0; i < _bloodPool.length; i++) {
        if (_bloodPool[i]) _bloodPool[i].destroy()
    }
    _bloodPool = []
    _bloodIndex = 0
    _bloodInitialized = false
    _bloodComponent = null

    // 残渣池
    for (var j = 0; j < _debrisPool.length; j++) {
        if (_debrisPool[j]) _debrisPool[j].destroy()
    }
    _debrisPool = []
    _debrisIndex = 0
    _debrisInitialized = false
    _debrisComponent = null

    // 爆炸池
    for (var k = 0; k < _explosionPool.length; k++) {
        if (_explosionPool[k]) _explosionPool[k].destroy()
    }
    _explosionPool = []
    _explosionIndex = 0
    _explosionInitialized = false
    _explosionComponent = null
}
