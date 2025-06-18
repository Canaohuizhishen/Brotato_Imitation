pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    property int curLevel: 0   //目前等级
    property int maxXp: curLevel<5 ? 5+10*curLevel : 50+Math.pow(curLevel,2) //最大经验
    property int curXp: 0    //当前经验
    property int maxHp: 10   //最大血量
    property int curHp: 10   //当前血量
    property int hpRegeneration: 0  //生命恢复
    property int lifeSteal: 0   //生命偷取
    property int damage: 0      //伤害
    property int meleeDamage: 0  //近战伤害
    property int rangedDamage: 0  //远程伤害
    property int elementalDamage: 0  //元素伤害
    property int attackSpeed: 0   //攻击速度
    property int critChance: 0   //暴击率
    property int engineering: 0  //工程学
    property int range: 0     //攻击范围
    property int armor: 0     //护甲
    property int dodge: 0     //闪避
    property int speed: 0     //速度
    property int luck: 0      //幸运
    property int harvesting: 0  //收获

    //次要
    property int consumptiveTherapy :0//消耗性治疗
    property int materialTherapy:0    //材料治疗
    property int gainExperience:0     //获得经验
    property int pickingRegion :0     //拾取范围
    property int propPrices:0         //道具价格
    property int explosiveDamage:0    //爆炸伤害
    property int explosionRange:0     //爆炸范围
    property int rebound:0            //反弹
    property int penetrate:0          //贯通
    property int penetratingDamage:0  //贯通伤害
    property int damageToBoss:0       //对boss伤害
    property int burningRatePercentage:0 //燃烧速度百分比
    property int burningRate:0        //燃烧速度
    property int repel:0              //击退
    property int obtainingDoubleMaterial:0 //双倍材料
    property int materialsInTheBox:0   //箱子里的材料
    property int freeRefresh:0        //免费刷新
    property int trees:0              //树木
    property int enemy:0              //敌人
    property int enemySpeed:0         //敌人速度


    property int pickupRange: 150
    property int materialsNumber: 0
    property int remainingMaterialsNumber: 0

    onCurXpChanged: {
        if(curXp>=maxXp){
            curXp-=maxXp
            curLevel++
        }
    }

    function init(){
        curLevel = 0
        curXp = 0
        maxHp = 10
        curHp = maxHp
        hpRegeneration = 0
        lifeSteal = 0
        damage = 0
        meleeDamage = 0
        rangedDamage = 0
        elementalDamage = 0
        attackSpeed = 0
        critChance = 0
        engineering = 0
        range = 0
        armor = 0
        dodge = 0
        speed = 0
        luck = 0
        harvesting = 0
    }
}
