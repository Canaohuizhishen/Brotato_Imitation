import QtQuick 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../logic/utils/tool.js" as Tool
import "../monsters"
import "../components"
import "../data/cores"

Item{
    id: weapons
    property Player owner
    property Monsters target
    property var bulletsParent: parent
    property var componentCache: null
    property double scaleFactor: 1.0
    property bool active: true
    property bool paused: false
    anchors.centerIn: owner
    anchors.horizontalCenterOffset: 10*scaleFactor
    width: 110*scaleFactor
    height: width
    z: 3
    property bool isFaceRight: true
    // 手动瞄准目标点（全局坐标，由 GameArea 设置）
    property var manualAimPoint: null

    Component.onCompleted: {
        upDataWeapons()
    }

    onScaleFactorChanged: {
        relocation()
    }

    onActiveChanged: {
        if(active==false){
            owner.isFaceRight ? faceRight() : faceLeft()
        }
    }

    Connections {
        target: PlayerData
        function onWeaponsListChanged() {
            weapons.upDataWeapons()
        }
    }

    Rectangle{
        visible: false
        anchors.fill: weapons
        color: "black"
        opacity: 0.5
    }

    Rectangle{
        visible: false
        x: weapons.getPosition(1,1,weapons.isFaceRight).x
        y: weapons.getPosition(1,1,weapons.isFaceRight).y
        width: 5
        height: 5
        color: "red"
        z: 100
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    function updateGoals() {
        if (!active || paused) return
        
        var useManualAim = SettingsData.manualAim && manualAimPoint !== null

        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName !== "Weapon") continue
            
            if (useManualAim) {
                // 手动瞄准：鼠标光标位置（已由 GameArea 转换到游戏区坐标）
                child.targetPoint = Qt.point(
                    manualAimPoint.x - weapons.x,
                    manualAimPoint.y - weapons.y
                )
            } else {
                // 自动瞄准
                var weapon = child.core
                var monster = target.getClosestMonster(child.x + weapons.x, child.y + weapons.y, weapon.range * scaleFactor)
                if (monster === null) {
                    child.targetPoint = null
                    if (!child.inFire) {
                        owner.isFaceRight ? child.faceRight() : child.faceLeft()
                    }
                } else {
                    child.targetPoint = Qt.point(monster.x + monster.width / 2 - weapons.x, monster.y + monster.height / 2 - weapons.y)
                }
            }
        }
    }

    function init(){
        active=true
        paused=false
    }

    function faceLeft(){
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName==="Weapon"&&isFaceRight){
                if(child.targetPoint===null){
                    child.faceLeft()
                    child.rotationReset()
                }
            }
        }
        isFaceRight=false
        anchors.horizontalCenterOffset=-10*scaleFactor
        reSetZ()
    }

    function faceRight(){
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName==="Weapon"&&!isFaceRight){
                if(child.targetPoint===null){
                    child.faceRight()
                    child.rotationReset()
                }
            }
        }
        isFaceRight=true
        anchors.horizontalCenterOffset=10*scaleFactor
        reSetZ()
    }

    function clear(){
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName==="Weapon"){//console.log(8);console.log(weapons.children.length)
                child.destroy();//console.log(9);console.log(weapons.children.length)//可以发现，销毁后孩子列表的长度没有发生变化，说明destroy()是异步方法
                child.isDestroy=true
            }
        }
    }

    function upDataWeapons(){
        clear()
        for(var i=0;i<PlayerData.weapons.count;i++){
            var weapon=PlayerData.weapons.get(i)
            addWeapon(weapon.weaponName,weapon.grade)
        }
    }

    function addWeapon(weaponName,grade=1){
        var weaponData = weaponCore.getWeapon(weaponName,grade)
        if (!componentCache || !weaponData) return
        // 数据中 source 是裸文件名（如 "SMG.qml"），需拼接目录前缀
        // 路径相对于 ComponentCache 的位置（logic/），所以用 ../weapons/
        var weapon = componentCache.createFromSource("../weapons/" + weaponData.source, weapons, {})
        if (weapon) {
            weapon.grade=grade
            weapon.componentCache=weapons.componentCache
            weapon.bulletsParent=weapons.bulletsParent
            weapon.scaleFactor=Qt.binding(function() { return weapons.scaleFactor; })
            weapon.active=Qt.binding(function() { return weapons.active; })
            weapon.paused=Qt.binding(function() { return weapons.paused; })
            relocation()
        } else {
            console.log("Error loading component:", weaponData.source);
        }
    }

    function getPosition(n1,n2){
        var point
        switch(n1){
        case 1: {
            point=Qt.point(43, 76)
        }break
        case 2: {
            switch(n2){
            case 1:point=Qt.point(72, 67);break
            case 2:point=Qt.point(12, 67);break
            default: point=Qt.point(0,0)
            }
        }break
        case 3: {
            switch(n2){
            case 1:point=getPosition(2,1);break
            case 2:point=getPosition(2,2);break
            case 3:point=Qt.point(42, 25);break
            default: point=Qt.point(0,0)
            }
        }break
        case 4: {
            switch(n2){
            case 1:point=Qt.point(63, 77);break
            case 2:point=Qt.point(20, 77);break
            case 3:point=Qt.point(63, 30);break
            case 4:point=Qt.point(20, 30);break
            default: point=Qt.point(0,0)
            }
        }break
        case 5: {
            switch(n2){
            case 1:point=Qt.point(63, 77);break
            case 2:point=Qt.point(20, 77);break
            case 3:point=Qt.point(78, 37);break
            case 4:point=Qt.point(5, 37);break
            case 5:point=Qt.point(42, 10);break
            default: point=Qt.point(0,0)
            }
        }break
        case 6: {
            switch(n2){
            case 1:point=Qt.point(63, 80);break
            case 2:point=Qt.point(20, 80);break
            case 3:point=Qt.point(78, 50);break
            case 4:point=Qt.point(5, 50);break
            case 5:point=Qt.point(63, 20);break
            case 6:point=Qt.point(20, 20);break
            default: point=Qt.point(0,0)
            }
        }break
        default: point=Qt.point(0,0)
        }
        return Qt.point(point.x,point.y)
    }

    function relocation(){
        var n=1
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName==="Weapon" && !child.isDestroy){
                var weapon = weaponCore.getWeapon(child.weaponName)
                var targetPoint=weapons.getPosition(PlayerData.weapons.count,n)
                var originX,originY
                originX=(targetPoint.x-weapon.handX+weapon.xOffset)*scaleFactor
                originY=(targetPoint.y-weapon.handY+weapon.yOffset)*scaleFactor
                child.originPos=Qt.point(originX,originY)
                child.x=originX
                child.y=originY
                n++
            }
        }
    }

    function reSetZ(){
        var n=1
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName==="Weapon" && !child.isDestroy){
                if(isFaceRight){
                    if(n%2==0)child.z=1
                    else child.z=0
                }else{
                    if(n%2==0)child.z=0
                    else child.z=1
                }
                n++
            }
        }
    }
}

