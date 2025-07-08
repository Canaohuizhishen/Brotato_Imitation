import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property alias wellRounded: wellRounded
    property alias mutant: mutant

    function getRole(roleName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName===roleName || core.children[i].roleName===roleName){
                return core.children[i]
            }
        }
        console.error("roleName: ",roleName,"not found")
    }

    Item{
        id: wellRounded
        objectName: "wellRounded"
        property string roleName: "全能者"
        readonly property string talentText: `
        <font color='lime'>+5</font><font color='white'> 最大生命值</font><br>
        <font color='lime'>+5</font><font color='white'> %速度</font><br>
        <font color='lime'>+8</font><font color='white'> 收获</font>
        `
        function setInitRoleAttributes(){
            if(PlayerData.maxHp<15)PlayerData.maxHp=15
            PlayerData.curHp=PlayerData.maxHp
            if(PlayerData.speed<5)PlayerData.speed=5
            if(PlayerData.harvesting<8)PlayerData.harvesting=8
        }
    }

    Item{
        id: mutant
        objectName: "mutant"
        property string roleName: "异变体"
        readonly property string talentText: `
        <font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>
        <font color='red'>+50</font><font color='white'> %道具价格</font>
        `
        function setInitRoleAttributes(){
            if(PlayerData.expDiscountRate>0.33)PlayerData.expDiscountRate=0.33
            if(PlayerData.goodsDiscountRate<1.5)PlayerData.goodsDiscountRate=1.5
        }
    }
}
