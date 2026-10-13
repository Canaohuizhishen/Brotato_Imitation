import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../logic/utils/tool.js" as Tool

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

    // 波末结算触发（Drops.allFruitsToPlayer）：QML 飞行动画（7946a27 之前的效果）。
    // 波末玩家静止，固定端点安全；战斗中玩家会移动，靠近拾取仍走帧驱动磁吸。
    // from/to/时长在调用时一次性快照——勿写回旧版的实时重算绑定表达式
    // （跟随移动目标时动画永不结算，即 2026-10-04 替换掉原动画的根因）。
    function beGetedAnimatedTo(target){
        fruit.isGeted=true
        beGetedAnimation.target=target
        var dist=Tool.getDistance(Qt.point(fruit.x,fruit.y),Qt.point(target.x,target.y))
        xbeGetedAnimation.from=fruit.x
        ybeGetedAnimation.from=fruit.y
        xbeGetedAnimation.to=target.x-fruit.width/2
        ybeGetedAnimation.to=target.y-fruit.height/2
        xbeGetedAnimation.duration=dist
        ybeGetedAnimation.duration=dist
        beGetedAnimation.start()
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

    // 波末飞行动画（还原 7946a27 之前的实现：InBack 弹性收尾，"吸"进玩家）
    ParallelAnimation {
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: null

        PropertyAnimation {
            id: xbeGetedAnimation
            target: fruit
            property: "x"
            duration: 0
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: fruit
            property: "y"
            duration: 0
            easing.type: Easing.InBack
        }

        onStopped: {
            var t = beGetedAnimation.target
            if (!t) return
            getSound.play()
            t.getFruit(fruit)
            fruit.visible=false
            fruit.destroy(700)
        }
    }
}
