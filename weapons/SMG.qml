import QtQuick 2.15
import QtQuick.Window 2.15
import "../tool.js" as Tool
import "../data"

Image {
    id: smg
    source: "/images/冲锋枪朝右.png"
    objectName: "冲锋枪"
    property double scaleFactor: 1
    width: 45*scaleFactor
    height: width*0.683
    z: 2
    rotation: 0
    //transformOrigin: Item.Left
    property var data: weaponCore.getWeapon(smg.objectName)
    property var targetPoint: null
    property var lastTargetPoint: null
    property bool isFaceRight: true
    property bool isAiming: false

    function rotationReset(){
        rotation=0
    }

    function faceLeft(){
        if(!isFaceRight)return
        smg.source="/images/冲锋枪朝左.png"
        isFaceRight=false
    }

    function faceRight(){
        if(isFaceRight)return
        smg.source="/images/冲锋枪朝右.png"
        isFaceRight=true
    }

    function aimToTarget() {
        if(smg.targetPoint==null)return
        isAiming=true
        var originRotation=smg.rotation
        rotate.duration=100
        var dx = smg.targetPoint.x - (smg.x+smg.width/2);
        var dy = smg.targetPoint.y - (smg.y+smg.height/2);
        var angle =  Math.atan2(dy, dx) * 180 / Math.PI;
        if(dx<0){
            if(!isFaceRight){
                rotate.duration=(Math.abs(Tool.reduceAbs(angle,180)-originRotation))*rotate.durationPerDegree
                //angle-=10//图片偏移量，确保枪口朝向目标点
                smg.rotation=Tool.reduceAbs(angle,180)
                smg.isAiming=false
                return
            }
            if(Tool.getQuadrant(-angle)==2){
                if(Tool.getQuadrant(-originRotation)==1)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation)==4)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 2 error")
                rotation=-90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=Tool.reduceAbs(angle,180)
                waitTimer.start()
            }else if(Tool.getQuadrant(-angle)==3){
                if(Tool.getQuadrant(-originRotation)==1)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation)==4)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 3 error ",Tool.getQuadrant(-originRotation))
                rotation=90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=Tool.reduceAbs(angle,180)
                waitTimer.start()
            }
        }else{
            if(isFaceRight){
                rotate.duration=(Math.abs(angle-originRotation))*rotate.durationPerDegree
                //angle+=10//图片偏移量，确保枪口朝向目标点
                smg.rotation=angle
                smg.isAiming=false
                return
            }
            if(Tool.getQuadrant(-angle)==1){
                if(Tool.getQuadrant(originRotation+90)==2)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation+180)==3)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 1 error")
                rotation=90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=angle
                waitTimer.start()
            }else if(Tool.getQuadrant(-angle)==4){
                if(Tool.getQuadrant(-originRotation+180)==2)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation+180)==3)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 4 error",Tool.getQuadrant(-originRotation+180))
                rotation=-90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=angle
                waitTimer.start()
            }
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
                        property int damage: ${data.damage}
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
                            property int range: weaponCore.getWeapon(smg.objectName).range
                            NumberAnimation { target: bullet; property: "x"; to: x+Math.cos(backAnimation.angle* (Math.PI/180))*shoot.range*gameArea.scaleFactor; loops: 1; duration: 0.6*shoot.range; easing.type: Easing.Linear }
                            NumberAnimation { target: bullet; property: "y"; to: y-Math.sin(backAnimation.angle* (Math.PI/180))*shoot.range*gameArea.scaleFactor;  loops: 1; duration: 0.6*shoot.range; easing.type: Easing.Linear }
                            onStopped: bullet.destroy()
                        }
                    }`,
                    gameArea,
                    "dynamicImage"
                    );
    }

    onTargetPointChanged: {
        if(targetPoint!=null)aimToTarget()
        else rotationReset()
    }

    Canvas {
        id: flame
        visible: false
        parent: smg
        width: smg.width
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
            gradient.addColorStop(0.64,Qt.rgba(1,1,0.45,1))
            gradient.addColorStop(0.65, Qt.rgba(1,1,0.5,0.6))
            gradient.addColorStop(0.9, Qt.rgba(1,1,0.5,0.1))
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
            to: from+flame.width/2
            duration: fireAnimation.duration/10
            loops: 1
            easing.type: Easing.OutCirc
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
            from : -flame.width/2
            to: from-flame.width/2
            duration: fireAnimation.duration/10
            loops: 1
            easing.type: Easing.OutCirc
            onStopped: {
                flame.visible=false
                flame.x=from
            }
        }
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    Timer {
        id: fireTimer
        interval: fireAnimation.duration
        running: smg.targetPoint!=null
        repeat: true
        onTriggered: {
            if(!smg.isAiming)smg.fire()
        }
    }

    Timer {
        id: waitTimer
        interval: rotate.duration
        running: false
        repeat: false
        property double angle
        property int degree
        onTriggered: {
            rotateBehavior.pause()
            if(smg.isFaceRight){
                smg.faceLeft()
                smg.rotation=Tool.reduceAbs(smg.rotation,180)
                //angle-=10//图片偏移量，确保枪口朝向目标点
            }else {
                smg.faceRight()
                smg.rotation=Tool.reduceAbs(smg.rotation,180)
                //angle+=10//图片偏移量，确保枪口朝向目标点
            }
            rotateBehavior.resume()
            rotate.duration=waitTimer.degree*rotate.durationPerDegree
            smg.rotation=waitTimer.angle
            smg.isAiming=false
        }
    }

    Behavior on rotation {
        id: rotateBehavior
        //enabled: false
        function pause(){enabled=false}
        function resume(){enabled=true}
        NumberAnimation {
            id: rotate
            readonly property int  durationPerDegree: 1
            duration: 2000
            easing.type: Easing.Linear
        }
    }

    SequentialAnimation {
        id: fireAnimation
        loops: 1
        running: false
        property double duration: 170
        property var originPos: Qt.point(smg.x,smg.y)

        onStarted: {
            originPos=Qt.point(smg.x,smg.y)
        }

        ParallelAnimation {
            id: backAnimation
            property double duration: fireAnimation.duration/2.5
            property double angle
            NumberAnimation { target: smg; property: "x"; from: fireAnimation.originPos.x; to: from-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/5; duration: 0; easing.type: Easing.OutCirc }
            NumberAnimation { target: smg; property: "x"; from: fireAnimation.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/5; to: fireAnimation.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/4; duration: backAnimation.duration; easing.type: Easing.OutCirc }
            NumberAnimation { target: smg; property: "y"; from: fireAnimation.originPos.y; to: from+Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/4;  duration: backAnimation.duration; easing.type: Easing.OutCirc }
        }

        ParallelAnimation {
            id: recoverAnimation
            property double duration: fireAnimation.duration/2.5*1.5
            NumberAnimation { target: smg; property: "x"; from: fireAnimation.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*smg.width/4; to: fireAnimation.originPos.x; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
            NumberAnimation { target: smg; property: "y"; from: fireAnimation.originPos.y+Math.sin(backAnimation.angle* (Math.PI/180))*smg.width/4; to: fireAnimation.originPos.y; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
        }
    }
}
