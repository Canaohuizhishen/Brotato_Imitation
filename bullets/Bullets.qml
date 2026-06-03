import QtQuick 2.15
import singleton.PlayerData
import "../monsters"

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
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "子弹" && !child.isDestroy && !child.inHitCoolDown) {
                if (target.objectName === "Monsters") {
                    var monster = target.getCollidingChild(child)
                    if (monster !== null) {
                        monster.onHit(child)
                        if (!child.hitNotDestroy) child.destroy()
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
