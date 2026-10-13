import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../data/cores"
import "../logic/utils/tool.js" as Tool

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

    // 波末结算触发（Drops.allChestToPlayer）：QML 飞行动画（7946a27 之前的效果）。
    // 波末玩家静止，固定端点安全；战斗中玩家会移动，靠近拾取仍走帧驱动磁吸。
    // from/to/时长在调用时一次性快照——勿写回旧版的实时重算绑定表达式
    // （跟随移动目标时动画永不结算，即 2026-10-04 替换掉原动画的根因）。
    function beGetedAnimatedTo(target){
        chest.isGeted=true
        beGetedAnimation.target=target
        var dist=Tool.getDistance(Qt.point(chest.x,chest.y),Qt.point(target.x,target.y))
        xbeGetedAnimation.from=chest.x
        ybeGetedAnimation.from=chest.y
        xbeGetedAnimation.to=target.x-chest.width/2
        ybeGetedAnimation.to=target.y-chest.height/2
        xbeGetedAnimation.duration=dist
        ybeGetedAnimation.duration=dist
        beGetedAnimation.start()
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

    // 波末飞行动画（还原 7946a27 之前的实现：InBack 弹性收尾，"吸"进玩家）
    ParallelAnimation {
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: null

        PropertyAnimation {
            id: xbeGetedAnimation
            target: chest
            property: "x"
            duration: 0
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: chest
            property: "y"
            duration: 0
            easing.type: Easing.InBack
        }

        onStopped: {
            var t = beGetedAnimation.target
            if (!t) return
            getSound.play()
            t.getChest(chest)
            chest.visible=false
            chest.destroy(700)
        }
    }
}
