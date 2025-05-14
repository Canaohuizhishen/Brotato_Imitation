import QtQuick 2.15

Item {
    id: core
    property int currentLevel: 0
    property int maxHp: 10
    property int hpRegeneration: 0
    property int lifeSteal: 0
    property int damage: 0
    property int meleeDamage: 0
    property int rangedDamage: 0
    property int elementalDamage: 0
    property int attackSpeed: 0
    property int critChance: 0
    property int engineering: 0
    property int range: 0
    property int armor: 0
    property int dodge: 0
    property int speed: 0
    property int luck: 0
    property int harvesting: 0

    function getRole(roleName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==roleName)break
        }
        return core.children[i]
    }

    Item{
        id: wellRounded
        objectName: "全能者"
        readonly property double scalingFactor: 0.75
        readonly property double aspectRatio: 1.167
        readonly property string talentText: `
            <font color='lime'>+5</font><font color='white'> 最大生命值</font><br>
            <font color='lime'>+5</font><font color='white'> %速度</font><br>
            <font color='lime'>+8</font><font color='white'> 收获</font>
        `
        function setInitRoleAttributes(roleData){
            maxHp=15
            speed=5
            harvesting=8
        }
    }

    Item{
        id: mutant
        objectName: "异变体"
        readonly property double scalingFactor: 0.8
        readonly property double aspectRatio: 1.12
        readonly property string talentText: `
            <font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>
            <font color='red'>+50</font><font color='white'> %道具价格</font>
        `
        function setInitRoleAttributes(roleData){
            //do nothing
        }
    }
}
