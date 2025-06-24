import QtQuick 2.15
import singleton.PlayerData
import "../monsters"
import "../tool.js" as Tool

Item {
    id: drops
    anchors.fill: parent
    property Player target
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool active: true
    z: 2

    onScaleFactorChanged: {
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="材料" || child.objectName==="果实" || child.objectName==="宝箱"){
                child.x=child.x*scaleFactor/lastScaleFactor
                child.y=child.y*scaleFactor/lastScaleFactor
            }
        }
        lastScaleFactor=scaleFactor
    }

    function init(){
        active=true
        clear()
    }

    function clear(){
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="材料" || child.objectName==="果实" || child.objectName==="宝箱"){
                child.destroy()
                child.isDestroy=true
            }
        }
    }

    function allMaterialsToBag(point){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="材料" && child.isGeted===false){
                child.toBag(point)
            }
        }
    }

    function allFruitsToPlayer(player){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="果实" && child.isGeted===false){
                child.beGetedTo(player)
            }
        }
    }

    function allChestToPlayer(player){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="宝箱" && child.isGeted===false){
                child.beGetedTo(player)
            }
        }
    }

    Timer {
        id: collidingTimer
        interval: 100
        running: drops.active
        repeat: true
        onTriggered: {
            for(var i=0;i<drops.children.length;i++){
                var child=drops.children[i]
                if(child.objectName==="材料" && child.isGeted===false && !child.isDestroy){
                    if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(drops.target.x,drops.target.y))<PlayerData.pickupRange*scaleFactor){
                        child.beGetedTo(target)
                    }
                }else if(child.objectName==="果实" && child.isGeted===false && !child.isDestroy){
                    if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(drops.target.x,drops.target.y))<PlayerData.pickupRange*scaleFactor){
                        child.beGetedTo(target)
                    }
                }else if(child.objectName==="宝箱" && child.isGeted===false && !child.isDestroy){
                    if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(drops.target.x,drops.target.y))<PlayerData.pickupRange*scaleFactor){
                        child.beGetedTo(target)
                    }
                }
            }
        }
    }
}
