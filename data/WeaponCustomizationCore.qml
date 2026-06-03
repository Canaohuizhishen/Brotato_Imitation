import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property int weaponNumber: core.children.length
    property double grade_one_weapon_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_weapon_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_weapon_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_weapon_spawn_probability: 0.065*(1+PlayerData.luck/125)
    property var smg: submachineGun
    property var spear: spear

    function getWeaponRandomly(n){
        var result=[]//存储所有选中的武器选项
        var array=[]//存储所有选中的武器选项的索引，便于查重
        var random//存储随机数
        var probability
        var grade
        var index
        for(var i=0;i<n;i++){
            //获得随机等级
            random=Math.random()*(grade_one_weapon_spawn_probability+grade_two_weapon_spawn_probability+grade_three_weapon_spawn_probability+grade_four_weapon_spawn_probability)
            probability=grade_four_weapon_spawn_probability
            if(random<probability){
                grade=4
            }else{
                probability+=grade_three_weapon_spawn_probability
                if(random<probability){
                    grade=3
                }else{
                    probability+=grade_two_weapon_spawn_probability
                    if(random<probability){
                        grade=2
                    }else grade=1
                }
            }

            //获得随机索引
            index=Math.floor(Math.random()*weaponNumber)

            //查重
            var isSame=false
            // for(var i=0;i<array.length;i++){
            //     if(array[i]==index){
            //         isSame=true
            //         break
            //     }
            // }

            //存储结果
            if(!isSame){
                array.push(index)
                core.children[index].grade=grade
                result.push(core.children[index])
            }else i--
        }

        return result
    }

    function getWeapon(weaponName,grade=1){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName===weaponName || core.children[i].weaponName===weaponName) {
                core.children[i].grade = grade
                return core.children[i]
            }
        }
        console.error("WeaponCustomizationCore.getWeapon: '" + weaponName + "' not found")
        return null
    }

    Item{
        id: spear
        objectName: "spear"
        property string weaponName: "长矛"
        property int grade: 1
        property int baseDamage: 15
        property double meleeDamageMultiplier: 1
        property int damage: Math.max((baseDamage+PlayerData.meleeDamage*meleeDamageMultiplier)*(1+PlayerData.damage/100),1)
        property int critical:  3+PlayerData.critChance
        readonly property double criticalDamageRate: 2
        property double baseCooldown: 1.52
        property double cooldown: baseCooldown/(1+PlayerData.attackSpeed/100)
        property double attackTime: Math.min(0.75,cooldown)
        property int baseRange: 350
        property int range: baseRange+PlayerData.range
        property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)

        readonly property string source: "Spear.qml"
        readonly property double aspectRatio: 0.1634
        readonly property double scaleRatio: 2.5

        readonly property double xOffset: -22 //图片中的手相对于武器定位点的水平偏移,将图片位置调整至weapons的水平中心
        readonly property double yOffset: -5
        readonly property double handX: 9*scaleRatio //图片中的手对于左上角的水平偏移
        readonly property double handY: 3*scaleRatio //图片中的手对于左上角的垂直偏移
        readonly property string type: "原始"
        readonly property string talentText: `
        <font color='#ffffc0'>伤害 : </font><font color='white'>`+damage+`(+100%近战伤害)</font><br>
        <font color='#ffffc0'>暴击 : </font><font color='white'>x`+criticalDamageRate+`(`+critical+`%概率)</font><br>
        <font color='#ffffc0'>冷却 : </font><font color='white'>`+cooldown.toFixed(2)+`</font><br>
        <font color='#ffffc0'>范围 : </font><font color='white'>`+range+`(近战)</font><br>
        `
        onGradeChanged: {
            switch(grade){
            case 1:{
                baseDamage=15
                baseCooldown=1.52
                baseRange=350
                basePrice=20
            }break
            case 2:{
                baseDamage=25
                baseCooldown=1.4
                baseRange=375
                basePrice=39
            }break
            case 3:{
                baseDamage=40
                baseCooldown=1.28
                baseRange=400
                basePrice=74
            }break
            case 4:{
                baseDamage=60
                baseCooldown=1.24
                baseRange=500
                basePrice=149
            }break
            default: console.log("无效的等级:",weaponName,":",grade)
            }
        }
    }

    Item{
        id: submachineGun
        objectName: "smg"
        property string weaponName: "冲锋枪"
        property int grade: 1
        property int baseDamage: 3
        property double rangedDamageMultiplier: 0.5
        property int damage: Math.max((baseDamage+PlayerData.rangedDamage*rangedDamageMultiplier)*(1+PlayerData.damage/100),1)
        property int critical: 1+PlayerData.critChance
        readonly property double criticalDamageRate: 1.5
        property double cooldown: 0.17/(1+PlayerData.attackSpeed/100)
        property double attackTime: Math.min(0.1,cooldown)
        property int baseRange: 400
        property int range: baseRange+PlayerData.range
        property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)

        readonly property string source: "SMG.qml"
        readonly property double aspectRatio: 0.683
        readonly property double scaleRatio: 1
        readonly property double xOffset: -2
        readonly property double yOffset: 0
        readonly property double handX: 9*scaleRatio
        readonly property double handY: 16*scaleRatio
        readonly property string type: "枪械"
        readonly property string talentText: `
        <font color='#ffffc0'>伤害 : </font><font color='white'>`+damage+`(+50%远程伤害)</font><br>
        <font color='#ffffc0'>暴击 : </font><font color='white'>x`+criticalDamageRate+`(`+critical+`%概率)</font><br>
        <font color='#ffffc0'>冷却 : </font><font color='white'>`+cooldown.toFixed(2)+`</font><br>
        <font color='#ffffc0'>范围 : </font><font color='white'>`+range+`(远战)</font><br>
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
