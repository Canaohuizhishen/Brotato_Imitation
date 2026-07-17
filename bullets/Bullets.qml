import QtQuick 2.15
import singleton.PlayerData
import "../logic/SpatialGrid.js" as SpatialGrid
import "../logic/utils/collision.js" as Collision

Item {
    id: bullets
    anchors.fill: parent
    property var target
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool active: true
    property bool paused: false

    function checkBulletCollisions() {
        if (!active || paused) return
        for (var i = children.length - 1; i >= 0; i--) {
            var child = children[i]
            if (child.objectName !== "子弹" || child.isDestroy || child.inHitCoolDown) continue

            if (target.objectName === "Monsters") {
                var nearby = SpatialGrid.query(child.x, child.y, child.width, child.height)
                for (var j = 0; j < nearby.length; j++) {
                    var monster = nearby[j]
                    if (!monster || monster.isDead || monster.isDestroy || !Collision.aabbCollide(child, monster)) continue

                    monster.onHit(child)

                    // 穿透：不销毁不停止，继续检查其他怪物
                    if (child.penetrateCount > 0) {
                        child.penetrateCount--
                        child.damage = Math.floor(child.damage * child.penetrateDamageMultiplier)
                        continue
                    }

                    // 反弹：寻找最近的其他怪物作为新目标
                    if (child.reboundCount > 0) {
                        child.reboundCount--
                        var reboundTarget = _findNearestMonster(child, nearby, monster)
                        if (reboundTarget && typeof child.reboundToTarget === 'function') {
                            child.reboundToTarget(reboundTarget)
                        }
                        break
                    }

                    // 默认行为
                    if (!child.hitNotDestroy) child.destroy()
                    break
                }
            } else if (target.objectName === "Player") {
                var player = target
                if (Math.abs(target.x + target.width / 2 - child.x - child.width / 2) < (target.width + child.width) / 2 && Math.abs(target.y + target.height / 2 - child.y - child.height / 2) < (target.height + child.height) / 2) {
                    player.onHit(child)
                    if (!child.hitNotDestroy) child.destroy()
                    else child.inHitCoolDown = true
                }
            }
        }
    }

    function _findNearestMonster(bullet, nearby, excludeMonster) {
        var nearest = null
        var minDist = Infinity
        var bx = bullet.x + bullet.width / 2
        var by = bullet.y + bullet.height / 2
        for (var k = 0; k < nearby.length; k++) {
            var m = nearby[k]
            if (m === excludeMonster || m.isDead || m.isDestroy) continue
            var dx = (m.x + m.width / 2) - bx
            var dy = (m.y + m.height / 2) - by
            var dist = dx * dx + dy * dy
            if (dist < minDist) {
                minDist = dist
                nearest = m
            }
        }
        return nearest
    }

    function clear(){
        for(var i=0;i<bullets.children.length;i++){
            var child=bullets.children[i]
            if(child.objectName==="子弹"){
                child.destroy()
                child.isDestroy=true
            }
        }
    }

    function init(){
        active=true
        clear()
    }
}
