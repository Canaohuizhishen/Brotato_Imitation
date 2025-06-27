import QtQuick 2.15

RangedWeapon {
    id: smg
    weaponName: "smg"

    onPausedChanged: {
        if(paused==true){
            flame.pause()
            fireAnimation.pause()
        }else{
            flame.resume()
            fireAnimation.resume()
        }
    }

    Canvas {
        id: flame
        visible: false
        parent: smg
        width: smg.width*1.2
        height: width
        x: smg.isFaceRight ? flame.width*3/4 : -flame.width*3/4
        y: (smg.height-flame.height)*0.8
        z: 5
        onPaint: {
            var ctx = getContext("2d")
            var gradient = ctx.createRadialGradient(
                        width / 2, height / 2, 0,
                        width / 2, height / 2, width / 2
                        )
            gradient.addColorStop(0,"white")
            gradient.addColorStop(0.49,"white")
            gradient.addColorStop(0.50,Qt.rgba(1,1,0.45,1))
            gradient.addColorStop(0.70,Qt.rgba(1,1,0.45,1))
            gradient.addColorStop(0.71, Qt.rgba(1,1,0.5,0.6))
            gradient.addColorStop(0.91, Qt.rgba(1,1,0.5,0.1))
            gradient.addColorStop(1, Qt.rgba(1,1,0.5,0))
            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2)
            ctx.fill()
        }

        function flame(){
            visible=true
            if(smg.isFaceRight)flameAnimationRight.start()
            else flameAnimationLeft.start()
        }

        NumberAnimation {
            id: flameAnimationRight
            running: false
            target: flame
            property: "x"
            from : flame.width/2
            to: from+flame.width/8
            duration: (smg.core.cooldown*1000)/10
            loops: 1
            easing.type: Easing.InQuad
            onStopped: {
                flame.visible=false
                flame.x=from
            }
            function pause(){
                if(running)paused=true
            }
        }

        NumberAnimation {
            id: flameAnimationLeft
            running: false
            target: flame
            property: "x"
            from : -flame.width*3/4
            to: from-flame.width/8
            duration: (smg.core.cooldown*1000)/10
            loops: 1
            easing.type: Easing.InQuad
            onStopped: {
                flame.visible=false
                flame.x=from
            }
            function pause(){
                if(running)paused=true
            }
        }
        function pause(){
            if(flameAnimationRight.running)flameAnimationRight.paused=true
            if(flameAnimationLeft.running)flameAnimationLeft.paused=true
        }
        function resume(){
            if(smg.isFaceRight)flameAnimationRight.resume()
            else flameAnimationLeft.resume()
        }
    }

    SequentialAnimation {
        id: fireAnimation
        loops: 1
        running: false
        property double duration: smg.core.attackTime*1000

        ParallelAnimation {
            id: backAnimation
            property double duration: fireAnimation.duration/2.5
            property double angle
            NumberAnimation { target: smg; property: "x"; from: smg.originPos.x; to: from-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/5; duration: 0; easing.type: Easing.OutCirc }
            NumberAnimation { target: smg; property: "x"; from: smg.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/5; to: smg.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/4; duration: backAnimation.duration; easing.type: Easing.OutCirc }
            NumberAnimation { target: smg; property: "y"; from: smg.originPos.y; to: from+Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/4;  duration: backAnimation.duration; easing.type: Easing.OutCirc }
        }

        ParallelAnimation {
            id: recoverAnimation
            property double duration: fireAnimation.duration/2.5*1.5
            NumberAnimation { target: smg; property: "x"; from: smg.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/4; to: smg.originPos.x; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
            NumberAnimation { target: smg; property: "y"; from: smg.originPos.y+Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/4; to: smg.originPos.y; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
        }
        onStopped: {
            smg.x=smg.originPos.x
            smg.y=smg.originPos.y
        }
        function pause(){
            if(running)paused=true
        }
    }

    function fire(){
        if(isFaceRight){
            backAnimation.angle=-rotation
        }else backAnimation.angle=180-rotation
        fireAnimation.start()
        flame.flame()
        var x=smg.parent.x+smg.x+smg.width/2+Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/2
        var y=smg.parent.y+smg.y+smg.height/4-Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/2
        var bulletComponent = Qt.createComponent("../bullets/EllipticalMovingBullet.qml")
        if (bulletComponent.status === Component.Ready) {
            var bullet = bulletComponent.createObject(bulletsParent);
            bullet.scaleFactor=Qt.binding(function(){return smg.scaleFactor})
            bullet.paused=Qt.binding(function(){return smg.paused})
            bullet.critical=core.critical
            bullet.width=smg.width*1.2
            bullet.height=bullet.width*0.28
            bullet.x=x - bullet.width / 2
            bullet.y=y - bullet.height / 2
            bullet.originPoint=Qt.point(x - bullet.width / 2,y - bullet.height / 2)
            bullet.color=Qt.rgba(1, 1, 0.45, 1)
            bullet.damage=core.damage
            bullet.fireRate=2000
            bullet.fireRange=core.range
            bullet.shootAngle=backAnimation.angle
        }else console.error("Error loading component:", bulletComponent.errorString())
    }
}
