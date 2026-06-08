import QtQuick 2.15

MeleeWeapon {
    id: spear
    weaponName: "spear"
    aimSpeedMultiplier: 0.2
    property double fireRotation: 0

    onPausedChanged: {
        if(paused==true){
            fireAnimation.pause()
        }else{
            fireAnimation.resume()
        }
    }

    onInFireChanged: {
        if(inFire){
            meleeBullet.inHitCoolDown=false
        }else{
            meleeBullet.inHitCoolDown=true
            if (targetPoint === null) {
                rotationReset()
            }
        }
    }

    SequentialAnimation {
        id: fireAnimation
        loops: 1
        running: false
        property double duration: spear.core.attackTime*1000
        property double angle: 0
        property double range: spear.core.range*spear.scaleFactor

        ParallelAnimation {
            id: retreatAnimation
            property double duration: fireAnimation.duration*0.15
            NumberAnimation { target: spear; property: "x"; from: spear.originPos.x; to: from-Math.cos(fireAnimation.angle* (Math.PI/180))*spear.width/8; duration: retreatAnimation.duration; easing.type: Easing.OutExpo }
            NumberAnimation { target: spear; property: "y"; from: spear.originPos.y; to: from+Math.sin(fireAnimation.angle* (Math.PI/180))*spear.width/8; duration: retreatAnimation.duration; easing.type: Easing.OutExpo }
        }

        ParallelAnimation {
            id: goAnimation
            property double duration: fireAnimation.duration*0.6
            NumberAnimation { target: spear; property: "x"; to: spear.originPos.x+Math.cos(fireAnimation.angle* (Math.PI/180))*fireAnimation.range; duration: goAnimation.duration; easing.type: Easing.OutExpo }
            NumberAnimation { target: spear; property: "y"; to: spear.originPos.y-Math.sin(fireAnimation.angle* (Math.PI/180))*fireAnimation.range; duration: goAnimation.duration; easing.type: Easing.OutExpo }
        }

        ParallelAnimation {
            id: backAnimation
            property double duration: fireAnimation.duration*0.25
            NumberAnimation { target: spear; property: "x"; to: spear.originPos.x; duration: backAnimation.duration; easing.type: Easing.OutExpo }
            NumberAnimation { target: spear; property: "y"; to: spear.originPos.y; duration: backAnimation.duration; easing.type: Easing.OutExpo }
        }
        onStopped: {
            spear.inFire=false
        }
        function pause(){
            if(running)paused=true
        }
    }

    function fire(){
        attackSound.play()
        inFire=true
        var dx = targetPoint.x - (x + width / 2)
        var dy = targetPoint.y - (y + height / 2)
        fireAnimation.angle = Math.atan2(-dy, dx) * 180 / Math.PI
        // 强制对齐矛身指向与刺出方向，覆盖背面跳过逻辑
        _snapRotation(true)
        fireAnimation.start()
    }
}
