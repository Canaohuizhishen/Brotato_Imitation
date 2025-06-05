import QtQuick 2.15

Weapon {
    id: smg
    weaponName: "冲锋枪"

    function fire(){
        if(isFaceRight){
            backAnimation.angle=-rotation
        }else backAnimation.angle=180-rotation
        fireAnimation.start()
        flame.flame()
        var x=smg.parent.x+smg.x+smg.width/2+Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/2
        var y=smg.parent.y+smg.y+smg.height/4-Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/2
        //console.log(gameArea.x)
        var bullet = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Canvas {
                        id: bullet
                        width: smg.width
                        height: width*0.28
                        objectName: "子弹"
                        x: ${x}-width/2;
                        y: ${y}-height/2;
                        z: 5
                        property int damage: ${core.damage}
                        onPaint: {
                            var ctx = getContext("2d")
                            var gradient = ctx.createRadialGradient(
                                        width / 2, height / 2, 0,
                                        width / 2, height / 2, Math.max(width / 2, height / 2)
                                        )
                            gradient.addColorStop(0.64, Qt.rgba(1, 1, 0.45, 1))
                            gradient.addColorStop(1, Qt.rgba(1, 1, 0.5, 0))
                            ctx.fillStyle = gradient
                            ctx.beginPath()
                            ctx.ellipse(0, 0, width, height) // 绘制椭圆
                            ctx.fill()
                        }
                        Component.onCompleted: {
                            rotation=smg.rotation
                            shoot.start()
                        }
                        Canvas {
                            width: bullet.width/1.2
                            height: bullet.height/1.1
                            anchors.centerIn: bullet
                            z: 4
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.fillStyle = Qt.rgba(1, 1, 0.45, 1)
                                ctx.beginPath()
                                ctx.ellipse(0, 0, width, height) // 绘制椭圆
                                ctx.fill()
                            }
                        }
                        Canvas {
                            width: bullet.width/1.5
                            height: bullet.height/1.3
                            anchors.centerIn: bullet
                            z: 5
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.fillStyle = "white"
                                ctx.beginPath()
                                ctx.ellipse(0, 0, width, height) // 绘制椭圆
                                ctx.fill()
                            }
                        }
                        ParallelAnimation {
                            id: shoot
                            running: false
                            property int range: weaponCore.smg.range
                            NumberAnimation { target: bullet; property: "x"; to: x+Math.cos(backAnimation.angle* (Math.PI/180))*shoot.range*gameArea.scaleFactor; loops: 1; duration: 0.6*shoot.range; easing.type: Easing.Linear }
                            NumberAnimation { target: bullet; property: "y"; to: y-Math.sin(backAnimation.angle* (Math.PI/180))*shoot.range*gameArea.scaleFactor;  loops: 1; duration: 0.6*shoot.range; easing.type: Easing.Linear }
                            onStopped: bullet.destroy()
                        }
                    }`,
                    bulletsParent,
                    "dynamicImage"
                    );
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
        }
    }

    SequentialAnimation {
        id: fireAnimation
        loops: 1
        running: false
        property double duration: smg.core.cooldown*1000*0.8

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
    }
}
