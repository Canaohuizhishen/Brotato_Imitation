import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../data"
import "../tool.js" as Tool

Image {
    id: chest
    objectName: "宝箱"
    source: grade==1 ? "qrc:/images/chest_white" : (grade==2 ? "qrc:/images/chest_green" : "qrc:/images/chest_red")
    property int grade: 1
    property string propName
    property bool isGeted: false
    property bool isDestroy: false
    property double scaleFactor: 1
    width: 50*scaleFactor
    height: width*0.9505
    z: y+height

    Component.onCompleted: {
        var porp=propCore.getPropRandomly()
        chest.grade=porp.grade
        chest.propName=porp.propName
    }

    PropCustomizationCore{
        id: propCore
    }

    function beGetedTo(target){
        chest.isGeted=true
        beGetedAnimation.target=target
        beGetedAnimation.start()
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_chest.wav"
        volume: 0.5
    }

    ParallelAnimation{
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: chest

        PropertyAnimation {
            id: xbeGetedAnimation
            target: chest
            property: "x"
            from: chest.x
            to: beGetedAnimation.target.x-chest.width/2
            duration: Tool.getDistance(Qt.point(chest.x,chest.y),Qt.point(beGetedAnimation.target.x,beGetedAnimation.target.y))*1
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: xbeGetedAnimation.target
            property: "y"
            from: chest.y
            to: beGetedAnimation.target.y-chest.height/2
            duration: xbeGetedAnimation.duration
            easing.type: xbeGetedAnimation.easing.type
        }

        onStopped: {
            getSound.play()
            target.getChest(chest)
            chest.visible=false
            chest.destroy(700)
        }
    }
}
