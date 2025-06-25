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
        // console.log(weaponName,grade)
        let foundedWeapon = null
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName===weaponName || core.children[i].weaponName===weaponName) {
                foundedWeapon =  core.children[i]
                break
            }
        }
        if(foundedWeapon) {
            foundedWeapon.grade = grade
            return foundedWeapon
        } else {
            return  console.error("Weapon not found")
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
