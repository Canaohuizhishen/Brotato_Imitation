import QtQuick 2.15
import Brotato
import singleton.PlayerData
import "../data"

Image {
    id: monster
    property Player target: null
    source: "/images/"+monster.monsterName+"_faceRight.png"
    objectName: "Monster"
    property string monsterName
    property var owner: parent
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property int imageWidth
    property int imageHeight
    width: imageWidth*scaleFactor
    height: imageHeight*scaleFactor
    z: 2
    property bool active: true
    property bool isDead: false
    property bool isHited: false
    property bool isFaceRight: true

    property int waveNumber: 0
    property alias monsterData: monsterData
    property var core: monsterCore.getMonster(monsterName)

    property double v: core.initVelocity*scaleFactor
    property int interval: 5
    property double stepSize: v*interval/1200

    Item {
        id: monsterData
        property int maxHp: monster.core.initHp+monster.core.hpBonus*(monster.waveNumber-1)
        property int hp: maxHp
        property int damage: monster.core.initDamage+monster.core.damageBonus*(monster.waveNumber-1)
        property int materialDrops: monster.core.materialDrops
        property double consumableDropRate: monster.core.consumableDropRate
        property double chestDropRate: monster.core.chestDropRate
        onHpChanged: {
            if(hp<=0)monster.kill()
        }
    }

    onScaleFactorChanged: {
        monster.x = monster.x*scaleFactor/lastScaleFactor;
        monster.y = monster.y*scaleFactor/lastScaleFactor;
        lastScaleFactor=scaleFactor
    }

    transform: Scale {
        id: squashScale
        origin.x: monster.width/2
        origin.y: monster.height
        xScale: 1.0; yScale: 1.0
    }

    MonsterCustomizationCore{
        id: monsterCore
    }

    SequentialAnimation {
        id: squashSequence
        loops: Animation.Infinite
        running: true

        // 阶段一：同时扁平 X 并拉长 Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.9; duration: 1000; easing.type: Easing.InOutQuad }
        }
        // 阶段二：同时恢复 X、Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    Timer {
        id: moveTimer
        interval: monster.interval; running: monster.active; repeat: true
        onTriggered: {
                    if(monster.isDead==true)return
                    if(!monster.active)return
                    var dx = (monster.target.x + monster.target.width/2) - (monster.x + monster.width/2);
                    var dy = (monster.target.y + monster.target.height/2) - (monster.y + monster.height/2);
                    var distance = Math.sqrt(dx * dx + dy * dy);

                    if (distance < monster.target.width/2) {//已碰撞
                        monster.hit()
                    } else {
                        var stepX = (dx / distance) * monster.stepSize;
                        var stepY = (dy / distance) * monster.stepSize;
                        monster.x += stepX;
                        monster.y += stepY;
                    }

                    if(dx<0)monster.faceLeft()
                    else monster.faceRight()
        }
    }

    ParallelAnimation{
        id: deadAnimation
        loops: 1
        running: false
        property double multiplier: 1.5
        property double angle: 0

        PropertyAnimation {
            target: monster
            property: "x"
            to:  monster.x+Math.cos(deadAnimation.angle* (Math.PI/180))*monster.width*2.5
            duration: 350*deadAnimation.multiplier
            easing.type: Easing.OutQuart
        }

        PropertyAnimation {
            target: monster
            property: "y"
            to: monster.y+Math.sin(deadAnimation.angle* (Math.PI/180))*monster.width*2.5
            duration: 350  // 动画持续时间
            easing.type: Easing.Linear  // 缓动效果
        }

        onStarted: {
            disappearAnimation.start()
        }
    }

    ParallelAnimation{
        id: disappearAnimation
        loops: 1
        running: false
        PropertyAnimation {
            target: monster
            property: "rotation"
            from: 0
            to: -360
            duration: 400*deadAnimation.multiplier
            easing.type: Easing.InQuad
        }

        PropertyAnimation {
            target: monster
            property: "scale"
            from: 1
            to: 0
            duration: 400 *deadAnimation.multiplier
            easing.type: Easing.Linear
        }
        onStopped:{
            monster.destroy()
        }
    }

    Timer {
        id: stunnedTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            monster.active=true
        }
    }

    Timer {
        id: hitingTimer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            monster.isHited=false
        }
    }

    function faceLeft(){
        monster.source="/images/"+monster.monsterName+"_faceLeft.png"
        isFaceRight=false
    }

    function faceRight(){
        monster.source="/images/"+monster.monsterName+"_faceRight.png"
        isFaceRight=true
    }

    function disappear(){
        monster.isDead=true
        disappearAnimation.start()
    }

    function kill(){
        monster.isDead=true
        monster.owner.dropMaterial(monster)
        deadAnimation.start()
    }

    function stunned(time){
        active=false
        stunnedTimer.interval=time
        stunnedTimer.start()
    }

    function hit(){
        if(isHited)return
        else isHited=true
        PlayerData.curHp-=monster.monsterData.damage
        hitingTimer.start()
    }

    function onHit(bullet) {
        //设置攻击角度
        deadAnimation.angle=monster.isFaceRight ? bullet.rotation+180 : bullet.rotation

        //僵直
        //stunned(100)

        // 白色遮罩动画
        makeMask(monster)

        // 飙血动画
        for (var i = 0; i < 5; i++) {
            var radius = (Math.random() * 10 + 4)*scaleFactor; // 随机半径
            var dx = Math.random() * monster.width*2;
            var dy = Math.random() * monster.width/2-monster.width/4;
            makeBlood(monster.x+monster.width/2,monster.y+monster.height/2,dx,dy, radius,gameArea);
        }

        //掉血
        monsterData.hp-=bullet.damage
    }

    function makeMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: whiteOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/"+monster.monsterName+"_mask_faceRight.png" : "/images/"+monster.monsterName+"_mask_faceLeft.png"
                        z: 100
                        Component.onCompleted: {
                        }

                        OpacityAnimator {
                            id: whiteOverlayAnimator
                            target: whiteOverlay
                            from: 1
                            to: 0
                            duration: 200
                            running: true
                            onStopped: {
                                whiteOverlay.destroy()
                            }
                        }
                    }`,
                    parent,
                    "dynamicImage"
                    );
    }

    function makeBlood(x,y,dx,dy, width, parent){
        var blood = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Rectangle {
                        id: bloodSplatter
                        width: ${width}
                        height: width * 1.1
                        x: ${x}-width/2
                        y: ${y}-height/2
                        color: 'black'
                        visible: true
                        radius: width / 2
                        rotation: -30
                        z: 3

                        Rectangle {
                            width: parent.width / 1.6
                            height: width * 1.2
                            anchors.centerIn: parent
                            color: '#AB0000'
                            visible: parent.visible
                            radius: width / 2
                        }


                        SequentialAnimation {
                            running: bloodSplatter.visible

                            // 向右移动并缩小
                            ParallelAnimation{
                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "x"
                                    to: bloodSplatter.x + ${dx}  // 向右移动的距离
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "y"
                                    to: bloodSplatter.y + ${dy}
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "scale"
                                    from: 1
                                    to: 0.7 //缩放倍数
                                    duration: 350
                                    easing.type: Easing.OutQuad
                                }
                            }

                            onStopped: {
                                bloodSplatter.destroy()
                            }
                        }
                    }`,
                    parent,
                    "dynamicImage"
                    );
    }
}

