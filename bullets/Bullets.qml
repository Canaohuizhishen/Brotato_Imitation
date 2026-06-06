import QtQuick 2.15
import singleton.PlayerData
import "../logic/SpatialGrid.js" as SpatialGrid

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
                // 用 SpatialGrid 查询子弹附近的怪物，代替 O(n) 遍历
                var nearby = SpatialGrid.query(child.x, child.y, child.width, child.height)
                for (var j = 0; j < nearby.length; j++) {
                    var monster = nearby[j]
                    if (monster && !monster.isDead && !monster.isDestroy && _aabbCollide(child, monster)) {
                        monster.onHit(child)
                        if (!child.hitNotDestroy) child.destroy()
                        break
                    }
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

    function _aabbCollide(a, b) {
        return a.x < b.x + b.width &&
               a.x + a.width > b.x &&
               a.y < b.y + b.height &&
               a.y + a.height > b.y
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
