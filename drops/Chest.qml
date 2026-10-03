import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../data/cores"

Image {
    id: chest
    objectName: "宝箱"
    source: grade==1 ? "qrc:/images/chest_white" : (grade==2 ? "qrc:/images/chest_green" : "qrc:/images/chest_red")
    property int grade: 1
    property string propName
    property bool isGeted: false
    property bool isDestroy: false
    property var magnetTarget: null   // 磁吸目标（玩家），由 Drops.updateFlyingDrops 每帧驱动
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

    // 被拾取范围触发：进入磁吸状态，由 Drops.updateFlyingDrops 每帧追踪玩家
    function beGetedTo(target){
        chest.isGeted=true
        chest.magnetTarget=target
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_chest.wav"
        volume: 0.5
    }

    // 磁吸命中玩家后结算（由 Drops.updateFlyingDrops 追到后调用）
    function completeCollect(){
        var t = chest.magnetTarget
        chest.magnetTarget = null
        if (!t) return
        getSound.play()
        t.getChest(chest)
        chest.visible=false
        chest.destroy(700)
    }
}
