import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../tool.js" as Tool

Image {
    id: fruit
    objectName: "果实"
    source:"qrc:/images/fruit"
    property int value: 2+PlayerData.consumptiveTherapy
    property bool isGeted: false
    property bool isDestroy: false
    property double scaleFactor: 1
    width: 35*scaleFactor
    height: width*1.209
    z: y+height

    function beGetedTo(target){
        fruit.isGeted=true
        beGetedAnimation.target=target
        beGetedAnimation.start()
    }

    SoundEffect {
        id: materialPickingSound
        source: "qrc:/audio/materialPicking.wav"
        volume: 0.6
    }

    ParallelAnimation{
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: fruit

        PropertyAnimation {
            id: xbeGetedAnimation
            target: fruit
            property: "x"
            from: fruit.x
            to: beGetedAnimation.target.x-fruit.width/2
            duration: Tool.getDistance(Qt.point(fruit.x,fruit.y),Qt.point(beGetedAnimation.target.x,beGetedAnimation.target.y))*1
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: xbeGetedAnimation.target
            property: "y"
            from: fruit.y
            to: beGetedAnimation.target.y-fruit.height/2
            duration: xbeGetedAnimation.duration
            easing.type: xbeGetedAnimation.easing.type
        }

        onStopped: {
            materialPickingSound.play()
            target.getFruit(fruit)
            fruit.visible=false
            waitDestroyTimer.start()
        }
    }

    Timer {
        id: waitDestroyTimer
        interval: 400
        running: false
        repeat: false
        onTriggered: {
            fruit.destroy()
        }
    }
}
