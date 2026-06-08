import QtQuick 2.15
import singleton.PlayerData

RangedWeapon {
    id: iceCone
    weaponName: "ice_cone"
    property var componentCache: null
    aimSpeedMultiplier: 2.0

    // 命中率从 DataLoader 读取（core.accuracy 数组）
    // 贯通属性从 DataLoader 读取（core.inherentPenetrate / inherentPenetrateMultiplier）

    onPausedChanged: {
        if(paused==true){
            fireAnimation.pause()
        }else{
            fireAnimation.resume()
        }
    }

    SequentialAnimation {
        id: fireAnimation
        loops: 1
        running: false
        property double duration: iceCone.core.attackTime*1000

        ParallelAnimation {
            id: backAnimation
            property double duration: fireAnimation.duration/2.5
            property double angle
            NumberAnimation { target: iceCone; property: "x"; from: iceCone.originPos.x; to: from-Math.cos(backAnimation.angle* (Math.PI/180))*iceCone.width/5; duration: 0; easing.type: Easing.OutCirc }
            NumberAnimation { target: iceCone; property: "x"; from: iceCone.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*iceCone.width/5; to: iceCone.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*iceCone.width/4; duration: backAnimation.duration; easing.type: Easing.OutCirc }
            NumberAnimation { target: iceCone; property: "y"; from: iceCone.originPos.y; to: from+Math.sin(backAnimation.angle* (Math.PI/180))*iceCone.width/4;  duration: backAnimation.duration; easing.type: Easing.OutCirc }
        }

        ParallelAnimation {
            id: recoverAnimation
            property double duration: fireAnimation.duration/2.5*1.5
            NumberAnimation { target: iceCone; property: "x"; from: iceCone.originPos.x-Math.cos(backAnimation.angle* (Math.PI/180))*iceCone.width/4; to: iceCone.originPos.x; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
            NumberAnimation { target: iceCone; property: "y"; from: iceCone.originPos.y+Math.sin(backAnimation.angle* (Math.PI/180))*iceCone.width/4; to: iceCone.originPos.y; duration: recoverAnimation.duration; easing.type: Easing.InOutQuad }
        }
        onStopped: {
            iceCone.x=iceCone.originPos.x
            iceCone.y=iceCone.originPos.y
            inFire = false
        }
        function pause(){
            if(running)paused=true
        }
    }

    function fire(){
        if (inFire) return  // 防止同一帧内 Timer 双重触发
        inFire = true
        attackSound.play()
        if(isFaceRight){
            backAnimation.angle=-_targetAngle
        }else backAnimation.angle=180-_targetAngle
        fireAnimation.start()

        // 命中率判定：从 DataLoader 读取，未命中时偏移子弹角度
        var accArr = core.accuracy
        var currentAccuracy = (accArr && accArr.length > 0) ? accArr[Math.min(grade - 1, accArr.length - 1)] : 1.0
        var finalAngle = backAnimation.angle
        if (Math.random() > currentAccuracy) {
            // 偏移 ±15 度
            finalAngle += (Math.random() - 0.5) * 30
        }

        // 子弹从武器中心生成（不从枪口延伸），确保贴脸怪物也能命中
        var x=iceCone.parent.x+iceCone.x+iceCone.width/2
        var y=iceCone.parent.y+iceCone.y+iceCone.height/4
        if (!iceCone.componentCache) return
        var bullet = iceCone.componentCache.createSpriteMovingBullet(bulletsParent, {})
        if (bullet) {
            bullet.spriteSource = "qrc:/images/ice_cone_bullet_" + (iceCone.isFaceRight ? "right" : "left") + ".png"
            bullet.spriteDefaultAngle = iceCone.isFaceRight ? 0 : 180
            bullet.scaleFactor=Qt.binding(function(){return iceCone.scaleFactor})
            bullet.paused=Qt.binding(function(){return iceCone.paused})
            bullet.critical=core.critical
            bullet.criticalDamageRate=core.criticalDamageRate
            bullet.width=iceCone.width*1.2
            bullet.height=bullet.width*0.28
            bullet.x=x - bullet.width / 2
            bullet.y=y - bullet.height / 2
            bullet.originPoint=Qt.point(x - bullet.width / 2,y - bullet.height / 2)
            bullet.damage=core.damage
            bullet.fireRate=2000
            bullet.fireRange=core.range
            bullet.shootAngle=finalAngle
            // 冰锥自带贯通（从 DataLoader 读取）
            bullet.penetrateCount = core.inherentPenetrate || 0
            bullet.penetrateDamageMultiplier = core.inherentPenetrateMultiplier || 1.0
            // 其他属性从 PlayerData 继承
            bullet.reboundCount = PlayerData.rebound
            bullet.penetrateCount += PlayerData.penetrate  // 与玩家属性叠加
            bullet.penetrateDamageMultiplier = PlayerData.penetratingDamage > 0 ? Math.max(0.1, 1 - PlayerData.penetratingDamage / 100) : (core.inherentPenetrateMultiplier || 1.0)
            bullet.baseDamage = core.damage
            bullet.burningRatePercentage = PlayerData.burningRatePercentage
            bullet.burningRate = PlayerData.burningRate
        } else {
            console.error("Error loading component: SpriteMovingBullet.qml")
        }
    }
}
