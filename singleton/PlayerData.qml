pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    //主要属性
    property int curLevel: 0                 //目前等级
    property int maxXp: (curLevel<5 ? 5+10*curLevel : 50+Math.pow(curLevel,2))*expDiscountRate //最大经验
    property int curXp: 0                    //当前经验
    property int maxHp: 10                   //最大血量
    property double curHp: 10                //当前血量
    property int hpRegeneration: 0           //生命恢复
    property int lifeSteal: 0                //生命偷取
    property int damage: 0                   //伤害
    property int meleeDamage: 0              //近战伤害
    property int rangedDamage: 0             //远程伤害
    property int elementalDamage: 0          //元素伤害
    property int attackSpeed: 0              //攻击速度
    property int critChance: 0               //暴击率
    property int engineering: 0              //工程学
    property int range: 0                    //攻击范围
    property int armor: 0                    //护甲
    property int dodge: 0                    //闪避
    property int speed: 0                    //速度
    property int luck: 0                     //幸运
    property int harvesting: 0               //收获

    //次要属性
    property int consumptiveTherapy :0       //消耗品治疗
    property int materialTherapy:0           //材料治疗
    property int gainExperience:0            //获得经验
    property int pickingRegion :0            //拾取范围
    property int propPrices:0                //道具价格
    property int explosiveDamage:0           //爆炸伤害
    property int explosionRange:0            //爆炸范围
    property int rebound:0                   //反弹
    property int penetrate:0                 //贯通
    property int penetratingDamage:0         //贯通伤害
    property int damageToBoss:0              //对boss伤害
    property int burningRatePercentage:0     //燃烧速度百分比
    property int burningRate:0               //燃烧速度
    property int repel:0                     //击退
    property int obtainingDoubleMaterial:0   //双倍材料
    property int materialsInTheBox:0         //箱子里的材料
    property int freeRefresh:0               //免费刷新
    property int trees:0                     //树木
    property int enemy:0                     //敌人
    property int enemySpeed:0                //敌人速度

    property int totalWaveNumber: 20         //通关波数
    property int currentWaveNumber: 0        //当前波次
    property int lastWaveNumber: 0           //上一次的波次，用来判断波次改变时的增减
    property int materialsNumber: 0          //当前材料数
    property int remainingMaterialsNumber: 0 //存储材料数
    property int pickupRange: 150            //拾取范围
    property double goodsDiscountRate: 1     //商品价格倍率
    property double expDiscountRate: 1       //升级所需经验值倍率

    property var weapons: ListModel{}
    property var props: ListModel{}
    property var lastStoreGoods: ListModel{} //上次游戏退出时商店的商品项
    property int lastStoreRefreshTimes: 0    //上次游戏退出时商店的刷新次数
    property int curDifficulty: 0            //当前难度
    property int maxDifficultyCompleted: -1  //已通关的最高难度

    property bool isInCombat: false //正在战斗状态的布尔值

    signal weaponsListChanged()

    Component.onCompleted: {
        //for(var i=0;i<1;i++)addWeapon("smg",1)
        // addWeapon("smg",4)
        // addProp("bat",12)
        // addProp("flag",101)
        // addGood("bat",2)
        // addGood("smg",3)
        // showWeapons()
        // showProps()
        // showLastStoreGoods()
    }

    onCurLevelChanged: {
        maxHp++
        curHp++
    }

    onMaxHpChanged: {
        if(curHp>=maxHp){
            curHp=maxHp
        }
    }

    onCurHpChanged: {
        if(curHp>=maxHp){
            curHp=maxHp
        }else if(curHp<0){
            curHp=0
        }
    }

    onCurXpChanged: {
        if(curXp>=maxXp){
            curXp-=maxXp
            curLevel++
        }
    }

    onDodgeChanged: {
        if(dodge>60)dodge=60
    }

    onCurrentWaveNumberChanged: {
        //console.log(PlayerData.lastWaveNumber,PlayerData.currentWaveNumber)
        // if(currentWaveNumber>1 && PlayerData.lastWaveNumber<PlayerData.currentWaveNumber){
        //     curXp+=harvesting
        //     materialsNumber+=harvesting
        //     harvesting=Math.ceil(harvesting*1.05)
        //     lastWaveNumber=currentWaveNumber
        // }
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

        consumptiveTherapy = 0
        materialTherapy = 0
        gainExperience = 0
        pickingRegion = 0
        propPrices = 0
        explosiveDamage = 0
        explosionRange = 0
        rebound = 0
        penetrate = 0
        penetratingDamage = 0
        damageToBoss = 0
        burningRatePercentage = 0
        burningRate = 0
        repel = 0
        obtainingDoubleMaterial = 0
        materialsInTheBox = 0
        freeRefresh = 0
        trees = 0
        enemy = 0
        enemySpeed = 0

        currentWaveNumber = 0
        materialsNumber = 0
        remainingMaterialsNumber = 0
        pickupRange = 150
        goodsDiscountRate = 1
        expDiscountRate = 1
        weapons.clear()
        props.clear()
        lastStoreGoods.clear()
        lastStoreRefreshTimes = 0
        isInCombat = false
    }

    function hpRegenerationPerSecond(){
        return hpRegeneration==0 ? 0.01 : 0.1+0.09*hpRegeneration
    }

    function damageReduction(){
        return armor/(armor+15)
    }

    function addWeapon(weaponName,grade=1){
        weapons.append({"weaponName": weaponName,"grade": grade})
        weaponsListChanged()
    }

    function addProp(propName,number=1){
        props.append({"propName": propName,"number": number})
    }

    function addGood(goodName,grade=1){
        lastStoreGoods.append({"goodName": goodName,"grade": grade})
    }

    function showWeapons(){
        console.log("\n----武器栏:----")
        for(var i=0;i<weapons.count;i++)console.log(weapons.get(i).weaponName,weapons.get(i).grade)
    }

    function showProps(){
        console.log("\n----道具栏:----")
        for(var i=0;i<props.count;i++)console.log(props.get(i).propName,props.get(i).number)
    }

    function showLastStoreGoods(){
        console.log("\n----上次退出时的商店的商品项:----")
        for(var i=0;i<lastStoreGoods.count;i++)console.log(lastStoreGoods.get(i).goodName,lastStoreGoods.get(i).grade)
    }
}
