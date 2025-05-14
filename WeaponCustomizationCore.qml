import QtQuick 2.15

Item {
    id: core

    function getWeapon(weaponName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==weaponName)break
        }
        return core.children[i]
    }

    RoleCustomizationCore{
        id: roleCore
    }

    Item{
        id: submachineGun
        objectName: "冲锋枪"
        readonly property string type: "枪械"
        readonly property string talentText: `
        <font color='#dad2a4'>伤害 : </font><font color='white'>`+(3+0.5*roleCore.rangedDamage)+`(+50%远程伤害)</font><br>
        <font color='#dad2a4'>暴击 : </font><font color='white'>x1.5(`+1.5*roleCore.critChance+`%概率)</font><br>
        <font color='#dad2a4'>冷却 : </font><font color='white'>0.17s</font><br>
        <font color='#dad2a4'>范围 : </font><font color='white'>400(远战)</font><br>
        `
    }

    Item{
        id: wand
        objectName: "魔杖"
        readonly property string type: "元素"
        readonly property string talentText: `
            <font color='#dad2a4'>伤害 : </font><font color='white'>`+(1+0.5*roleCore.elementalDamage)+`(+50%元素伤害)</font><br>
            <font color='#dad2a4'>暴击 : </font><font color='white'>x2(`+2*roleCore.critChance+`%概率)</font><br>
            <font color='#dad2a4'>冷却 : </font><font color='white'>0.86s</font><br>
            <font color='#dad2a4'>范围 : </font><font color='white'>350(远战)</font><br>
            <font color='white'>造成3x`+3+roleCore.elementalDamage+`(+100%元素伤害)燃烧伤害</font>
        `
    }
}
