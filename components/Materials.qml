import QtQuick 2.15
import singleton.PlayerData
import "../monsters"
import "../tool.js" as Tool

Item {
    id: materials
    anchors.fill: parent
    property Player target
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool active: true
    z: 2

    onScaleFactorChanged: {
        for(var i=0;i<materials.children.length;i++){
            var child=materials.children[i]
            if(child.objectName=="材料"){
                child.x=child.x*scaleFactor/lastScaleFactor
                child.y=child.y*scaleFactor/lastScaleFactor
            }
        }
        lastScaleFactor=scaleFactor
    }

    function allToBag(point){
        for(var i=0;i<materials.children.length;i++){
            var child=materials.children[i]
            if(child.objectName=="材料" && child.isGeted==false){
                child.toBag(point)
            }
        }
    }

    Timer {
        id: collidingTimer
        interval: 100
        running: materials.active
        repeat: true
        onTriggered: {
            for(var i=0;i<materials.children.length;i++){
                var child=materials.children[i]
                if(child.objectName=="材料" && child.isGeted==false){
                    if(Tool.getDistance(Qt.point(child.x,child.y),Qt.point(materials.target.x,materials.target.y))<PlayerData.pickupRange){
                        target.getMaterial(child)
                        child.beGetedTo(target)
                    }
                }
            }

        }
    }
}
