import QtQuick 2.15
import Brotato
import singleton.PlayerData
import singleton.MonstersData
import "../components"
import "../data"
import "../tool.js" as Tool

Item {
    id: monster
    property var target: null
    property var bulletsParent
    objectName: "Monster"
    property string monsterName
    property var owner: parent
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property int imageWidth
    property int imageHeight
    width: imageWidth*scaleFactor
    height: imageHeight*scaleFactor
    property int shadowWidth: width
    z: 2
    property bool active: owner.active
    property bool paused: owner.paused
    property bool isMoveStoped: false
    property bool isDead: false
    property bool isDestroy: false
    property bool inHitCoolDown: false
    property bool isFaceRight: true
    property bool isFaceUp: true
    property bool moveDirectionConverse: false
    property bool faceTarget: true
    property bool isFrontHaveOtherMonster: false

    property alias monsterData: monsterData
    property var core: MonstersData.getMonster(monsterName)
    property var monsterCore: MonstersData

    property double v: core.initVelocity * 5 / 6
    property int interval: 10
    property double stepSize: v*interval/1200*scaleFactor

    property var bulletImmunityList: [] //用来记录免疫的子弹，模拟近战武器攻击时的冷却
    property int immuneTime: 250

    Component.onCompleted: {
        core.curNumber++
    }
    Component.onDestruction: {
        core.curNumber--
    }

    onPausedChanged: {
        if(paused==true){
            squashSequence.pause()
            deadAnimation.pause()
            disappearAnimation.pause()
            stunnedTimer.pause()
            hitingTimer.pause()
        }else{
            squashSequence.resume()
            deadAnimation.resume()
            disappearAnimation.resume()
            stunnedTimer.resume()
            hitingTimer.resume()
        }
    }

    Item {
        id: monsterData
        property int maxHp: monster.core.initHp+monster.core.hpBonus*(PlayerData.currentWaveNumber-1)
        property int hp: maxHp
        property int damage: monster.core.initDamage+monster.core.damageBonus*(PlayerData.currentWaveNumber-1)
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

    WeaponCustomizationCore{
        id: weaponCore
    }

    transform: Scale {
        id: squashScale
        origin.x: monster.width/2
        origin.y: monster.height
        xScale: 1.0; yScale: 1.0
    }

    Image{
        id: monsterIcon
        source: "/images/"+monster.monsterName+"_faceRight.png"
        anchors.fill: parent
        z: 1
    }

    Image {
        id: whiteOverlay
        anchors.fill: monsterIcon
        source: monster.isFaceRight ? "/images/"+monster.monsterName+"_mask_faceRight.png" : "/images/"+monster.monsterName+"_mask_faceLeft.png"
        opacity: 0
        z: 100
    }

    Canvas {
        id: shadow
        width: monster.shadowWidth/1.1
        height: width/4
        anchors.bottom: monster.bottom
        anchors.bottomMargin: -height/6
        anchors.horizontalCenter: monster.horizontalCenter

        onPaint: {
            var ctx = getContext("2d");
            ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
            ctx.beginPath();
            ctx.ellipse(0, 0, width, height);
            ctx.fill();
        }
    }

    SequentialAnimation {
        id: squashSequence
        loops: Animation.Infinite
        running: monster.active

        // 阶段一：同时扁平 X 并拉长 Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.1; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.9; duration: 600; easing.type: Easing.InOutQuad }
        }
        // 阶段二：同时恢复 X、Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: 600; easing.type: Easing.InOutQuad }
        }
        function pause(){
            if(running)paused=true
        }
    }

    function updateMovement(deltaTime) {
        if (isDead) return
        if (isFrontHaveOtherMonster || isMoveStoped) return
        if (!active || paused) return

        var dx = (target.x + target.width / 2) - (x + width / 2)
        var dy = (target.y + target.height / 2) - (y + height / 2)
        var distance = Math.sqrt(dx * dx + dy * dy)

        if (distance < target.width / 2) {
            // 已碰撞
            hit()
        } else {
            var stepSize = v * deltaTime
            var stepX = (dx / distance) * stepSize
            var stepY = (dy / distance) * stepSize
            if (moveDirectionConverse) {
                if (x > 0 && x < parent.width - width) x -= stepX
                if (y > 0 && y < parent.height - height) y -= stepY
            } else {
                x += stepX
                y += stepY
            }
        }

        z = y + height  // Y 排序
    }

    Timer {
        id: checkFaceDirectionTimer
        interval: 175; running: monster.faceTarget && !monster.paused; repeat: true
        onTriggered: {
            var dx = (monster.target.x + monster.target.width/2) - (monster.x + monster.width/2);
            var dy = (monster.target.y + monster.target.height/2) - (monster.y + monster.height/2);
            if(dx<0){
                if(monster.moveDirectionConverse)monster.faceRight()
                else monster.faceLeft()
            }else {
                if(monster.moveDirectionConverse)monster.faceLeft()
                else monster.faceRight()
            }
            if(dy<0)monster.isFaceUp=true
            else monster.isFaceUp=false
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
        function pause(){
            if(running)paused=true
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
            if (monster.owner && monster.owner.unregisterMonsterCallbacks)
                monster.owner.unregisterMonsterCallbacks(monster)
            monster.isDestroy = true
            monster.destroy()
        }
        function pause(){
            if(running)paused=true
        }
    }

    TimerCanPause {
        id: stunnedTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            monster.active=true
        }
    }

    TimerCanPause {
        id: hitingTimer
        interval: 250
        running: false
        repeat: false
        onTriggered: {
            monster.inHitCoolDown=false
        }
    }

    //无法暂停whiteOverlayAnimator
    OpacityAnimator {
        id: whiteOverlayAnimator
        target: whiteOverlay
        from: 1
        to: 0
        duration: 200
        running: false
    }

    function faceLeft(){
        monsterIcon.source="/images/"+monster.monsterName+"_faceLeft.png"
        isFaceRight=false
    }

    function faceRight(){
        monsterIcon.source="/images/"+monster.monsterName+"_faceRight.png"
        isFaceRight=true
    }

    function isInEdge(){
        return monster.x<1 || monster.y<1 || monster.x>monster.parent.width-monster.width-1 || monster.y>monster.parent.height-monster.height-1
    }

    function disappear(){
        monster.isDead=true
        disappearAnimation.start()
    }

    function kill(){
        monster.isDead=true
        //掉落材料
        monster.owner.dropMaterial(monster)
        //可能掉落果实
        if(Math.random()<core.consumableDropRate)
            monster.owner.dropFruit(monster)
        //可能掉落宝箱
        if(Math.random()<core.chestDropRate)
            monster.owner.dropChest(monster)
        deadAnimation.start()
    }

    function stunned(time){
        active=false
        stunnedTimer.interval=time
        stunnedTimer.start()
    }

    function hit(){
        if(inHitCoolDown)return
        else inHitCoolDown=true

        //模拟角色被子弹击中
        var _x=(x+width/2+target.x+target.width/2)/2
        var _y=(y+height/2+target.y+target.height/2)/2
        var bullet={damage: monster.monsterData.damage, x: _x, y: _y}
        target.onHit(bullet)

        hitingTimer.start()
    }

    function addImmuneBullet(bullet){
        bulletImmunityList.push(bullet)
        var timer = Qt.createQmlObject(`
                    import QtQuick 2.15
                    Timer {
                        interval: ${immuneTime}
                        running: true
                        repeat: false
                        onTriggered: {
                            monster.bulletImmunityList.shift()
                            destroy();
                        }
                    }
                `, monster, "dynamicTimer");
    }

    function onHit(bullet) {
        //在免疫子弹列表中直接返回
        if(bulletImmunityList.indexOf(bullet)!=-1)return
        else addImmuneBullet(bullet)

        //设置击飞角度
        deadAnimation.angle=bullet.rotation

        //僵直
        //stunned(100)

        // 白色遮罩动画
        whiteOverlayAnimator.start()

        // 飙血动画
        for (var i = 0; i < 5; i++) {
            var radius = (Math.random() * 10 + 4)*scaleFactor; // 随机半径
            var dx = Math.random() * monster.width*2;
            var dy = Math.random() * monster.width/2-monster.width/4;
            makeBlood(monster.x+monster.width/2,monster.y+monster.height/2,dx,dy, radius,gameArea);
        }

        //可能的暴击
        if(Math.random()<bullet.critical/100){
            monsterData.hp-=bullet.damage*bullet.criticalDamageRate
            Tool.createText(owner,bullet.damage*2,27*scaleFactor,"yellow",bullet.x,bullet.y)
        }else{
            monsterData.hp-=bullet.damage
            Tool.createText(owner,bullet.damage,27*scaleFactor,"white",bullet.x,bullet.y)
        }

        //可能的生命窃取
        if(Math.random()<PlayerData.lifeSteal/100){
            PlayerData.curHp++
            Tool.createText(owner,"+1",24*scaleFactor,"lime",target.x,target.y-24*scaleFactor)
        }
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

