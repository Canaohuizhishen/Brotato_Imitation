import QtQuick 2.15
import singleton.MonstersData
import "../logic/utils/tool.js" as Tool
import "../data/cores"
import "../components"
import "../bullets"
import "../logic/SpatialGrid.js" as SpatialGrid

Item {
    id: monsters
    anchors.fill: parent
    objectName: "Monsters"
    z: 3
    property Player target: null
    property Forks forkParent: parent
    property Drops dropsParent: parent
    property double scaleFactor: 1.0
    property bool active: true
    property bool paused: false

    property int maxNum: 100
    property var gameLoop: null
    property var componentCache: null
    // 暴露内部 bullets 组件，供 GameArea 注册怪物子弹碰撞检测
    property alias bullets: bullets

    function init(){
        active=true
        paused=false
        clear()
    }

    Component.onCompleted: {
        // var monster1=spawnMonster(monsters,"babyAlien")
        // monster1.x=800
        // monster1.y=800
        // monster1.target=target
        // monster1.active=false
        // var monster3=spawnMonster(monsters,"babyAlien")
        // monster3.x=900
        // monster3.y=800
        // monster3.target=target
        // monster3.active=false
        // var monster2=spawnMonster(monsters,"babyAlien")
        // monster2.x=1000
        // monster2.y=800
        // monster2.target=monster1

        // var monster4=spawnMonster(monsters,"babyAlien")
        // monster4.x=800
        // monster4.y=1000
        // monster4.target=monster1
        // var monster5=spawnMonster(monsters,"babyAlien")
        // monster5.x=800
        // monster5.y=900
        // monster5.target=target
        // monster5.active=false

        // var monster6=spawnMonster(monsters,"babyAlien")
        // monster6.x=930
        // monster6.y=930
        // monster6.target=monster1
        // var monster7=spawnMonster(monsters,"babyAlien")
        // monster7.x=850
        // monster7.y=850
        // monster7.target=target
        // monster7.active=false

        //monsters.spawnMonsters(100,"babyAlien")
        //monsters.spawnMonsters(1,"charger")
        //monsters.spawnMonsters(10,"chaser")
    }

    onPausedChanged: {
        if(paused==true){
            sleepTimer.pause()
        }else{
            sleepTimer.resume()
        }
    }

    //用来管理所有怪物生成的子弹
    Bullets{
        id: bullets
        target: monsters.target
        active: true
        paused: monsters.paused
        scaleFactor: monsters.scaleFactor
        z: 3000
    }

    //用来实现从fork生成到怪物生成之间的时间间隔
    TimerCanPause {
        id: sleepTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            if(monsters.active)monsters.forksToMonsters()
        }
    }

    function createWaveMonsters() {
        if (!active || paused) return
        if (children.length < maxNum) {
            for (var i = 0; i < MonstersData.children.length; i++) {
                var monsterData = MonstersData.children[i]
                var n = Math.floor(monsterData.initCount * monsterData.countRation)
                var increaseFactor = 1 + monsterData.countIcreaseRation
                if (n === 0) {
                    monsterData.countRation *= increaseFactor
                } else if (n + monsterData.curNumber > monsterData.maxCurNumber) {
                    spawnMonsters(monsterData.maxCurNumber - monsterData.curNumber, monsterData.objectName)
                    if (increaseFactor !== 0) monsterData.countRation /= increaseFactor
                } else {
                    spawnMonsters(n, monsterData.objectName)
                    monsterData.countRation *= increaseFactor
                }
            }
        }
    }

    // 将所有活着的怪物重新插入 SpatialGrid（每次碰撞检测前调用）
    function updateSpatialGrid() {
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "Monster" && !child.isDead && !child.isDestroy) {
                SpatialGrid.insert(child, child.x, child.y)
            }
        }
    }

    function checkMonsterCollisions() {
        if (!active || paused) return
        for (var i = 0; i < children.length; i++) {
            var m = children[i]
            if (m.objectName !== "Monster" || m.isDead || m.isDestroy) continue
            // 用 SpatialGrid 快速找到附近怪物候选，再套用原版方向+距离+同种判定
            var checkDistance = m.width / 2
            // 查询范围覆盖 checkDistance + 一个网格边距，确保不漏
            var margin = Math.max(checkDistance + m.width, 200)
            var candidates = SpatialGrid.query(m.x - margin, m.y - margin, m.width + margin * 2, m.height + margin * 2)
            var blocked = false
            for (var j = 0; j < candidates.length; j++) {
                var other = candidates[j]
                if (other === m || other.isDead || other.isDestroy) continue
                // 原版逻辑：仅同种怪物互相阻挡
                if (other.monsterName !== m.monsterName) continue
                // 原版逻辑：只检查前方的怪物
                var dx = m.x - other.x
                var dy = (m.y + m.height) - (other.y + other.height)
                var inFront = false
                if (m.isFaceRight) {
                    if (dx <= 0) {
                        if (m.isFaceUp) {
                            if (dy >= 0) inFront = true
                        } else {
                            if (dy <= 0) inFront = true
                        }
                    }
                } else {
                    if (dx >= 0) {
                        if (m.isFaceUp) {
                            if (dy >= 0) inFront = true
                        } else {
                            if (dy <= 0) inFront = true
                        }
                    }
                }
                if (inFront && Tool.getDistance(Qt.point(m.x, m.y), Qt.point(other.x, other.y)) < checkDistance) {
                    blocked = true
                    break
                }
            }
            m.isFrontHaveOtherMonster = blocked
        }
    }

    function updateAllMonsterMovements(deltaTime) {
        if (!active || paused) return
        var deadList = []
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName === "Monster") {
                if (child.isDestroy) {
                    deadList.push(child)
                } else if (!child.isDead) {
                    child.updateMovement(deltaTime)
                }
            }
        }
        // 清理已销毁对象，防止 children 数组无限膨胀导致帧率下降
        for (var j = 0; j < deadList.length; j++) {
            deadList[j].destroy()
        }
    }

    //返回target的前进方向checkDistance处有其他怪物挡路的布尔值
    function isFrontHaveOtherMonster(target,checkDistance){
        for (var i = 0; i < monsters.children.length; i++) {
            var other = monsters.children[i];
            if (other.objectName === "Monster") {
                if(other===target || other.monsterName!==target.monsterName)continue
                var dx=target.x-other.x
                var dy=(target.y+target.height)-(other.y+other.height)
                if(target.isFaceRight){
                    if(dx<=0){
                        if(target.isFaceUp){
                            if(dy>=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }else{
                            if(dy<=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }
                    }
                }else{
                    if(dx>=0){
                        if(target.isFaceUp){
                            if(dy>=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }else{
                            if(dy<=0){
                                if(Tool.getDistance(Qt.point(target.x,target.y),Qt.point(other.x,other.y))<checkDistance)return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    //返回当前被target击中的怪物
    function getCollidingChild(target){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster" && !child.isDestroy) {
                if(child.isDead===true)continue
                if(Math.abs(target.x+target.width/2-child.x-child.width/2)<(target.width+child.width)/2 && Math.abs(target.y+target.height/2-child.y-child.height/2)<(target.height+child.height)/2){
                    return child
                }
            }
        }
        return null
    }

    //返回range范围内距离坐标(x,y)最近的怪物（使用 SpatialGrid 优化）
    function getClosestMonster(x,y,range){
        if(monsters.children.length===0)return null
        var m=null
        var minDist = Infinity
        // 用 SpatialGrid 查询 (x-range, y-range, range*2, range*2) 范围内的候选怪物
        var candidates = SpatialGrid.query(x - range, y - range, range * 2, range * 2)
        for (var j = 0; j < candidates.length; j++) {
            var child = candidates[j]
            if (!child || child.isDead || child.isDestroy) continue
            var dist = Tool.getDistance(Qt.point(child.x, child.y), Qt.point(x, y))
            if (dist < range && dist < minDist) {
                m = child
                minDist = dist
            }
        }
        return m
    }

    //令所有怪物消失
    function disappear(){
        var child
        for (var i = 0; i < monsters.children.length; i++) {
            child = monsters.children[i];
            if (child.objectName === "Monster" && !child.isDestroy) {
                unregisterMonsterCallbacks(child)
                child.disappear()
            }
        }
        forkParent.clear()
        bullets.clear()
    }

    function clear(){
        for (var i = 0; i < monsters.children.length; i++) {
            var child = monsters.children[i];
            if (child.objectName === "Monster") {
                unregisterMonsterCallbacks(child)
                child.destroy()
                child.isDestroy=true
            }
        }
        forkParent.clear()
    }

    //生成n个怪物名为monsterName的怪物
    function spawnMonsters(n,monsterName) {
        for(var i=0;i<n;i++){
            var margin = 50
            var retries = 0
            var maxRetries = 50
            var x, y
            while (retries < maxRetries) {
                x = Math.random() * (monsters.parent.width - margin*2) + margin
                y = Math.random() * (monsters.parent.height - margin*2) + margin
                if (Tool.getDistance(Qt.point(target.x,target.y), Qt.point(x,y)) >= 200) break
                retries++
            }
            if (retries >= maxRetries) continue
            var fork = forkParent.spawnFork()
            fork.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
            fork.x = x
            fork.y = y
            fork.rotation = Math.random() * 360
            fork.targetMonsterName=monsterName
            fork.paused=Qt.binding(function(){return monsters.paused})
        }
        sleepTimer.start()
    }

    //将场上所有的fork转换成对应的怪物
    function forksToMonsters() {
        for (var i = 0; i < monsters.forkParent.children.length; i++) {
            var child = monsters.forkParent.children[i]
            if (child.objectName === "Fork" && !child.isDestroy) {
                var monster = spawnMonster(monsters,child.targetMonsterName)
                monster.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
                monster.x = child.x+child.width/2-monster.width/2
                monster.y = child.y+child.height/2-monster.height/2
                monster.owner=monsters
                monster.target=monsters.target
                monster.bulletsParent=bullets
                monster.active=Qt.binding(function(){return monsters.active})
                monster.paused=Qt.binding(function(){return monsters.paused})
                if((monster.x-monster.target.x)>0)monster.faceLeft()
                else monster.faceRight()
                registerMonsterCallbacks(monster)
                // 注册到空间网格
                SpatialGrid.insert(monster, monster.x, monster.y)
                // Scavenger 需要生成后立即获得随机方向，不等 per3000ms
                if (monster.monsterName === "scavenger") {
                    monster.setGoalRandomly()
                }
                child.destroy()
            }
        }
    }

    //在parent中动态生成一个怪物名为monsterName的怪物
    function spawnMonster(parent,monsterName) {
        var source=MonstersData.getMonster(monsterName).source
        // 数据中 source 是裸文件名（如 "Charger.qml"），需拼接目录前缀
        // 路径相对于 ComponentCache 的位置（logic/），所以用 ../monsters/
        var monster = componentCache
                ? componentCache.createFromSource("../monsters/" + source, parent, {})
                : null
        if (monster) registerMonsterCallbacks(monster)
        return monster
    }

    // 根据怪物类型注册对应的 GameLoop 回调
    function registerMonsterCallbacks(monster) {
        if (!gameLoop || !monster) return
        switch (monster.monsterName) {
        case "charger":
            gameLoop.registerPerFrame(monster, monster.checkChargeCollision)
            gameLoop.registerPer200ms(monster, monster.checkChargeRange)
            break
        case "sprayer":
            gameLoop.registerPer200ms(monster, monster.checkSprayBehavior)
            break
        case "prayer":
            gameLoop.registerPer1000ms(monster, monster.updatePrayerExistTime)
            gameLoop.registerPer3000ms(monster, monster.triggerPrayerAttack)
            break
        case "scavenger":
            gameLoop.registerPer3000ms(monster, monster.setGoalRandomly)
            break
        case "summoner":
            gameLoop.registerPer200ms(monster, monster.checkSummonerBehavior)
            break
        case "pursuer":
            gameLoop.registerPer200ms(monster, monster.updateAcceleration)
            break
        }
    }

    function unregisterMonsterCallbacks(monster) {
        if (!gameLoop || !monster) return
        switch (monster.monsterName) {
        case "charger":
            gameLoop.removePerFrame(monster, monster.checkChargeCollision)
            gameLoop.removePer200ms(monster, monster.checkChargeRange)
            break
        case "sprayer":
            gameLoop.removePer200ms(monster, monster.checkSprayBehavior)
            break
        case "prayer":
            gameLoop.removePer1000ms(monster, monster.updatePrayerExistTime)
            gameLoop.removePer3000ms(monster, monster.triggerPrayerAttack)
            break
        case "scavenger":
            gameLoop.removePer3000ms(monster, monster.setGoalRandomly)
            break
        case "summoner":
            gameLoop.removePer200ms(monster, monster.checkSummonerBehavior)
            break
        case "pursuer":
            gameLoop.removePer200ms(monster, monster.updateAcceleration)
            break
        }
    }

    //在dropsParent中怪物monster的当前位置附近生成其死亡时应掉落数量个材料
    function dropMaterial(monster){
        if(monster.isDestroy)return
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in dropMaterial")
            return
        }
        var mapW = monsters.parent.width
        var mapH = monsters.parent.height
        for(var i=0;i<monster.monsterData.materialDrops;i++){
            var material=componentCache.createMaterial(dropsParent, {})
            if (!material) continue
            material.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
            if(i==0){
                material.x=monster.x+monster.width/2-material.width/2
                material.y=monster.y+monster.height-material.height
            }else{
                material.x=monster.x+monster.width/2-material.width/2+(Math.random()-0.5)*monster.width*2
                material.y=monster.y+monster.height-material.height+(Math.random()-0.5)*monster.width*2
            }
            // 钳制到地图内，防止掉到黑色区域
            material.x = Math.max(0, Math.min(mapW - material.width, material.x))
            material.y = Math.max(0, Math.min(mapH - material.height, material.y))
        }
    }

    //在dropsParent中怪物monster的当前位置附近生成一个果实
    function dropFruit(monster){
        if(monster.isDestroy)return
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in dropFruit")
            return
        }
        var fruit=componentCache.createFruit(dropsParent, {})
        if (!fruit) return
        fruit.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
        fruit.x=monster.x+monster.width/2-fruit.width/2+(Math.random()-0.5)*monster.width*1.6
        fruit.y=monster.y+monster.height-fruit.height+(Math.random()-0.5)*monster.width*1.6
        fruit.x = Math.max(0, Math.min(monsters.parent.width - fruit.width, fruit.x))
        fruit.y = Math.max(0, Math.min(monsters.parent.height - fruit.height, fruit.y))
    }

    //在dropsParent中怪物monster的当前位置附近生成一个宝箱
    function dropChest(monster){
        if(monster.isDestroy)return
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in dropChest")
            return
        }
        var chest=componentCache.createChest(dropsParent, {})
        if (!chest) return
        chest.scaleFactor=Qt.binding(function() { return monsters.scaleFactor; })
        chest.x=monster.x+monster.width/2-chest.width/2+(Math.random()-0.5)*monster.width*1.6
        chest.y=monster.y+monster.height-chest.height+(Math.random()-0.5)*monster.width*1.6
        chest.x = Math.max(0, Math.min(monsters.parent.width - chest.width, chest.x))
        chest.y = Math.max(0, Math.min(monsters.parent.height - chest.height, chest.y))
    }

    //在bulletsParent中的点（x,y）位置上生成宽width高height伤害为damage射程为range攻击角度为shootAngle颜色为color的飞行子弹
    function spawnBullet(x,y,width,height,damage,range,shootAngle,color){
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in spawnBullet")
            return
        }
        var bullet = componentCache.createRoundMovingBullet(bullets, {})
        if (!bullet) return
        bullet.scaleFactor=Qt.binding(function(){return monsters.scaleFactor})
        bullet.paused=Qt.binding(function(){return monsters.paused})
        bullet.width=width
        bullet.height=height
        bullet.x=x - bullet.width / 2
        bullet.y=y - bullet.height / 2
        bullet.originPoint=Qt.point(x - bullet.width / 2,y - bullet.height / 2)
        bullet.color=color
        bullet.damage=damage
        bullet.fireRate=400
        bullet.fireRange=range
        bullet.shootAngle=shootAngle
    }

    //在bulletsParent中的点（centerX,centerY）方圆spawnR内随机生成n个宽width高height伤害为damage颜色为color存在时间为existTime的静止子弹
    function spawnRandomStaticBullets(n,centerX,centerY,width,height,damage,color,existTime,spawnR){
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in spawnRandomStaticBullets")
            return
        }
        for(var i=0;i<n;i++){
            var bullet = componentCache.createRoundStaticBullet(bullets, {})
            if (!bullet) {
                console.warn("Monsters: failed to create round static bullet")
                continue
            }
            var angle=360*Math.random()
            var distance=spawnR*Math.random()
            var x=centerX+distance*Math.cos(angle* (Math.PI/180))
            var y=centerY+distance*Math.sin(angle* (Math.PI/180))
            bullet.scaleFactor=Qt.binding(function(){return monsters.scaleFactor})
            bullet.paused=Qt.binding(function(){return monsters.paused})
            bullet.width=width
            bullet.height=height
            bullet.x=x - bullet.width / 2
            bullet.y=y - bullet.height / 2
            bullet.color=color
            bullet.damage=damage
            bullet.existTime=existTime
        }
    }

    //以bulletsParent中的点（centerX,centerY）为圆心spawnR为半径生成n个宽width高height伤害为damage颜色为color存在时间为existTime的静止子弹均匀分布在圆周
    function spawnCircularStaticBullets(n,centerX,centerY,width,height,damage,color,existTime,spawnR){
        if (!componentCache) {
            console.warn("Monsters: componentCache not available in spawnCircularStaticBullets")
            return
        }
        for(var i=0;i<n;i++){
            var bullet = componentCache.createRoundStaticBullet(bullets, {})
            if (!bullet) {
                console.warn("Monsters: failed to create round static bullet")
                continue
            }
            var angle=360/(n+1)*i
            var x=centerX+spawnR*Math.cos(angle* (Math.PI/180))
            var y=centerY+spawnR*Math.sin(angle* (Math.PI/180))
            bullet.scaleFactor=Qt.binding(function(){return monsters.scaleFactor})
            bullet.paused=Qt.binding(function(){return monsters.paused})
            bullet.width=width
            bullet.height=height
            bullet.x=x - bullet.width / 2
            bullet.y=y - bullet.height / 2
            bullet.color=color
            bullet.damage=damage
            bullet.existTime=existTime
        }
    }
}
