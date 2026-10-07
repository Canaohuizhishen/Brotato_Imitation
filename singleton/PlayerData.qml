pragma Singleton
import QtQuick 2.15
import com.mygame.utils 1.0
import "../logic/SaveManager.js" as SaveManager

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

    property string roleName: ""             //当前角色名
    property string originWeaponName: ""     //当前初始武器名
    property int difficulty: 0               //当前难度
    readonly property int totalWaveNumber: 20//通关波数
    property int currentWaveNumber: 1        //当前波次

    property int materialsNumber: 0          //当前材料数
    property int remainingMaterialsNumber: 0 //存储材料数
    property int _waveStartRemainingMaterials: 0 //本波开始时"余料池"快照（严格回退还原到波初用）
    property bool _xpAdjusting: false        //onCurXpChanged 防重入守卫（见该处理器注释）
    property int curWaveMaterialsNumber: 0   //当前波次获得的材料数，便于中途返回主菜单时回退材料数和经验及等级
    property int curWaveXpNumber: 0          //当前波次获得的经验值（精确口径，严格回退用）
    readonly property int pickupRange: 150 + pickingRegion   //拾取范围（基础值 + 次要属性加成）
    property double goodsDiscountRate: 1     //商品价格倍率
    property double expDiscountRate: 1       //升级所需经验值倍率

    property var weapons: ListModel{}
    property var props: ListModel{}
    property var lastStoreGoods: ListModel{} //上次游戏退出时商店的商品项
    property int lastStoreRefreshTimes: 0    //上次游戏退出时商店的刷新次数
    property int maxDifficultyCompleted: -1  //已通关的最高难度
    property int maxDifficulty: 0            //已实现的最高难度
    property FileManager fileManager: FileManager {}

    property bool isInCombat: false //正在战斗状态的布尔值

    signal weaponsListChanged()
    signal upgrad()

    Component.onCompleted: {
        loadGame()
    }

    Component.onDestruction: {
        saveGame()
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
        // 防重入：本处理器内对 curXp 的写会同步递归触发自身——递归帧里 curLevel++
        // 尚未执行，maxXp 会按旧级阈值重复扣除（单次批量跨级时账目错误，且与降级
        // 回退不对称）。守卫阻断重入后，下方循环按"每级各自的 maxXp"逐级走账
        // （与负经验的降级回路精确互逆，供死亡重试的收益回退使用）。
        if (_xpAdjusting) return
        _xpAdjusting = true
        var maxIter = 100
        while(curXp>=maxXp && maxXp > 0 && --maxIter > 0){
            curXp-=maxXp
            curLevel++
            upgrad()
        }
        maxIter = 100
        while(curXp<0 && --maxIter > 0){
            if(curLevel<=0){
                curXp=0
                break
            }
            curLevel--
            curXp+=maxXp
            maxHp-=2 //多减1抵消等级变化时的自动加一
        }
        _xpAdjusting = false
    }

    onDodgeChanged: {
        if(dodge>60)dodge=60
    }

    onCurrentWaveNumberChanged: {
        PlayerData.curWaveMaterialsNumber=0
        PlayerData.curWaveXpNumber=0
    }

    onIsInCombatChanged: {
        // 进入战斗（波次开始）时快照"余料池"，供严格回退还原到波初值
        if(isInCombat){
            _waveStartRemainingMaterials=remainingMaterialsNumber
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

        // roleName=""
        // originWeaponName=""
        // difficulty=0
        currentWaveNumber = 1

        materialsNumber = 0
        remainingMaterialsNumber = 0
        _waveStartRemainingMaterials=0
        _xpAdjusting=false
        curWaveMaterialsNumber=0
        curWaveXpNumber=0
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

    // 回退本波中途获得的收益（材料/经验精确口径），并把"余料池"还原到本波开始时的快照。
    // 单一收口：死亡重试（严格回退）与中途返回主菜单共用，勿在使用点重复回退逻辑。
    function rollbackWaveGains() {
        materialsNumber -= curWaveMaterialsNumber
        curXp -= curWaveXpNumber
        curWaveMaterialsNumber = 0
        curWaveXpNumber = 0
        remainingMaterialsNumber = _waveStartRemainingMaterials
    }

    function saveGame() {
        SaveManager.saveGame(root, fileManager, appDataPath)
    }

    function loadGame() {
        SaveManager.loadGame(root, fileManager, appDataPath)
    }
}
