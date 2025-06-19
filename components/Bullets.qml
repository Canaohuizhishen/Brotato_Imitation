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

    onScaleFactorChanged: {
        for(var i=0;i<bullets.children.length;i++){
            var child=bullets.children[i]
            if(child.objectName=="子弹"){
                child.x=child.x*scaleFactor/lastScaleFactor
                child.y=child.y*scaleFactor/lastScaleFactor
            }
        }
        lastScaleFactor=scaleFactor
    }

    Timer {
        id: collidingTimer
        interval: 30
        running: bullets.active
        repeat: true
        onTriggered: {
            for(var i=0;i<bullets.children.length;i++){
                var child=bullets.children[i]
                if(child.objectName=="子弹"){
                    if(bullets.target.objectName=="Monsters"){
                        var monster=bullets.target.getCollidingChild(child)
                        if(monster!=null){
                            monster.onHit(child)
                            child.destroy()
                        }
                    }else if(bullets.target.objectName=="Player"){
                        var player=bullets.target
                        if(Math.abs(bullets.target.x-child.x)<(bullets.target.width+child.width)/2 && Math.abs(bullets.target.y-child.y)<(bullets.target.height+child.height)/2){
                            player.onHit(child)
                            child.destroy()
                        }
                    }
                }
            }

        }
    }

    function clear(){
        for(var i=0;i<bullets.children.length;i++){
            var child=bullets.children[i]
            if(child.objectName=="子弹"){
                child.destroy()
            }
        }
    }
}
