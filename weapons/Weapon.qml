import QtQuick 2.15
import "../tool.js" as Tool
import "../components"
import "../data"

Item {
    id: weapon
    objectName: "Weapon"
    property string weaponName
    property int grade: 1
    property double scaleFactor: 1
    //transformOrigin: Item.Left
    property var bulletsParent: parent
    property var originPos: Qt.point(weapon.x,weapon.y)
    property var core: weaponCore.getWeapon(weapon.weaponName,grade)
    property var targetPoint: null
    property bool active: true
    property bool paused: true
    property bool isFaceRight: true
    property bool isAiming: false
    property bool inFire: false
    property bool inCoolDown: false
    property bool isDestroy: false //用来标记是否已销毁，因为qml的destroy()是异步方法
    property double baseWidth: 45*core.scaleRatio
    width: baseWidth*scaleFactor
    height: width*core.aspectRatio
    z: 2
    rotation: 0

    onActiveChanged: {
        if(active==false)rotationReset()
    }

    onTargetPointChanged: {
        if(targetPoint!=null)aimToTarget()
        else rotationReset()
    }

    Image{
        id: weaponIcon
        source: weapon.grade>1 ? "/images/"+weapon.weaponName+"-mask-"+weapon.grade+(weaponIcon.isRight ? "_faceRight.png" : "_faceLeft.png") : ""
        width: weapon.width+6*weapon.scaleFactor
        height: weapon.height+6*weapon.scaleFactor
        anchors.centerIn: weapon
        property bool isRight: true
        z: 2

        Image{
            source: "/images/"+weapon.weaponName+(weaponIcon.isRight ? "_faceRight.png" : "_faceLeft.png")
            width: weapon.width
            height: weapon.height
            anchors.centerIn: parent
        }
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    Timer {
        id: waitTimer
        interval: rotate.duration
        running: false
        repeat: false
        property double angle
        property int degree
        onTriggered: {
            rotateBehavior.stop()
            if(weapon.isFaceRight){
                weapon.faceLeft()
                weapon.rotation=Tool.reduceAbs(weapon.rotation,180)
                //angle-=10//图片偏移量，确保枪口朝向目标点
            }else {
                weapon.faceRight()
                weapon.rotation=Tool.reduceAbs(weapon.rotation,180)
                //angle+=10//图片偏移量，确保枪口朝向目标点
            }
            rotateBehavior.start()
            rotate.duration=waitTimer.degree*rotate.durationPerDegree
            weapon.rotation=waitTimer.angle
            weapon.isAiming=false
        }
    }

    Behavior on rotation {
        id: rotateBehavior
        //enabled: false
        function stop(){enabled=false}
        function start(){enabled=true}
        RotationAnimation {
            id: rotate
            target: weapon
            readonly property double  durationPerDegree: 0.5
            duration: 30000
            easing.type: Easing.Linear
            direction: RotationAnimation.Shortest
            onDurationChanged: {
                if(duration>90*durationPerDegree)duration=90*durationPerDegree
            }
        }
    }

    function rotationReset(){
        rotation=0
    }

    function faceLeft(){
        if(!isFaceRight)return
        weaponIcon.isRight=false
        isFaceRight=false
    }

    function faceRight(){
        if(isFaceRight)return
        weaponIcon.isRight=true
        isFaceRight=true
    }

    function aimToTarget() {
        if(weapon.targetPoint==null)return
        isAiming=true
        var originRotation=weapon.rotation
        rotate.duration=100
        var dx = weapon.targetPoint.x - (weapon.x+weapon.width/2);
        var dy = weapon.targetPoint.y - (weapon.y+weapon.height/2);
        var angle =  Math.atan2(dy, dx) * 180 / Math.PI;
        if(dx<0){
            if(!isFaceRight){
                rotate.duration=(Math.abs(Tool.reduceAbs(angle,180)-originRotation))*rotate.durationPerDegree
                //angle-=10//图片偏移量，确保枪口朝向目标点
                weapon.rotation=Tool.reduceAbs(angle,180)
                weapon.isAiming=false
                return
            }
            if(Tool.getQuadrant(-angle)===2){
                if(Tool.getQuadrant(-originRotation)===1)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation)===4)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 2 error")
                rotation=-90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=Tool.reduceAbs(angle,180)
                waitTimer.start()
            }else if(Tool.getQuadrant(-angle)===3){
                if(Tool.getQuadrant(-originRotation)===1)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation)===4)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
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
                weapon.rotation=angle
                weapon.isAiming=false
                return
            }
            if(Tool.getQuadrant(-angle)===1){
                if(Tool.getQuadrant(originRotation+90)===2)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation+180)===3)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 1 error")
                rotation=90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=angle
                waitTimer.start()
            }else if(Tool.getQuadrant(-angle)===4){
                if(Tool.getQuadrant(-originRotation+180)===2)rotate.duration=(90+Math.abs(originRotation))*rotate.durationPerDegree
                else if(Tool.getQuadrant(-originRotation+180)===3)rotate.duration=(90-Math.abs(originRotation))*rotate.durationPerDegree
                //else console.log("to 4 error",Tool.getQuadrant(-originRotation+180))
                rotation=-90
                waitTimer.degree=Math.abs(Tool.reduceAbs(angle,90))
                waitTimer.angle=angle
                waitTimer.start()
            }
        }
    }
}
