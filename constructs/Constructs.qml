import QtQuick 2.15
import singleton.PlayerData
import "../components"

Item {
    id: constructsContainer
    anchors.fill: parent
    objectName: "Constructs"
    z: 4
    property bool active: true
    property bool paused: false
    property var componentCache: null
    property var bulletsParent: null
    property var gameArea: null
    property var monsterContainer: null  // 由 GameArea 设置，用于碰撞检测

    property int maxConstructs: 8

    function placeConstruct(type, x, y) {
        if (!componentCache) return null
        if (getConstructCount() >= maxConstructs) return null

        var construct = null
        if (type === "turret") {
            construct = Qt.createQmlObject(
                "import QtQuick 2.15; import '../constructs/TurretConstruct.qml' as T; T.TurretConstruct {}",
                constructsContainer
            )
        } else if (type === "mine") {
            construct = Qt.createQmlObject(
                "import QtQuick 2.15; import '../constructs/MineConstruct.qml' as M; M.MineConstruct {}",
                constructsContainer
            )
        }

        if (construct) {
            construct.scaleFactor = 1.0  // 由 GameArea 的 scaleFactor 管理
            construct.x = x - construct.width / 2
            construct.y = y - construct.height / 2
            construct.bulletsParent = bulletsParent
            construct.componentCache = componentCache
            construct.gameArea = gameArea
            construct.paused = paused
        }
        return construct
    }

    function getConstructCount() {
        var count = 0
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "TurretConstruct" || child.objectName === "MineConstruct") {
                if (!child.isDestroy) count++
            }
        }
        return count
    }

    function getAllActiveConstructs() {
        var list = []
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if ((child.objectName === "TurretConstruct" || child.objectName === "MineConstruct") && !child.isDestroy) {
                list.push(child)
            }
        }
        return list
    }

    // 每帧更新所有构筑物的目标
    function updateAllTargets() {
        if (!active || paused) return
        var monsters = []
        if (monsterContainer) {
            for (var i = 0; i < monsterContainer.children.length; i++) {
                var m = monsterContainer.children[i]
                if (m.objectName === "Monster" && !m.isDead && !m.isDestroy) {
                    monsters.push(m)
                }
            }
        }
        var constructs = getAllActiveConstructs()
        for (var j = 0; j < constructs.length; j++) {
            constructs[j].updateTarget(monsters)
        }
    }

    // 每帧检测地雷与怪物的碰撞
    function checkMineCollisions() {
        if (!active || paused) return
        if (!monsterContainer) return

        var mines = []
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "MineConstruct" && !child.isDestroy && !child.isTriggered) {
                mines.push(child)
            }
        }
        if (mines.length === 0) return

        for (var mi = 0; mi < mines.length; mi++) {
            var mine = mines[mi]
            if (mine.isDestroy || mine.isTriggered) continue
            for (var mj = 0; mj < monsterContainer.children.length; mj++) {
                var monster = monsterContainer.children[mj]
                if (monster.objectName !== "Monster" || monster.isDead || monster.isDestroy) continue
                if (mine.checkMonsterCollision(monster)) break
            }
        }
    }

    function clear() {
        for (var i = children.length - 1; i >= 0; i--) {
            var child = children[i]
            if (child.objectName === "TurretConstruct" || child.objectName === "MineConstruct") {
                child.isDestroy = true
                child.destroy()
            }
        }
    }

    function init() {
        clear()
        active = true
        paused = false
    }

    onPausedChanged: {
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "TurretConstruct" || child.objectName === "MineConstruct") {
                child.paused = paused
            }
        }
    }
}
