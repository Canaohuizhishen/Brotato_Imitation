import QtQuick 2.15

/**
 * ComponentCache — 全局预编译组件缓存
 *
 * 在启动时异步预编译常用 QML 组件（Fork / 子弹 / 掉落等），
 * 避免运行时重复调用 Qt.createComponent（每次 0.5-3ms 编译时间）。
 *
 * 对于 source 动态变化的组件（怪物、武器），使用懒加载缓存。
 *
 * 用法：在 GameArea.qml 中声明，通过属性传递给子组件。
 *
 * 注意：所有路径使用从 logic/ 出发的相对路径（../xxx/yyy.qml），
 * 因为 Qt.createComponent 的路径解析相对于 ComponentCache.qml 的位置。
 */
Item {
    id: cache

    // ---- 静态预编译组件 ----
    property Component forkComponent: null
    property Component materialComponent: null
    property Component fruitComponent: null
    property Component chestComponent: null
    property Component bigMaterialComponent: null
    property Component roundMovingBulletComponent: null
    property Component roundStaticBulletComponent: null
    property Component meleeBulletComponent: null
    property Component ellipticalMovingBulletComponent: null

    // ---- 状态 ----
    property bool allReady: false
    property int _loadedCount: 0
    readonly property int _totalCount: 9

    // 动态组件缓存（懒加载，按 source URL 缓存）
    property var _dynamicCache: ({})

    Component.onCompleted: {
        // 路径相对于 logic/ 目录，使用 ../ 上溯到项目根
        forkComponent = Qt.createComponent("../components/Fork.qml", Component.Asynchronous)
        materialComponent = Qt.createComponent("../drops/Material.qml", Component.Asynchronous)
        fruitComponent = Qt.createComponent("../drops/Fruit.qml", Component.Asynchronous)
        chestComponent = Qt.createComponent("../drops/Chest.qml", Component.Asynchronous)
        bigMaterialComponent = Qt.createComponent("../drops/BigMaterial.qml", Component.Asynchronous)
        roundMovingBulletComponent = Qt.createComponent("../bullets/RoundMovingBullet.qml", Component.Asynchronous)
        roundStaticBulletComponent = Qt.createComponent("../bullets/RoundStaticBullet.qml", Component.Asynchronous)
        meleeBulletComponent = Qt.createComponent("../bullets/MeleeBullet.qml", Component.Asynchronous)
        ellipticalMovingBulletComponent = Qt.createComponent("../bullets/EllipticalMovingBullet.qml", Component.Asynchronous)

        forkComponent.statusChanged.connect(_checkAllReady)
        materialComponent.statusChanged.connect(_checkAllReady)
        fruitComponent.statusChanged.connect(_checkAllReady)
        chestComponent.statusChanged.connect(_checkAllReady)
        bigMaterialComponent.statusChanged.connect(_checkAllReady)
        roundMovingBulletComponent.statusChanged.connect(_checkAllReady)
        roundStaticBulletComponent.statusChanged.connect(_checkAllReady)
        meleeBulletComponent.statusChanged.connect(_checkAllReady)
        ellipticalMovingBulletComponent.statusChanged.connect(_checkAllReady)

        // Catch any components that already loaded before signal connections
        _checkAllReady()
    }

    function _checkComponent(comp, name) {
        if (!comp) return null
        if (comp.status === Component.Ready) {
            _loadedCount++
            return comp
        }
        if (comp.status === Component.Error) {
            console.error("ComponentCache: " + name + " failed to load:", comp.errorString())
            return null
        }
        return comp  // still loading
    }

    function _checkAllReady() {
        _loadedCount = 0
        forkComponent = _checkComponent(forkComponent, "forkComponent")
        materialComponent = _checkComponent(materialComponent, "materialComponent")
        fruitComponent = _checkComponent(fruitComponent, "fruitComponent")
        chestComponent = _checkComponent(chestComponent, "chestComponent")
        bigMaterialComponent = _checkComponent(bigMaterialComponent, "bigMaterialComponent")
        roundMovingBulletComponent = _checkComponent(roundMovingBulletComponent, "roundMovingBulletComponent")
        roundStaticBulletComponent = _checkComponent(roundStaticBulletComponent, "roundStaticBulletComponent")
        meleeBulletComponent = _checkComponent(meleeBulletComponent, "meleeBulletComponent")
        ellipticalMovingBulletComponent = _checkComponent(ellipticalMovingBulletComponent, "ellipticalMovingBulletComponent")
        if (_loadedCount >= _totalCount) {
            allReady = true
            console.log("ComponentCache: all " + _loadedCount + " components ready")
        }
    }

    // 获取或创建动态缓存组件（懒加载）
    function _getCachedComponent(source) {
        if (source === undefined || source === null) return null
        if (_dynamicCache[source] !== undefined) {
            return _dynamicCache[source]
        }
        var comp = Qt.createComponent(source)
        _dynamicCache[source] = comp
        return comp
    }

    // ---- 工厂方法 ----
    // 每个工厂方法优先使用预编译组件，异步未 Ready 时退回到同步创建

    function createFork(parent, properties) {
        if (forkComponent && forkComponent.status === Component.Ready) {
            return forkComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: forkComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../components/Fork.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createMaterial(parent, properties) {
        if (materialComponent && materialComponent.status === Component.Ready) {
            return materialComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: materialComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../drops/Material.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createFruit(parent, properties) {
        if (fruitComponent && fruitComponent.status === Component.Ready) {
            return fruitComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: fruitComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../drops/Fruit.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createChest(parent, properties) {
        if (chestComponent && chestComponent.status === Component.Ready) {
            return chestComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: chestComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../drops/Chest.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createBigMaterial(parent, properties) {
        if (bigMaterialComponent && bigMaterialComponent.status === Component.Ready) {
            return bigMaterialComponent.createObject(parent, properties || {})
        }
        // Check status of async pre-compiled component
        if (bigMaterialComponent) {
            if (bigMaterialComponent.status === Component.Error) {
                console.error("ComponentCache: bigMaterialComponent error:", bigMaterialComponent.errorString())
            } else if (bigMaterialComponent.status === Component.Loading) {
                console.warn("ComponentCache: bigMaterialComponent still loading, trying sync fallback")
            }
        }
        console.warn("ComponentCache: bigMaterialComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../drops/BigMaterial.qml")
        if (fallback.status === Component.Error) {
            console.error("ComponentCache: BigMaterial sync fallback error:", fallback.errorString())
            return null
        }
        if (fallback.status === Component.Ready) {
            return fallback.createObject(parent, properties || {})
        }
        // Still loading (shouldn't happen for sync), wait a frame
        console.warn("ComponentCache: BigMaterial sync fallback also loading, retrying next frame")
        return null
    }

    function createRoundMovingBullet(parent, properties) {
        if (roundMovingBulletComponent && roundMovingBulletComponent.status === Component.Ready) {
            return roundMovingBulletComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: roundMovingBulletComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../bullets/RoundMovingBullet.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createRoundStaticBullet(parent, properties) {
        if (roundStaticBulletComponent && roundStaticBulletComponent.status === Component.Ready) {
            return roundStaticBulletComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: roundStaticBulletComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../bullets/RoundStaticBullet.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createMeleeBullet(parent, properties) {
        if (meleeBulletComponent && meleeBulletComponent.status === Component.Ready) {
            return meleeBulletComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: meleeBulletComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../bullets/MeleeBullet.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    function createEllipticalMovingBullet(parent, properties) {
        if (ellipticalMovingBulletComponent && ellipticalMovingBulletComponent.status === Component.Ready) {
            return ellipticalMovingBulletComponent.createObject(parent, properties || {})
        }
        console.warn("ComponentCache: ellipticalMovingBulletComponent not ready, fallback to sync")
        var fallback = Qt.createComponent("../bullets/EllipticalMovingBullet.qml")
        return fallback.status === Component.Ready
                ? fallback.createObject(parent, properties || {}) : null
    }

    // 动态 source 组件（怪物 source / 武器 source 各不相同）
    // 注意：调用者需传入完整的可解析路径（带目录前缀），
    // 因为此文件位于 logic/，裸文件名无法正确解析。
    function createFromSource(source, parent, properties) {
        if (!source) {
            console.error("ComponentCache: createFromSource called with null/undefined source")
            return null
        }
        var comp = _getCachedComponent(source)
        if (comp && comp.status === Component.Ready) {
            return comp.createObject(parent, properties || {})
        }
        console.error("ComponentCache: failed to load", source, comp ? comp.errorString() : "null component")
        return null
    }
}
