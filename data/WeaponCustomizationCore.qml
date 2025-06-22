import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property var smg: submachineGun

    function getWeapon(weaponName,grade=1){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==weaponName)break
        }
        core.children[i].grade=grade
        return core.children[i]
    }

    Item{
        id: submachineGun
        objectName: "smg"
        property string weaponName: "冲锋枪"
        property int grade: 1
        property int baseDamage: 3
        property double rangedDamageMultiplier: 0.5
        property int damage: (baseDamage+PlayerData.rangedDamage*rangedDamageMultiplier)*(1+PlayerData.damage/100)
        property double critical:  1.5* PlayerData.critChance/100
        property double cooldown: 0.17/(1+PlayerData.attackSpeed/100)
        property int range: 400+PlayerData.range
        property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)

        readonly property string source: "SMG.qml"
        readonly property double aspectRatio: 0.683
        readonly property double iconWidthOffset: 9
        readonly property double iconHeightOffset: 16
        readonly property string type: "枪械"
        readonly property string talentText: `
        <font color='#dad2a4'>伤害 : </font><font color='white'>`+damage+`(+50%远程伤害)</font><br>
        <font color='#dad2a4'>暴击 : </font><font color='white'>x1.5(`+critical+`%概率)</font><br>
        <font color='#dad2a4'>冷却 : </font><font color='white'>`+cooldown+`</font><br>
        <font color='#dad2a4'>范围 : </font><font color='white'>`+range+`(远战)</font><br>
        `
        onGradeChanged: {
            switch(grade){
            case 1:{
                baseDamage=3
                rangedDamageMultiplier=0.5
                basePrice=20
            }break
            case 2:{
                baseDamage=4
                rangedDamageMultiplier=0.6
                basePrice=39
            }break
            case 3:{
                baseDamage=5
                rangedDamageMultiplier=0.7
                basePrice=74
            }break
            case 4:{
                baseDamage=8
                rangedDamageMultiplier=0.8
                basePrice=149
            }break
            default: console.log("无效的等级:",weaponName,":",grade)
            }
        }
    }
}
