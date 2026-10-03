import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import singleton.SettingsData
import "../logic/utils/tool.js" as Tool
import "../logic/ParticlePool.js" as ParticlePool

Item {
    id: material
    objectName: "材料"
    property int value: 1
    property var materialImageAspectRatioArray: [0.643, 0.905, 0.681, 0.886, 0.93, 0.415, 0.623, 0.906]
    property bool isGeted: false
    property bool isDestroy: false
    property var magnetTarget: null   // 磁吸目标（玩家），由 Drops.updateFlyingDrops 每帧驱动
    property double scaleFactor: 1
    width: 30*scaleFactor
    height: width
    z: y+height

    Component.onCompleted: {
        if(PlayerData.remainingMaterialsNumber>0){
            PlayerData.remainingMaterialsNumber--
            value++
        }
        var array=materialImageAspectRatioArray
        materialImage.rotation=Math.random()*360
        var index=Math.floor(Math.random()*array.length)
        materialImage.source="qrc:/images/material"+(index+1)+".png"
        var k=1/array[index]
        materialImage.width=Qt.binding(function(){return material.width*k/Math.sqrt(k*k+1)})
        materialImage.height=Qt.binding(function(){return material.width/k})
    }

    function toBag(point){
        toBagAnimation.targetPoint=point
        toBagAnimation.start()
    }

    // 被拾取范围触发：进入磁吸状态，由 Drops.updateFlyingDrops 每帧追踪玩家。
    // 2026-10-04 改为 JS 磁吸：原 QML 飞行动画的 from/to/时长均为实时重算绑定，
    // 跟随移动中的玩家时动画永不结算（停下才成批补收）；磁吸速度恒快于玩家，
    // 追上后实时跟随，追到身上才结算。
    function beGetedTo(target){
        material.isGeted=true
        material.magnetTarget=target
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_material.wav"
        volume: 0.6
    }

    Image{
        id: materialImage
        anchors.centerIn: material
        z: 1
    }

    Canvas {
        id: flame
        width: material.width*1.5
        height: width
        anchors.centerIn: material
        z: 0
        onPaint: {
            var ctx = getContext("2d")
            var gradient = ctx.createRadialGradient(
                        width / 2, height / 2, 0,
                        width / 2, height / 2, width / 2
                        )
            gradient.addColorStop(0,Qt.rgba(0,0.8,0,1))
            gradient.addColorStop(1, Qt.rgba(0,1,0,0))
            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2)
            ctx.fill()
        }
    }

    ParallelAnimation{
        id: toBagAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(0,0)

        PropertyAnimation {
            id: xtoBagAnimation
            target: material
            property: "x"
            from: material.x
            to: toBagAnimation.targetPoint.x-material.width/2
            duration: Tool.getDistance(Qt.point(material.x+material.width/2,material.y+material.height/2),toBagAnimation.targetPoint)
            easing.type: Easing.OutQuart
        }

        PropertyAnimation {
            id: ytoBagAnimation
            target: xtoBagAnimation.target
            property: "y"
            from: material.y
            to: toBagAnimation.targetPoint.y-material.height/2
            duration: xtoBagAnimation.duration
            easing.type: xtoBagAnimation.easing.type
        }

        onStopped: {
            //getSound.play()
            PlayerData.remainingMaterialsNumber++
            material.visible=false
            material.destroy(700)
        }
    }

    // 磁吸命中玩家后结算（由 Drops.updateFlyingDrops 追到后调用）
    function completeCollect(){
        var t = material.magnetTarget
        material.magnetTarget = null
        if (!t) return
        if (SettingsData.materialSound) getSound.play()
        // 材料治疗：拾取材料时恢复 1 HP
        if (PlayerData.materialTherapy > 0) {
            PlayerData.curHp = Math.min(PlayerData.curHp + 1, PlayerData.maxHp)
        }
        // 残渣掉落动画
        for (var i = 0; i < 6; i++) {
            var radius = 13*material.scaleFactor;
            var angle=Math.random() * 2 * 3.14159
            var dx = Math.cos(angle)*(Math.random() * material.width*6-material.width*3)
            var dy = Math.sin(angle)*(Math.random() * material.width*6-material.width*3)+material.width*1.5
            material.makeResidue(t.x+t.width/2,t.y,dx,dy, radius,gameArea);
        }
        t.getMaterial(material)
        material.visible=false
        material.destroy(700)
    }

    function makeResidue(x,y,dx,dy, width, parent){
        ParticlePool.spawnDebris(x, y, dx, dy, width, parent, SettingsData.visualEffects)
    }
}
