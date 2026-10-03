import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData

Image {
    id: fruit
    objectName: "果实"
    source:"qrc:/images/fruit"
    property int value: 2+PlayerData.consumptiveTherapy
    property bool isGeted: false
    property bool isDestroy: false
    property var magnetTarget: null   // 磁吸目标（玩家），由 Drops.updateFlyingDrops 每帧驱动
    property double scaleFactor: 1
    width: 35*scaleFactor
    height: width*1.209
    z: y+height

    // 被拾取范围触发：进入磁吸状态，由 Drops.updateFlyingDrops 每帧追踪玩家
    function beGetedTo(target){
        fruit.isGeted=true
        fruit.magnetTarget=target
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_fruit.wav"
        volume: 0.6
    }

    // 磁吸命中玩家后结算（由 Drops.updateFlyingDrops 追到后调用）
    function completeCollect(){
        var t = fruit.magnetTarget
        fruit.magnetTarget = null
        if (!t) return
        getSound.play()
        t.getFruit(fruit)
        fruit.visible=false
        fruit.destroy(700)
    }
}
