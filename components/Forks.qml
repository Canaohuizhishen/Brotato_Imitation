import QtQuick 2.15
import singleton.PlayerData
import "../monsters"
import "../tool.js" as Tool

Item {
    id: forks
    anchors.fill: parent
    property Player target
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    z: 2

    onScaleFactorChanged: {
        for(var i=0;i<forks.children.length;i++){
            var child=forks.children[i]
            if(child.objectName==="Fork"){
                child.x=child.x*scaleFactor/lastScaleFactor
                child.y=child.y*scaleFactor/lastScaleFactor
            }
        }
        lastScaleFactor=scaleFactor
    }

    function spawnFork() {
        var forkComponent = Qt.createComponent("../components/Fork.qml");
        if (forkComponent.status === Component.Ready) {
                var fork = forkComponent.createObject(forks);
        }else console.error("Error loading component:", forkComponent.errorString())
        return fork
    }

    function init(){
        clear()
    }

    function clear(){
        for(var i=0;i<forks.children.length;i++){
            var child=forks.children[i]
            if(child.objectName==="Fork"){
                child.destroy()
                child.isDestroy=true
            }
        }
    }
}
