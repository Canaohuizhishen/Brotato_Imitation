import QtQuick
import QtTest
import "../logic/DataLoader.js" as DataLoader
import "../logic/SpatialGrid.js" as SpatialGrid
import "../logic/utils/tool.js" as Tool
import "../logic/utils/color.js" as Color
import "../logic/SaveManager.js" as SaveManager
import "../logic/ShopLogicHandler.js" as Shop

TestCase {
    name: "CoreTests"

    function test_getAllWeapons() {
        verify(Array.isArray(DataLoader.getAllWeapons()))
        compare(DataLoader.getAllWeapons().length, 6)
    }

    function test_getWeapon_spear() {
        var s = DataLoader.getWeapon("spear")
        verify(s)
        compare(s.objectName, "spear")
        compare(s.weaponName, "长矛")
        compare(s.grades.length, 4)
        compare(s.grades[0].baseDamage, 15)
    }

    function test_getWeapon_smg() {
        compare(DataLoader.getWeapon("smg").grades[0].baseDamage, 3)
    }

    function test_getWeapon_grade3() {
        compare(DataLoader.getWeapon("spear", 3).baseDamage, 40)
    }

    function test_getWeapon_notFound() {
        compare(DataLoader.getWeapon("nonexistent_xyz"), null)
    }

    function test_getWeapon_deepCopy() {
        var a = DataLoader.getWeapon("spear")
        var b = DataLoader.getWeapon("spear")
        a.weaponName = "篡改值"
        compare(b.weaponName, "长矛")
        // 验证嵌套数组的隔离性（深拷贝应递归到所有嵌套结构）
        a.grades[0].baseDamage = 999
        compare(b.grades[0].baseDamage, 15)
    }

    function test_getProp_bat() {
        var p = DataLoader.getProp("bat")
        compare(p.objectName, "bat")
        compare(p.effects[0].delta, 2)
    }

    function test_getProp_wellRounded() {
        compare(DataLoader.getProp("wellRounded").grade, 5)
    }

    function test_getProp_empty() {
        var p = DataLoader.getProp("")
        compare(p.objectName, "")
        compare(p.grade, 1)
        compare(p.effects.length, 0)
    }

    function test_getProp_notFoundFallback() {
        // getProp 对不存在的 key 返回默认回退对象 {grade:1}，而非 null
        compare(DataLoader.getProp("nonexistent_xyz").grade, 1)
    }

    function test_getAllRoles() {
        var roles = DataLoader.getAllRoles()
        compare(roles.length, 2)
        compare(roles[0].roleName, "全能者")
        compare(roles[1].roleName, "异变体")
    }

    function test_getRole_wellRounded() {
        compare(DataLoader.getRole("wellRounded").roleName, "全能者")
    }

    function test_getMonster_charger() {
        compare(DataLoader.getMonster("charger").initHp, 4)
        compare(DataLoader.getMonster("charger").monsterName, "冲锋者")
    }

    function test_getMonster_notFound() {
        compare(DataLoader.getMonster("nonexistent_xyz"), null)
    }

    function test_getUpgradeOption_lung() {
        compare(DataLoader.getUpgradeOption(1, "lung").optionName, "肺")
    }

    function test_getUpgradeOption_reflexes() {
        compare(DataLoader.getUpgradeOption(3, "reflexes").grade, 3)
    }

    function test_getUpgradeOption_notFound() {
        compare(DataLoader.getUpgradeOption(1, "nonexistent"), null)
    }

    function test_waveData() {
        compare(DataLoader.getWaveConfig(1).wave, 1)
        compare(DataLoader.getWaveConfig(20).wave, 20)
        compare(DataLoader.getWaveConfig(999), null)
    }

    function test_getWeaponRandomly() {
        compare(DataLoader.getWeaponRandomly(1, {1:1,2:1,3:1,4:1}).length, 1)
        compare(DataLoader.getWeaponRandomly(4, {1:1,2:1,3:1,4:1}).length, 4)
    }

    function test_getPropRandomly() {
        var r = DataLoader.getPropRandomly(2, {1:1,2:1,3:1,4:1})
        compare(r.length, 2)
        // 验证 grade 在有效范围内
        verify(r[0].grade >= 1 && r[0].grade <= 4)
        verify(r[1].grade >= 1 && r[1].grade <= 4)
    }

    function test_getUpgradeOptionRandomly() {
        var r = DataLoader.getUpgradeOptionRandomly(3, {1:1,2:1,3:1,4:1})
        compare(r.length, 3)
        // 验证不重复且 grade 有效
        verify(r[0].optionName !== r[1].optionName || r.length === 1)
        for (var i = 0; i < r.length; i++) {
            verify(r[i].grade >= 1 && r[i].grade <= 4)
        }
    }

    function test_renderWeapon_spear() {
        var w = DataLoader.getWeapon("spear", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0,rangedDamage:0,damage:0,attackSpeed:0,range:0,critChance:0})
        compare(r.dmg, 15)
        verify(r.isMelee)
    }

    function test_renderWeapon_spear_melee() {
        var w = DataLoader.getWeapon("spear", 1)
        compare(DataLoader.renderWeaponTalentText(w, {meleeDamage:10,rangedDamage:0,damage:0,attackSpeed:0,range:0,critChance:0}).dmg, 25)
    }

    function test_renderWeapon_smg() {
        var w = DataLoader.getWeapon("smg", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0,rangedDamage:0,damage:0,attackSpeed:0,range:0,critChance:0})
        compare(r.isMelee, false)
        compare(r.dmg, 3)
    }

    function test_renderWeapon_smg_damage() {
        var w = DataLoader.getWeapon("smg", 4)
        compare(DataLoader.renderWeaponTalentText(w, {meleeDamage:0,rangedDamage:0,damage:50,attackSpeed:0,range:0,critChance:0}).dmg, 12)
    }

    function test_renderWeapon_null() {
        compare(DataLoader.renderWeaponTalentText({}, {damage:0}), null)
    }

    function test_renderWeapon_flamethrower() {
        var w = DataLoader.getWeapon("flamethrower", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0, rangedDamage:0, elementalDamage:0, damage:0, attackSpeed:0, range:0, critChance:0})
        compare(r.dmg, 4)
        compare(r.isElemental, true)
        compare(r.isMelee, false)
    }

    function test_renderWeapon_flamethrower_elemental() {
        var w = DataLoader.getWeapon("flamethrower", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0, rangedDamage:0, elementalDamage:10, damage:0, attackSpeed:0, range:0, critChance:0})
        // (4 + 10*1.0) * (1 + 0/100) = 14
        compare(r.dmg, 14)
    }

    function test_renderWeapon_iceCone() {
        var w = DataLoader.getWeapon("ice_cone", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0, rangedDamage:0, elementalDamage:0, damage:0, attackSpeed:0, range:0, critChance:0})
        // 10 + 0*1.0 = 10
        compare(r.dmg, 10)
        compare(r.isElemental, true)
        compare(r.isMelee, false)
    }

    function test_renderWeapon_iceCone_elemental() {
        var w = DataLoader.getWeapon("ice_cone", 1)
        var r = DataLoader.renderWeaponTalentText(w, {meleeDamage:0, rangedDamage:0, elementalDamage:5, damage:0, attackSpeed:0, range:0, critChance:0})
        // (10 + 5*1.0) * 1 = 15
        compare(r.dmg, 15)
    }

    function test_renderWeapon_flamethrower_grade4() {
        var w = DataLoader.getWeapon("flamethrower", 4)
        compare(DataLoader.renderWeaponTalentText(w, {meleeDamage:0, rangedDamage:0, elementalDamage:5, damage:10, attackSpeed:0, range:0, critChance:0}).dmg,
            // (14 + 5*2.0) * (1 + 10/100) = (14+10)*1.1 = 26.4 -> floor 26
            26)
    }

    function test_applyEffects_delta() {
        var d = {maxHp:100,speed:10}
        DataLoader.applyEffects([{attribute:"maxHp",delta:5},{attribute:"speed",delta:-2}],d,1)
        compare(d.maxHp, 105)
        compare(d.speed, 8)
    }

    function test_applyEffects_conditionLt() {
        var d = {maxHp:10}
        DataLoader.applyEffects([{attribute:"maxHp",condition:"lt",conditionValue:15,setTo:15}],d,1)
        compare(d.maxHp, 15)
        var d2 = {maxHp:20}
        DataLoader.applyEffects([{attribute:"maxHp",condition:"lt",conditionValue:15,setTo:15}],d2,1)
        compare(d2.maxHp, 20)
    }

    function test_applyEffects_setToProp() {
        var d = {curHp:0,maxHp:50}
        DataLoader.applyEffects([{attribute:"curHp",setToProp:"maxHp"}],d,1)
        compare(d.curHp, 50)
    }

    function test_applyEffects_deltaFromGrade() {
        var d = {damage:0}
        DataLoader.applyEffects([{attribute:"damage",deltaFromGrade:3}],d,3)
        compare(d.damage, 9)
    }

    function test_renderTalentText() {
        compare(DataLoader.renderTalentText("伤害 +{{value}}",5), "伤害 +5")
    }

    // ---- SpatialGrid ----

    function test_spatial_init() {
        SpatialGrid.init(100)
        compare(SpatialGrid.query(0,0,1000,1000).length, 0)
    }

    function test_spatial_insertQuery() {
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"e1",width:40,height:40},50,50)
        compare(SpatialGrid.query(0,0,200,200).length, 1)
    }

    function test_spatial_queryOutside() {
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"e1",width:40,height:40},50,50)
        compare(SpatialGrid.query(500,500,100,100).length, 0)
    }

    function test_spatial_remove() {
        SpatialGrid.init(100)
        var e = {_spatialId:"e1",width:40,height:40}
        SpatialGrid.insert(e,50,50)
        SpatialGrid.remove(e)
        compare(SpatialGrid.query(0,0,200,200).length, 0)
    }

    function test_spatial_update() {
        SpatialGrid.init(100)
        var e = {_spatialId:"e1",width:40,height:40}
        SpatialGrid.insert(e,50,50)
        SpatialGrid.update(e,500,500)
        compare(SpatialGrid.query(400,400,200,200).length, 1)
    }

    function test_spatial_multiple() {
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"a",width:40,height:40},50,50)
        SpatialGrid.insert({_spatialId:"b",width:20,height:20},70,70)
        compare(SpatialGrid.query(0,0,200,200).length, 2)
    }

    function test_spatial_clear() {
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"a",width:40,height:40},50,50)
        SpatialGrid.insert({_spatialId:"b",width:20,height:20},150,150)
        SpatialGrid.clear()
        compare(SpatialGrid.query(0,0,500,500).length, 0)
    }

    function test_spatial_bigEntity() {
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"big",width:250,height:250},50,50)
        verify(SpatialGrid.query(0,0,500,500).length >= 1)
    }

    // ---- Tool ----

    function test_tool_getDistance() {
        compare(Tool.getDistance({x:0,y:0},{x:3,y:4}), 5)
        compare(Tool.getDistance({x:10,y:10},{x:10,y:10}), 0)
    }

    function test_tool_reduceAbs() {
        compare(Tool.reduceAbs(10,3), 7)
        compare(Tool.reduceAbs(-10,3), -7)
        compare(Tool.reduceAbs(0,5), 5)
    }

    function test_tool_getQuadrant() {
        compare(Tool.getQuadrant(45), 1)
        compare(Tool.getQuadrant(135), 2)
        compare(Tool.getQuadrant(225), 3)
        compare(Tool.getQuadrant(315), 4)
    }

    function test_tool_getQuadrant_boundary() {
        compare(Tool.getQuadrant(0), 1)
        compare(Tool.getQuadrant(90), 2)
        compare(Tool.getQuadrant(180), 3)
        compare(Tool.getQuadrant(270), 4)
    }

    function test_tool_getQuadrant_negative() {
        compare(Tool.getQuadrant(-45), 4)
        compare(Tool.getQuadrant(-360), 1)
    }

    function test_tool_approximatelyEqual() {
        verify(Tool.approximatelyEqual(0.1+0.2,0.3))
        verify(!Tool.approximatelyEqual(0.1,0.2))
    }

    function test_tool_getMirrorX() {
        compare(Tool.getMirrorX(10,20), 30)
        compare(Tool.getMirrorX(0,100), 200)
    }

    // ---- Color ----

    function test_color_lightenColor_blackWhite() {
        compare(Color.lightenColor("#000000",1.1),"#000000")
        compare(Color.lightenColor("#ffffff",1.1),"#ffffff")
    }

    function test_color_lightenColor_mid() {
        compare(Color.lightenColor("#323232",1.1),"#373737")
    }

    function test_color_lightenColor_cap() {
        compare(Color.lightenColor("#f0f0f0",2.0),"#ffffff")
    }

    function test_color_getBorderColor() {
        compare(Color.getBorderColor(1),"#000000")
        compare(Color.getBorderColor(2),"#5abeff")
        verify(/^#[0-9a-f]{6}$/i.test(Color.getBorderColor(4)), "getBorderColor 应返回合法 hex 颜色")
    }

    function test_color_allFormats() {
        for (var g=1; g<=5; g++) {
            verify(/^#[0-9a-f]{6}$/i.test(Color.getButtonColor(g)))
            verify(/^#[0-9a-f]{6}$/i.test(Color.getBackgroundColor(g)))
            verify(/^#[0-9a-f]{6}$/i.test(Color.getImageBackgroundColor(g)))
        }
    }

    // ---- DataLoader: 剩余函数 ----

    function test_getWeaponGradeCounts() {
        var c = DataLoader.getWeaponGradeCounts()
        verify(typeof c === "object")
        // 各等级计数应为非负整数
        verify(c[1] >= 0 && c[2] >= 0 && c[3] >= 0 && c[4] >= 0)
        // 总计入库数 = 武器数 × 每把武器4个等级
        verify(c[1] + c[2] + c[3] + c[4] >= 4)
    }

    function test_getPropGradeCounts() {
        var c = DataLoader.getPropGradeCounts()
        verify(typeof c === "object")
        verify(c[1] >= 0 && c[2] >= 0 && c[3] >= 0 && c[4] >= 0)
    }

    function test_getTheme_valid() {
        var t = DataLoader.getTheme(4)
        verify(t !== null)
        compare(t.name, "梦幻之地")
        verify(Array.isArray(t.stoneImages))
    }

    function test_getTheme_invalid() {
        compare(DataLoader.getTheme(-1), null)
        compare(DataLoader.getTheme(999), null)
    }

    function test_getTheme_noData() {
        // 索引 0~3,5~6 没有数据
        compare(DataLoader.getTheme(0), null)
        compare(DataLoader.getTheme(1), null)
    }

    function test_getAllThemes() {
        var all = DataLoader.getAllThemes()
        verify(Array.isArray(all))
        verify(all.length >= 7)
        // 第 4 个（索引 4）是 梦幻之地
        verify(all[4] !== null)
        compare(all[4].name, "梦幻之地")
        // 验证深拷贝：修改返回值不影响缓存
        all[4].name = "篡改值"
        compare(DataLoader.getTheme(4).name, "梦幻之地")
    }

    // ---- SaveManager: 数据转换 ----

    function test_weaponsToArray() {
        var mock = {
            count: 2,
            get: function(i) { return [{weaponName:"spear",grade:1},{weaponName:"smg",grade:2}][i]; }
        }
        var arr = SaveManager.weaponsToArray(mock)
        compare(arr.length, 2)
        compare(arr[0].weaponName, "spear")
        compare(arr[0].grade, 1)
        compare(arr[1].weaponName, "smg")
        compare(arr[1].grade, 2)
    }

    function test_propsToArray() {
        var mock = {
            count: 1,
            get: function(i) { return [{propName:"bat",number:2}][i]; }
        }
        var arr = SaveManager.propsToArray(mock)
        compare(arr.length, 1)
        compare(arr[0].propName, "bat")
        compare(arr[0].number, 2)
    }

    function test_lastStoreGoodsToArray() {
        var mock = {
            count: 1,
            get: function(i) { return [{goods:"spear",isLockedModel:false,weaponGrade:1,isPurchased:true}][i]; }
        }
        var arr = SaveManager.lastStoreGoodsToArray(mock)
        compare(arr.length, 1)
        compare(arr[0].goods, "spear")
        compare(arr[0].isLockedModel, false)
        compare(arr[0].weaponGrade, 1)
        compare(arr[0].isPurchased, true)
    }

    // ---- ShopLogicHandler: 纯函数 ----

    function test_refreshPrice_wave1() {
        Shop.resetRefreshTimes()
        // wave 1: base = (1+1)=2, refreshTimes从-1→0, return 2+0=2
        compare(Shop.refreshPrice(1), 2)
        // 第二次: refreshTimes=1, return 2+1=3
        compare(Shop.refreshPrice(1), 3)
    }

    function test_refreshPrice_wave10() {
        Shop.resetRefreshTimes()
        // wave 10: increment=⌊10/2⌋=5, base=(10+5)=15, refreshTimes=0, return 15+0=15
        compare(Shop.refreshPrice(10), 15)
        // 第二次: refreshTimes=1, return 15+1×5=20
        compare(Shop.refreshPrice(10), 20)
    }

    function test_resetRefreshTimes() {
        Shop.resetRefreshTimes()
        Shop.refreshPrice(1)  // refreshTimes++ → 0
        Shop.refreshPrice(1)  // refreshTimes++ → 1
        Shop.resetRefreshTimes()
        Shop.refreshPrice(1)  // refreshTimes从-1→0(因为reset设为-1), return 2+0=2
        compare(Shop.refreshPrice(1), 3)
    }

    // freeRefresh 依赖 QML 单例 PlayerData，纯 JS 测试环境不可用
    // 已在 ShopLogicHandler.js 中通过 typeof 守卫确保无 PlayerData 时走原逻辑

    // ---- DataLoader: 边界/健壮性 ----

    function test_getWeapon_nullKey() {
        // getWeapon(null) 返回 null（与 getWeapon("nonexistent") 一致）
        var r = DataLoader.getWeapon(null)
        compare(r, null)
    }

    function test_getProp_nullKey() {
        // getProp 有 fallback 机制：null/未定义 key 返回默认对象 {grade:1}
        // 这与 getMonster(null) 返回 null 不同，是设计意图
        var r = DataLoader.getProp(null)
        verify(typeof r === "object")
    }

    function test_getMonster_nullKey() {
        // getMonster 没有 fallback：null key 返回 null
        // 这与 getProp(null) 返回默认对象不同，是设计意图
        var r = DataLoader.getMonster(null)
        compare(r, null)
    }

    function test_getRole_nullKey() {
        // getRole(null) 返回 null（与 getRole("nonexistent") 一致）
        var r = DataLoader.getRole(null)
        compare(r, null)
    }

    function test_getUpgradeOption_nullKey() {
        var r = DataLoader.getUpgradeOption(1, null)
        compare(r, null)
    }

    function test_getWaveConfig_edge() {
        compare(DataLoader.getWaveConfig(0), null)
        compare(DataLoader.getWaveConfig(-1), null)
    }

    function test_applyEffects_null() {
        var d = {maxHp: 100}
        // null effects 不应该崩溃
        DataLoader.applyEffects(null, d, 1)
        compare(d.maxHp, 100)
        // null playerData 不应该崩溃
        DataLoader.applyEffects([{attribute:"maxHp",delta:5}], null, 1)
    }

    function test_applyEffects_enemySpeed() {
        var d = {enemySpeed: 0, enemy: 0, trees: 0}
        DataLoader.applyEffects([{attribute:"enemySpeed",delta:8},{attribute:"enemy",delta:5},{attribute:"trees",delta:3}], d, 1)
        compare(d.enemySpeed, 8)
        compare(d.enemy, 5)
        compare(d.trees, 3)
    }

    function test_applyEffects_burning() {
        var d = {burningRatePercentage: 0, burningRate: 0}
        DataLoader.applyEffects([{attribute:"burningRatePercentage",delta:15},{attribute:"burningRate",delta:3}], d, 1)
        compare(d.burningRatePercentage, 15)
        compare(d.burningRate, 3)
    }

    function test_applyEffects_penetrateRebound() {
        var d = {penetrate: 0, rebound: 0, penetratingDamage: 0}
        DataLoader.applyEffects([{attribute:"penetrate",delta:1},{attribute:"rebound",delta:2},{attribute:"penetratingDamage",delta:30}], d, 1)
        compare(d.penetrate, 1)
        compare(d.rebound, 2)
        compare(d.penetratingDamage, 30)
    }

    // ---- SaveManager: JSON 序列化往返 ----

    function test_saveLoad_roundtrip() {
        // 构造 mock data 对象（模拟 PlayerData 的结构）
        var mockWeapons = {
            count: 2, _items: [{weaponName:"spear",grade:1},{weaponName:"smg",grade:2}],
            get: function(i) { return this._items[i]; },
            clear: function() { this._items = []; this.count = 0; },
            append: function(item) { this._items.push(item); this.count = this._items.length; }
        }
        var mockProps = {
            count: 1, _items: [{propName:"bat",number:2}],
            get: function(i) { return this._items[i]; },
            clear: function() { this._items = []; this.count = 0; },
            append: function(item) { this._items.push(item); this.count = this._items.length; }
        }
        var mockGoods = {
            count: 1, _items: [{goods:"spear",isLockedModel:false,weaponGrade:1,isPurchased:false}],
            get: function(i) { return this._items[i]; },
            clear: function() { this._items = []; this.count = 0; },
            append: function(item) { this._items.push(item); this.count = this._items.length; }
        }

        var playerData = {
            curLevel: 5, curXp: 50, maxHp: 100, curHp: 80,
            hpRegeneration: 2, lifeSteal: 1, damage: 10,
            meleeDamage: 5, rangedDamage: 3, elementalDamage: 2,
            attackSpeed: 20, critChance: 10, engineering: 0,
            range: 300, armor: 3, dodge: 5, speed: 110,
            luck: 0, harvesting: 5,
            consumptiveTherapy: 0, materialTherapy: 1,
            gainExperience: 0, pickingRegion: 0, propPrices: 0,
            explosiveDamage: 0, explosionRange: 0, rebound: 0,
            penetrate: 1, penetratingDamage: 0, damageToBoss: 0,
            burningRatePercentage: 0, burningRate: 0, repel: 0,
            obtainingDoubleMaterial: 0, materialsInTheBox: 0,
            freeRefresh: 0, trees: 0, enemy: 0, enemySpeed: 0,
            roleName: "wellRounded", originWeaponName: "spear",
            difficulty: 2, currentWaveNumber: 5,
            materialsNumber: 200, remainingMaterialsNumber: 150,
            goodsDiscountRate: 1.0, expDiscountRate: 1.0,
            weapons: mockWeapons, props: mockProps,
            lastStoreGoods: mockGoods, lastStoreRefreshTimes: 2,
            maxDifficultyCompleted: 1, isInCombat: true
        }

        // mock fileManager
        var storedData = null
        var mockFM = {
            saveGameData: function(path, data) { storedData = data; return true; },
            loadGameData: function(path) { return storedData || {}; }
        }

        // 保存
        SaveManager.saveGame(playerData, mockFM, "/test")

        // 验证数据已被存储
        verify(storedData !== null)
        compare(storedData.curLevel, 5)
        compare(storedData.roleName, "wellRounded")
        compare(storedData.weapons.length, 2)
        compare(storedData.props.length, 1)

        // 构造空的接收对象并加载
        var emptyWeapons = { count: 0, _items: [], get: function(i) { return this._items[i]; }, clear: function() { this._items = []; this.count = 0; }, append: function(item) { this._items.push(item); this.count = this._items.length; } }
        var emptyProps = { count: 0, _items: [], get: function(i) { return this._items[i]; }, clear: function() { this._items = []; this.count = 0; }, append: function(item) { this._items.push(item); this.count = this._items.length; } }
        var emptyGoods = { count: 0, _items: [], get: function(i) { return this._items[i]; }, clear: function() { this._items = []; this.count = 0; }, append: function(item) { this._items.push(item); this.count = this._items.length; } }

        var loadedData = {
            curLevel: 0, curXp: 0, maxHp: 0, curHp: 0,
            hpRegeneration: 0, lifeSteal: 0, damage: 0,
            meleeDamage: 0, rangedDamage: 0, elementalDamage: 0,
            attackSpeed: 0, critChance: 0, engineering: 0,
            range: 0, armor: 0, dodge: 0, speed: 100,
            luck: 0, harvesting: 0,
            consumptiveTherapy: 0, materialTherapy: 0,
            gainExperience: 0, pickingRegion: 0, propPrices: 0,
            explosiveDamage: 0, explosionRange: 0, rebound: 0,
            penetrate: 0, penetratingDamage: 0, damageToBoss: 0,
            burningRatePercentage: 0, burningRate: 0, repel: 0,
            obtainingDoubleMaterial: 0, materialsInTheBox: 0,
            freeRefresh: 0, trees: 0, enemy: 0, enemySpeed: 0,
            roleName: "", originWeaponName: "",
            difficulty: 0, currentWaveNumber: 0,
            materialsNumber: 0, remainingMaterialsNumber: 0,
            goodsDiscountRate: 1.0, expDiscountRate: 1.0,
            weapons: emptyWeapons, props: emptyProps,
            lastStoreGoods: emptyGoods, lastStoreRefreshTimes: 0,
            maxDifficultyCompleted: 0, isInCombat: false
        }

        var ok = SaveManager.loadGame(loadedData, mockFM, "/test")
        verify(ok, "loadGame 应返回 true")

        // 验证加载后的字段值
        compare(loadedData.curLevel, 5)
        compare(loadedData.curXp, 50)
        compare(loadedData.maxHp, 100)
        compare(loadedData.curHp, 80)
        compare(loadedData.roleName, "wellRounded")
        compare(loadedData.originWeaponName, "spear")
        compare(loadedData.difficulty, 2)
        compare(loadedData.currentWaveNumber, 5)
        compare(loadedData.materialsNumber, 200)
        compare(loadedData.remainingMaterialsNumber, 150)
        compare(loadedData.isInCombat, true)
        compare(loadedData.weapons.count, 2)
        compare(loadedData.props.count, 1)
        compare(loadedData.lastStoreGoods.count, 1)
    }

    // 空存档加载：应返回 false 且数据不变
    function test_saveLoad_empty() {
        var emptyFM = { saveGameData: function(p,d) { return true; }, loadGameData: function(p) { return {}; } }
        var d = {maxHp: 50, weapons: {count:0, get:function(i){}, clear:function(){}, append:function(){}},
                 props: {count:0, get:function(i){}, clear:function(){}, append:function(){}},
                 lastStoreGoods: {count:0, get:function(i){}, clear:function(){}, append:function(){}} }
        var result = SaveManager.loadGame(d, emptyFM, "/test")
        compare(result, false)
        compare(d.maxHp, 50, "空存档不应覆盖已有字段")
        // 空存档加载时，空对象 {} 不覆盖已有属性值（JS ?? 回退行为）
    }
}
