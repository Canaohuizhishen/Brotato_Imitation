import QtQuick
import QtTest
import "../logic/SpatialGrid.js" as SpatialGrid

// 子弹命中结算的回归测试（bullets/Bullets.qml）——
// 背景：checkBulletCollisions 命中后调用 destroy()，而 QML 的 destroy() 是异步删除
// （要到下一轮事件循环才真正从 children 移除）。删除落地前的下一次检测必须被
// isDestroy 守卫跳过，否则同一发子弹会重复结算（喷吐怪子弹命中玩家 -3 双跳的根因）。
TestCase {
    name: "BulletsTests"

    // 用 Loader 按文件路径加载容器，避免 import "../bullets" 需要 qmldir
    Loader {
        id: bulletsLoader
        source: "../bullets/Bullets.qml"
        asynchronous: false
    }

    // 假玩家：只实现玩家命中分支所需的接口
    Item {
        id: fakePlayer
        objectName: "Player"
        x: 100
        y: 100
        width: 40
        height: 40
        property int hitCount: 0
        function onHit(bullet) { hitCount++ }
    }

    // 探针子弹：与 Bullet.qml 同构的最小接口（容器命中逻辑只依赖这些字段）
    Component {
        id: probeBulletComponent
        Item {
            objectName: "子弹"
            width: 26
            height: 26
            property bool isDestroy: false
            property bool inHitCoolDown: false
            property bool hitNotDestroy: false
            property int penetrateCount: 0
            property int reboundCount: 0
        }
    }

    // 每个用例后清理：删除探针子弹、复位容器与空间网格
    function cleanup() {
        var cont = bulletsLoader.item
        if (cont) {
            cont.target = null
            for (var i = 0; i < cont.children.length; i++) {
                var c = cont.children[i]
                if (c.objectName === "子弹") {
                    c.isDestroy = true
                    c.destroy()
                }
            }
        }
        SpatialGrid.clear()
    }

    function test_bulletHitPlayer_noDoubleHitInDestroyWindow() {
        var cont = bulletsLoader.item
        verify(cont, "Bullets.qml 应可加载")
        cont.target = fakePlayer
        fakePlayer.hitCount = 0

        var bullet = probeBulletComponent.createObject(cont, { x: 100, y: 100 })
        verify(bullet, "探针子弹创建失败")

        cont.checkBulletCollisions()
        compare(fakePlayer.hitCount, 1, "首次检测应命中一次")

        // destroy 尚未落地（同一轮事件循环内对象仍在 children 中）：
        // 立即再检测一次——必须被 isDestroy 守卫拦住，否则同一发子弹重复扣血
        cont.checkBulletCollisions()
        compare(fakePlayer.hitCount, 1, "异步删除窗口内不得重复扣血")
        compare(bullet.isDestroy, true, "命中后必须立即置 isDestroy（destroy 为异步删除）")

        wait(50)   // 让延迟删除落地
        cont.checkBulletCollisions()
        compare(fakePlayer.hitCount, 1, "销毁落地后不得再命中")
    }

    function test_bulletHitMonster_noDoubleHitInDestroyWindow() {
        var cont = bulletsLoader.item
        verify(cont, "Bullets.qml 应可加载")
        cont.target = { objectName: "Monsters" }

        // 空间网格里放一只假怪物（容器命中只依赖 SpatialGrid 查询与存活标记）
        SpatialGrid.init(200)
        var hitCount = 0
        var monster = {
            _spatialId: "probe_monster",
            x: 100, y: 100, width: 40, height: 40,
            isDead: false, isDestroy: false,
            onHit: function(b) { hitCount++ }
        }
        SpatialGrid.insert(monster, monster.x, monster.y)

        var bullet = probeBulletComponent.createObject(cont, { x: 100, y: 100 })
        verify(bullet, "探针子弹创建失败")

        cont.checkBulletCollisions()
        compare(hitCount, 1, "首次检测应命中一次")

        cont.checkBulletCollisions()
        compare(hitCount, 1, "异步删除窗口内不得重复结算")
        compare(bullet.isDestroy, true, "命中后必须立即置 isDestroy（destroy 为异步删除）")
    }
}
