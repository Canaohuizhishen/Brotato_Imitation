.pragma library

var _COMPONENT_READY = 1  // Component.Ready — QML JS 引擎不暴露 Component 枚举

/**
 * SafeCreate — 安全的 QML 动态组件创建工具
 *
 * 封装 Qt.createComponent + createObject 模式，提供：
 * - 统一的错误处理
 * - 类型安全的属性注入
 * - 自动的 scaleFactor/paused/active 绑定注入（可选）
 *
 * 用法：
 *   import "../logic/SafeCreate.js" as SafeCreate
 *
 *   // 创建组件
 *   var bullet = SafeCreate.create("EllipticalMovingBullet.qml", parent, {
 *       damage: 10, x: 100, y: 200
 *   })
 *
 *   // 创建并注入标准绑定
 *   var monster = SafeCreate.createWithBindings(
 *       "BabyAlien.qml", parent,
 *       { target: player, damage: 5 },           // 自定义属性
 *       { scaleFactor: "scaleFactor", paused: "paused" }  // 继承绑定
 *   )
 */

// 创建组件并设置属性
function create(componentPath, parent, properties) {
    var component = Qt.createComponent(componentPath)
    if (component.status !== _COMPONENT_READY) {
        console.error("SafeCreate: failed to load", componentPath, component.errorString())
        return null
    }

    var obj = component.createObject(parent, properties || {})
    if (!obj) {
        console.error("SafeCreate: failed to create object from", componentPath)
        return null
    }
    return obj
}

// 创建组件 + 注入从父级继承的绑定属性
function createWithBindings(componentPath, parent, customProperties, bindingMap) {
    var component = Qt.createComponent(componentPath)
    if (component.status !== _COMPONENT_READY) {
        console.error("SafeCreate: failed to load", componentPath, component.errorString())
        return null
    }

    var obj = component.createObject(parent, customProperties || {})
    if (!obj) {
        console.error("SafeCreate: failed to create object from", componentPath)
        return null
    }

    // 注入 QML 绑定：将绑定源（parent）的属性绑定到目标对象的指定属性
    if (bindingMap) {
        for (var targetProp in bindingMap) {
            if (bindingMap.hasOwnProperty(targetProp)) {
                var sourceProp = bindingMap[targetProp]
                // 使用 IIFE 捕获 sourceProp（for 循环的 var 变量会有闭包陷阱）
                ;(function(capturedTarget, capturedSource) {
                    obj[capturedTarget] = Qt.binding(function() {
                        return parent[capturedSource]
                    })
                })(targetProp, sourceProp)
            }
        }
    }

    return obj
}
