import QtQuick 2.15

MeleeWeapon {
    id: spear
    weaponName: "spear"
    property double fireRotation: 0
    property var meleeBullet

    onRotationChanged: {
        if(inFire)rotation=fireRotation
    }

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
        }
    }

    Component.onCompleted: {
        sleepTimer.start()
    }

    Timer {
        id: sleepTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            spear.meleeBullet=spear.createMeleeBullet()
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
            NumberAnimation { target: spear; property: "x"; to: spear.originPos.x+Math.cos(fireAnimation.angle* (Math.PI/180))*fireAnimation.range; duration: fireAnimation.range*1.2; easing.type: Easing.OutExpo }
            NumberAnimation { target: spear; property: "y"; to: spear.originPos.y-Math.sin(fireAnimation.angle* (Math.PI/180))*fireAnimation.range; duration: fireAnimation.range*1.2; easing.type: Easing.OutExpo }
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
        inFire=true
        fireRotation=rotation
        if(isFaceRight){
            fireAnimation.angle=-rotation
        }else fireAnimation.angle=180-rotation
        fireAnimation.start()
    }

    function createMeleeBullet(){
        var bulletComponent = Qt.createComponent("../bullets/MeleeBullet.qml")
        if (bulletComponent.status === Component.Ready) {
            var bullet = bulletComponent.createObject(bulletsParent);
            bullet.target=spear
            bullet.critical=core.critical
            bullet.damage=core.damage
        }else console.error("Error loading component:", bulletComponent.errorString())
        return bullet
    }
}
