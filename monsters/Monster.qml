import QtQuick 2.15
import Brotato
import singleton.PlayerData
import singleton.MonstersData
import singleton.SettingsData
import "../components"
import "../data/cores"
import "../logic/utils/tool.js" as Tool
import "../logic/ParticlePool.js" as ParticlePool

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
    property string _spatialId: ""
    property bool _isInViewport: x + width > -200 && x < parent.width + 200 &&
                                  y + height > -200 && y < parent.height + 200

    property alias monsterData: monsterData
    property var core: MonstersData.getMonster(monsterName)
    property var monsterCore: MonstersData

    property double v: core.initVelocity * (SettingsData.enemySpeedModifier / 100.0) * (1 + PlayerData.enemySpeed / 100)
    property int interval: 10
    property double stepSize: v*interval/1200*scaleFactor

    property var bulletImmunityList: [] //用来记录免疫的子弹，模拟近战武器攻击时的冷却
    property int immuneTime: 250
    property bool _reachedTarget: false
    property double blockedTime: 0   // 当前阻塞时长（秒），用于超时换向

    // 到达目标点时的钩子，子类可覆盖（如 Scavenger 抵达后立即换方向）
    function onReachTarget() {
        // 基类空实现
    }

    // 阻塞超时（1 秒）时的钩子，子类可覆盖
    function onBlockedTimeout() {
        // 基类空实现
    }

    Component.onCompleted: {
        core.curNumber++
        // 生成空间网格唯一 ID（不使用 monsterName 以避免初始化时序问题）
        _spatialId = "monster_" + Math.random().toString(36).substr(2, 8)
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
            burnTimer.pause()
        }else{
            squashSequence.resume()
            deadAnimation.resume()
            disappearAnimation.resume()
            stunnedTimer.resume()
            hitingTimer.resume()
            burnTimer.resume()
        }
    }

    Item {
        id: monsterData
        property int maxHp: Math.round((monster.core.initHp+monster.core.hpBonus*(PlayerData.currentWaveNumber-1)) * (SettingsData.enemyHpModifier / 100.0))
        property int hp: maxHp
        property int damage: Math.round((monster.core.initDamage+monster.core.damageBonus*(PlayerData.currentWaveNumber-1)) * (SettingsData.enemyDamageModifier / 100.0))
        property int materialDrops: monster.core.materialDrops
        property double consumableDropRate: monster.core.consumableDropRate
        property double chestDropRate: monster.core.chestDropRate
        // 燃烧状态
        property bool isBurning: false
        property int burnDamagePerTick: 0
        property int burnTicksRemaining: 0
        onHpChanged: {
            if(hp<=0)monster.kill()
        }
        onIsBurningChanged: {
            if (isBurning) {
                burnTimer.start()
            } else {
                burnTimer.stop()
            }
        }
    }

    // 燃烧 DOT 计时器
    TimerCanPause {
        id: burnTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if (monsterData.burnTicksRemaining > 0 && !monster.isDead) {
                monsterData.hp -= monsterData.burnDamagePerTick
                monsterData.burnTicksRemaining--
                if (SettingsData.showDamageNumbers)
                    Tool.createText(monster, "-" + monsterData.burnDamagePerTick, 22*monster.scaleFactor, "orange", monster.x, monster.y - 10*monster.scaleFactor)
            }
            if (monsterData.burnTicksRemaining <= 0) {
                monsterData.isBurning = false
            }
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
        transform: Scale {
            origin.x: monsterIcon.width / 2
            xScale: monster.isFaceRight ? 1 : -1
        }
    }

    Image {
        id: whiteOverlay
        anchors.fill: monsterIcon
        source: "/images/"+monster.monsterName+"_mask_faceRight.png"
        opacity: 0
        z: 100
        transform: Scale {
            origin.x: whiteOverlay.width / 2
            xScale: monster.isFaceRight ? 1 : -1
        }
    }

    // Boss 血条
    Item {
        id: bossHpBar
        visible: monster.core.isBoss && SettingsData.showBossHealthBar
        opacity: 0.7
        anchors.bottom: monsterIcon.top
        anchors.bottomMargin: 4 * scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        width: 45 * scaleFactor
        height: 11 * scaleFactor
        z: 101

        Rectangle {
            id: hpBarBg
            anchors.fill: parent
            color: "#454545"
            border.color: "black"
            border.width: hpBarFill.anchors.margins
            radius: 2
        }

        Rectangle {
            id: hpBarFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2.3
            width: (parent.width - anchors.margins*2) * Math.max(0, monsterData.hp / monsterData.maxHp)
            color: Qt.rgba(0.7, 0, 0, 1)
            radius: 1
        }
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
        running: monster.active && monster._isInViewport

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
        if (isMoveStoped) return
        if (!active || paused) return

        var dx = (target.x + target.width / 2) - (x + width / 2)
        var dy = (target.y + target.height / 2) - (y + height / 2)
        var distance = Math.sqrt(dx * dx + dy * dy)
        var stepSize = v * deltaTime

        if (isFrontHaveOtherMonster) {
            // 侧向混合移动：前向分量（30%）+ 垂直滑开分量（60%）
            blockedTime += deltaTime
            if (distance > 0.01) {
                var nx = dx / distance
                var ny = dy / distance
                // 垂直方向（逆时针旋转90°）
                var pnx = -ny
                var pny = nx

                var newX = x + nx * stepSize * 0.3 + pnx * stepSize * 0.6
                var newY = y + ny * stepSize * 0.3 + pny * stepSize * 0.6

                // 边界 clamp，防止滑出屏幕
                if (newX >= 0 && newX <= parent.width - width) x = newX
                if (newY >= 0 && newY <= parent.height - height) y = newY
            }
            // 阻塞超过 1 秒 → 触发换向钩子
            if (blockedTime > 1.0) {
                blockedTime = 0
                onBlockedTimeout()
            }
            z = y + height
            return
        }
        blockedTime = 0

        if (distance < target.width / 2) {
            // 已碰撞
            hit()
            _reachedTarget = false
        } else if (distance > 0.01) {
            // 实际步长不超过剩余距离，防止过冲振荡
            var actualStep = Math.min(stepSize, distance)
            var stepX = (dx / distance) * actualStep
            var stepY = (dy / distance) * actualStep
            if (moveDirectionConverse) {
                if (x > 0 && x < parent.width - width) x -= stepX
                if (y > 0 && y < parent.height - height) y -= stepY
            } else {
                x += stepX
                y += stepY
            }
            _reachedTarget = false
        } else if (!_reachedTarget) {
            // 首次进入已到达状态 → 通知子类（Scavenger 立即换方向）
            _reachedTarget = true
            onReachTarget()
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
    NumberAnimation {
        id: whiteOverlayAnimator
        target: whiteOverlay
        property: "opacity"
        from: 0.6
        to: 0
        duration: 200
    }

    function faceLeft(){
        isFaceRight=false
    }

    function faceRight(){
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
        // 第20波击杀Boss(prayer)立即通关
        if(PlayerData.currentWaveNumber===20 && core.isBoss){
            PlayerData.isInCombat=false
        }
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
        var bullet={damage: monster.monsterData.damage, x: _x, y: _y, rotation: 0}
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

        //击退效果
        if (PlayerData.repel > 0) {
            var repelAngle = bullet.rotation * (Math.PI / 180)
            var repelDist = PlayerData.repel * scaleFactor
            var newX = monster.x + Math.cos(repelAngle) * repelDist
            var newY = monster.y - Math.sin(repelAngle) * repelDist
            //边界约束
            if (newX >= 0 && newX <= monster.parent.width - monster.width) monster.x = newX
            if (newY >= 0 && newY <= monster.parent.height - monster.height) monster.y = newY
        }

        //僵直
        //stunned(100)

        // 白色遮罩动画
        whiteOverlayAnimator.restart()

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
            if(SettingsData.showDamageNumbers) Tool.createText(owner,bullet.damage*2,27*scaleFactor,"yellow",bullet.x,bullet.y)
        }else{
            monsterData.hp-=bullet.damage
            if(SettingsData.showDamageNumbers) Tool.createText(owner,bullet.damage,27*scaleFactor,"white",bullet.x,bullet.y)
        }

        //对 Boss 额外伤害
        if (monster.core.isBoss && PlayerData.damageToBoss > 0) {
            var bossExtraDmg = Math.floor(bullet.damage * PlayerData.damageToBoss / 100)
            monsterData.hp -= bossExtraDmg
            if (SettingsData.showDamageNumbers) Tool.createText(owner, "+" + bossExtraDmg, 22*scaleFactor, "purple", bullet.x, bullet.y - 20*scaleFactor)
        }

        //可能的燃烧触发
        if (bullet.burningRatePercentage > 0 && bullet.burningRate > 0 && !monsterData.isBurning) {
            if (Math.random() < bullet.burningRatePercentage / 100) {
                monsterData.burnDamagePerTick = bullet.burningRate
                monsterData.burnTicksRemaining = 3  // 燃烧 3 秒
                monsterData.isBurning = true
                // 视觉：红色闪烁
                whiteOverlayAnimator.restart()
            }
        }

        //可能的爆炸特效
        if (SettingsData.explosionEffect && PlayerData.explosiveDamage > 0) {
            var expRadius = 20 + (PlayerData.explosionRange / 100) * 30
            ParticlePool.spawnExplosion(bullet.x, bullet.y, expRadius * scaleFactor, gameArea, SettingsData.explosionEffect)
            // 爆炸伤害：对范围内所有其他怪物造成 explosiveDamage 点伤害
            var ownerChildren = monster.owner.children
            for (var ei = 0; ei < ownerChildren.length; ei++) {
                var otherMonster = ownerChildren[ei]
                if (otherMonster.objectName === "Monster" && otherMonster !== monster && !otherMonster.isDead && !otherMonster.isDestroy) {
                    var dist = Tool.getDistance(Qt.point(bullet.x, bullet.y), Qt.point(otherMonster.x + otherMonster.width/2, otherMonster.y + otherMonster.height/2))
                    if (dist < expRadius * scaleFactor) {
                        otherMonster.monsterData.hp -= PlayerData.explosiveDamage
                    }
                }
            }
        }

        //可能的生命窃取
        if(Math.random()<PlayerData.lifeSteal/100){
            PlayerData.curHp++
            Tool.createText(owner,"+1",24*scaleFactor,"lime",target.x,target.y-24*scaleFactor)
        }
    }

    function makeBlood(x,y,dx,dy, width, parent){
        ParticlePool.spawn(x, y, dx, dy, width, parent, SettingsData.visualEffects)
    }
}

