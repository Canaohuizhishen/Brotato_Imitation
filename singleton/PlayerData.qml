pragma Singleton
import QtQuick 2.15
import com.mygame.utils 1.0
QtObject {
    id: root
    property FileManager fileManager: FileManager {}
    // 添加 shopContext 属性
    property QtObject shopContext: QtObject {
        property ListModel _purchasedPropsModel: ListModel {}
        property ListModel _duplicatePropsCountModel: ListModel {}
        property ListModel _purchasedWeaponsModel: ListModel {}
    }
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

    property bool isInCombat: false //正在战斗状态的布尔值

    signal weaponsListChanged()
    signal hpChanged()


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
        shopContext._purchasedPropsModel.clear();
        shopContext._duplicatePropsCountModel.clear();
        shopContext._purchasedWeaponsModel.clear();
    }
    function saveGame() {
        try {
            const saveData = {
                "curLevel": curLevel,
                "maxXp": maxXp,
                "curXp": curXp,
                "maxHp": maxHp,
                "curHp": curHp,
                "hpRegeneration": hpRegeneration,
                "lifeSteal": lifeSteal,
                "damage": damage,
                "meleeDamage": meleeDamage,
                "rangedDamage": rangedDamage,
                "elementalDamage": elementalDamage,
                "attackSpeed": attackSpeed,
                "critChance": critChance,
                "engineering": engineering,
                "range": range,
                "armor": armor,
                "dodge": dodge,
                "speed": speed,
                "luck": luck,
                "consumptiveTherapy": consumptiveTherapy,
                "materialTherapy": materialTherapy,
                "gainExperience": gainExperience,
                "pickingRegion": pickingRegion,
                "propPrices": propPrices,
                "explosiveDamage": explosiveDamage,
                "explosionRange": explosionRange,
                "rebound": rebound,
                "penetrate": penetrate,
                "penetratingDamage": penetratingDamage,
                "damageToBoss": damageToBoss,
                "burningRatePercentage": burningRatePercentage,
                "burningRate": burningRate,
                "repel": repel,
                "obtainingDoubleMaterial": obtainingDoubleMaterial,
                "materialsInTheBox": materialsInTheBox,
                "freeRefresh": freeRefresh,
                "trees": trees,
                "enemy": enemy,
                "enemySpeed": enemySpeed,

                "totalWaveNumber": totalWaveNumber,
                "lastWaveNumber": lastWaveNumber,
                "materialsNumber": materialsNumber,
                "remainingMaterialsNumber": remainingMaterialsNumber,
                "goodsDiscountRate": goodsDiscountRate,
                "pickupRange": pickupRange,
                "expDiscountRate": expDiscountRate,
                "currentWaveNumber": currentWaveNumber,

                "weapons": weaponsToArray(weapons),
                "props": propsToArray(props),
                "lastStoreRefreshTimes": lastStoreRefreshTimes,

                "lastStoreGoods": propsToArray(lastStoreGoods),
                // ...其他需要保存的属性...
                "isInCombat": isInCombat
            }

            const savePath = appDataPath + "/savegame.json"
            const success = fileManager.saveGameData(savePath,
                                                     JSON.parse(JSON.stringify(saveData)))

            if (success) {
                console.log("游戏保存成功")
            } else {
                console.error("保存失败！")
            }
        } catch (e) {
            console.error("保存异常：" + e)
        }
    }

    // 加载游戏
    function loadGame() {
        try {
            const savePath = appDataPath + "/savegame.json"
            const saveData = fileManager.loadGameData(savePath)
            // 检查是否为空对象
            if (Object.keys(saveData).length === 0) {
                console.log("未找到有效存档数据")
                return
            }

            // 核心属性恢复（使用空值合并运算符??提供默认值）
            curLevel = saveData.curLevel ?? 0
            maxXp = saveData.maxXp ?? 0
            curXp = saveData.curXp ?? 0
            maxHp = saveData.maxHp ?? 10
            curHp = saveData.curHp ?? maxHp
            hpRegeneration = saveData.hpRegeneration ?? 0
            lifeSteal = saveData.lifeSteal ?? 0
            damage = saveData.damage ?? 0
            meleeDamage = saveData.meleeDamage ?? 0
            rangedDamage = saveData.rangedDamage ?? 0
            elementalDamage = saveData.elementalDamage ?? 0
            explosionRange = saveData.explosionRange ?? 0
            critChance = saveData.critChance ?? 0
            engineering = saveData.engineering ?? 0
            range = saveData.range ?? 0
            armor = saveData.armor ?? 0
            dodge = saveData.dodge ?? 0
            speed = saveData.speed ?? 0
            luck = saveData.luck ?? 0
            harvesting = saveData.harvesting ?? 0

            // 游戏状态恢复
            currentWaveNumber = saveData.currentWaveNumber ?? 0
            materialsNumber = saveData.materialsNumber ?? 0
            remainingMaterialsNumber = saveData.remainingMaterialsNumber ?? 0
            lastWaveNumber = saveData.lastWaveNumber ?? 0
            totalWaveNumber = saveData.totalWaveNumber ?? 20
            goodsDiscountRate = saveData.goodsDiscountRate ?? 1.0
            pickupRange = saveData.pickupRange ?? 150
            expDiscountRate = saveData.expDiscountRate ?? 1.0
            isInCombat = saveData.isInCombat ?? false

            //次要属性
            consumptiveTherapy = saveData.consumptiveTherapy ?? 0
            materialTherapy = saveData.materialTherapy ?? 0
            gainExperience = saveData.gainExperience ?? 0
            pickingRegion = saveData.pickingRegion ?? 0
            propPrices = saveData.propPrices ?? 0
            explosiveDamage = saveData.explosiveDamage ?? 0
            rebound = saveData.rebound ?? 0
            penetrate = saveData.penetrate ?? 0
            penetratingDamage = saveData.penetratingDamage ?? 0
            damageToBoss = saveData.damageToBoss ?? 0
            burningRatePercentage = saveData.burningRatePercentage ?? 0
            burningRate = saveData.burningRate ?? 0
            repel = saveData.repel ?? 0
            obtainingDoubleMaterial = saveData.obtainingDoubleMaterial ?? 0
            materialsInTheBox = saveData.materialsInTheBox ?? 0
            freeRefresh = saveData.freeRefresh ?? 0
            trees = saveData.trees ?? 0
            enemy = saveData.enemy ?? 0
            enemySpeed = saveData.enemySpeed ?? 0

            // 武器列表恢复
            weapons.clear()
            if (saveData.weapons && Array.isArray(saveData.weapons)) {
                saveData.weapons.forEach(weapon => weapons.append(weapon))
            }

            // 道具列表恢复
            props.clear()
            if (saveData.props && Array.isArray(saveData.props)) {
                saveData.props.forEach(prop => props.append(prop))
            }
            // 商店商品项恢复
            lastStoreGoods.clear();
            if (saveData.lastStoreGoods && Array.isArray(saveData.lastStoreGoods)) {
                saveData.lastStoreGoods.forEach(item => lastStoreGoods.append(item));
            }

            console.log("游戏加载成功，当前等级：" + curLevel)
        } catch (e) {
            console.error("加载异常：" + e)
        }
    }
    function weaponsToArray(weaponsModel) {
        const arr = []
        for (let i = 0; i < weaponsModel.count; ++i) {
            arr.push(weaponsModel.get(i))
        }
        return arr
    }

    function propsToArray(propsModel) {
        const arr = []
        for (let i = 0; i < propsModel.count; ++i) {
            arr.push(propsModel.get(i))
        }
        return arr
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
        hpChanged()
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
        if(currentWaveNumber>1 && PlayerData.lastWaveNumber<PlayerData.currentWaveNumber){
            curXp+=harvesting
            materialsNumber+=harvesting
            harvesting=Math.ceil(harvesting*1.05)
            lastWaveNumber=currentWaveNumber
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

    function hpRegeneratPerSecond(){
        curHp+=0.1+0.09*hpRegeneration
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
