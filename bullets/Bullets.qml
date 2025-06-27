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

    Timer {
        id: collidingTimer
        interval: bullets.target.objectName==="Monsters" ? 15 : 50
        running: bullets.active && !bullets.paused
        repeat: true
        onTriggered: {
            for(var i=0;i<bullets.children.length;i++){
                var child=bullets.children[i]
                if(child.objectName==="子弹" && !child.isDestroy && !child.inHitCoolDown){
                    if(bullets.target.objectName==="Monsters"){
                        var monster=bullets.target.getCollidingChild(child)
                        if(monster!==null){
                            monster.onHit(child)
                            if(!child.hitNotDestroy)child.destroy()
                        }
                    }else if(bullets.target.objectName==="Player"){
                        var player=bullets.target
                        if(Math.abs(bullets.target.x+bullets.target.width/2-child.x-child.width/2)<(bullets.target.width+child.width)/2 && Math.abs(bullets.target.y+bullets.target.height/2-child.y-child.height/2)<(bullets.target.height+child.height)/2){
                            player.onHit(child)
                            if(!child.hitNotDestroy)child.destroy()
                            else child.inHitCoolDown=true
                        }
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
