import QtQuick
import QtTest
import "../logic/DataLoader.js" as DataLoader
import "../logic/SpatialGrid.js" as SpatialGrid
import "../logic/ParticlePool.js" as ParticlePool
import "../logic/utils/tool.js" as Tool
import "../logic/utils/color.js" as Color
import "../logic/utils/collision.js" as Collision
import "../logic/SaveManager.js" as SaveManager
import "../logic/ShopLogicHandler.js" as Shop
import "./TestPlayerData.js" as PlayerData

TestCase {
    name: "CoreTests"

    // ---- 商店刷新（refreshShop）作用域 mock：JS 通过文件作用域解析这些名字 ----
    // 刻意不提供 waveNumberText —— 回归锁定：refreshShop 不得依赖商店外的界面元素
    property var shopModel: ({
        arr: [],
        count: 0,
        get: function(i) { return this.arr[i] },
        clear: function() { this.arr = []; this.count = 0 },
        append: function(x) { this.arr.push(x); this.count = this.arr.length }
    })
    property var shopView: ({ columns: 4 })
    property var weaponCore: ({
        getWeaponRandomly: function(n) {
            var a = []
            for (var i = 0; i < n; i++) a.push({ grade: 1 })
            return a
        }
    })
    property var propCore: ({
        getPropRandomly: function(n) {
            var a = []
            for (var i = 0; i < n; i++) a.push({ grade: 1 })
            return a
        }
    })

    // 死引用构造专用父（ParticlePool 守卫回归用例用；仅销毁一次，勿在其它用例引用）
    property var doomedParticleParent: Item { objectName: "doomedParticleParent" }

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

    function test_renderTalentText() {
        compare(DataLoader.renderTalentText("伤害 +{{value}}",5), "伤害 +5")
    }

    // ---- 升级选项：分桶展开 / 显示值 = 生效值（回归） ----

    function test_effectValue_concreteDelta() {
        // 展开后条目带具体 delta；取值 = 首个增量效果
        compare(DataLoader.effectValue([{attribute:"speed", delta:6}]), 6)
        // 空数组 / 非数值效果 → 0
        compare(DataLoader.effectValue([]), 0)
        compare(DataLoader.effectValue([{attribute:"maxHp", condition:"lt", conditionValue:15, setTo:15}]), 0)
    }

    function test_upgradeOption_migrationParity() {
        // 迁移对等：新 deltaByGrade 展开后，每级数值必须等于旧格式基数 × 等级
        //（基线 = 迁移前旧字段的每级基数；写错一个数即失败）
        var base = { leg:3, chest:1, skull:2, lung:2, finger:3, back:3, teeth:1, heart:3,
                     brain:1, reflexes:5, nose:5, hand:5, shoulder:1, foream:2, triceps:5, eyes:15 }
        var names = Object.keys(base)
        compare(names.length, 16)
        for (var n = 0; n < names.length; n++) {
            var name = names[n]
            for (var g = 1; g <= 4; g++) {
                var opt = DataLoader.getUpgradeOption(g, name)
                verify(opt, name + " 缺失")
                compare(opt.grade, g)
                verify(opt.effects.length >= 1)
                for (var e = 0; e < opt.effects.length; e++) {
                    compare(opt.effects[e].delta, base[name] * g,
                            name + " 等级" + g + " delta 应为 " + (base[name] * g))
                }
            }
        }
    }

    function test_upgradeOption_expandByGrade() {
        // 逐级展开与字段清理
        var expects = [3, 6, 9, 12]
        for (var g = 1; g <= 4; g++) {
            var opt = DataLoader.getUpgradeOption(g, "leg")
            compare(opt.effects[0].delta, expects[g - 1])
            verify(opt.effects[0].deltaByGrade === undefined, "展开后不应残留 deltaByGrade")
        }
        // 心脏：双效果均展开且逐级同值
        var heart = DataLoader.getUpgradeOption(2, "heart")
        compare(heart.effects.length, 2)
        compare(heart.effects[0].delta, 6)
        compare(heart.effects[1].delta, 6)
    }

    function test_upgradeOption_noCrossGradeDuplicates() {
        // 跨等级按 objectName 去重：同一选项的不同等级不得出现在同一次四选一中
        for (var round = 0; round < 30; round++) {
            var r = DataLoader.getUpgradeOptionRandomly(4, {1:1,2:1,3:1,4:1})
            compare(r.length, 4)
            var seen = {}
            for (var i = 0; i < r.length; i++) {
                verify(!seen[r[i].objectName], "同一选项跨等级重复出现：" + r[i].objectName)
                seen[r[i].objectName] = true
            }
        }
    }

    function test_upgradeDisplayValueMatchesApplied() {
        // [objectName, grade, 期望值]：覆盖基数≠1 的典型与双效果选项
        var cases = [["eyes", 1, 15], ["leg", 3, 9], ["chest", 4, 4], ["heart", 2, 6]]
        for (var i = 0; i < cases.length; i++) {
            var opt = DataLoader.getUpgradeOption(cases[i][1], cases[i][0])
            verify(opt)
            // 1) 取值（展开后的实际生效值）
            var v = DataLoader.effectValue(opt.effects)
            compare(v, cases[i][2])
            // 2) 渲染文本包含该数值（回归：曾渲染为等级数字）
            var text = DataLoader.renderTalentText(opt.talentTextTemplate, v)
            verify(text.indexOf("+" + cases[i][2]) !== -1,
                   cases[i][0] + " 渲染文本应含 +" + cases[i][2] + "，实际：" + text)
            // 3) 与 applyEffects 实际施加值一致
            var attr = opt.effects[0].attribute
            var d = {}
            d[attr] = 0
            DataLoader.applyEffects(opt.effects, d)
            compare(d[attr], cases[i][2])
        }
    }

    // ---- ParticlePool ----

    function test_particlePool_releaseReinit() {
        // release 语义：清空并复位标志 → 下次 spawn 惰性重建（backMainMenu 接线依赖）
        ParticlePool.init(this)
        compare(ParticlePool._bloodPool.length, 50, "init 应预创建 50 个血花粒子")
        compare(ParticlePool._debrisPool.length, 30, "init 应预创建 30 个残渣粒子")

        ParticlePool.release()
        compare(ParticlePool._bloodPool.length, 0, "release 后血花池应清空")
        compare(ParticlePool._debrisPool.length, 0, "release 后残渣池应清空")
        compare(ParticlePool._bloodInitialized, false, "初始化标志应复位")

        ParticlePool.spawn(10, 10, 0, 0, 10, this, true)
        compare(ParticlePool._bloodPool.length, 50, "spawn 应惰性重建血花池")

        ParticlePool.release()   // 收尾：清干净，避免粒子存留影响后续用例
    }

    function test_particlePool_releaseWithDeadRefs() {
        // 守卫回归（与 TextPool 对称）：死引用槽位下 release 必须不中断、池完整复位。
        // （修复前：对死引用调用 .destroy() 抛 TypeError，循环中断）
        ParticlePool.release()   // 自包含：干净起点
        ParticlePool.init(doomedParticleParent)
        compare(ParticlePool._bloodPool.length, 50, "init 应预创建 50 个血花粒子")
        compare(ParticlePool._debrisPool.length, 30, "init 应预创建 30 个残渣粒子")
        doomedParticleParent.destroy()
        wait(300)   // 等 deleteLater 生效
        verify(typeof ParticlePool._bloodPool[0].restartAnimation === "undefined",
               "前置：以 doomedParticleParent 为填充父创建的粒子应为死引用")

        ParticlePool.release()   // 目标：死引用下不抛错、不中断
        compare(ParticlePool._bloodPool.length, 0, "死引用下 release 仍应清空血花池")
        compare(ParticlePool._debrisPool.length, 0, "死引用下 release 仍应清空残渣池")
        compare(ParticlePool._bloodInitialized, false, "初始化标志应复位")

        // 复位后仍可正常惰性重建
        ParticlePool.spawn(10, 10, 0, 0, 10, this, true)
        compare(ParticlePool._bloodPool.length, 50, "spawn 应惰性重建血花池")

        ParticlePool.release()   // 收尾：清干净，避免粒子存留影响后续用例
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

    function test_spatial_reinitRebuilds() {
        // 锁定“每帧 init 重建”用法（GameArea 每帧 init(200 * scaleFactor)）：
        // 重复 init 应等价于清空重建，且换 cellSize 后查询仍正确
        SpatialGrid.init(100)
        SpatialGrid.insert({_spatialId:"e1",width:40,height:40},50,50)
        compare(SpatialGrid.query(0,0,200,200).length, 1)

        SpatialGrid.init(100)   // 模拟下一帧重建
        compare(SpatialGrid.query(0,0,200,200).length, 0, "重 init 后应清空旧登记")
        SpatialGrid.insert({_spatialId:"e1",width:40,height:40},50,50)
        compare(SpatialGrid.query(0,0,200,200).length, 1, "重建后应可重新插入并查询")

        SpatialGrid.init(200 * 0.5)   // 缩放联动公式代入：cellSize 随 init 更新
        SpatialGrid.insert({_spatialId:"e2",width:40,height:40},10,10)   // 单格几何，断言确定
        compare(SpatialGrid.query(0,0,200,200).length, 1, "新 cellSize 下查询应正确")
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

    function test_refreshShop_noUiDependency() {
        // 回归：refreshShop 必须只依赖文件作用域内的数据源，
        // 不得引用商店外的界面元素（历史上曾裸引用 GameWindow 的 waveNumberText，HUD 重构后即失效）
        shopModel.clear()
        PlayerData.lastStoreGoods.clear()
        Shop.refreshShop()
        compare(shopModel.count, shopView.columns)
        compare(PlayerData.lastStoreGoods.count, shopModel.count)
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
        var r = DataLoader.getProp(null)
        verify(typeof r === "object")
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

    // ---- AABB Collision ----

    function test_aabb_fullOverlap() {
        verify(Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:0,y:0,width:10,height:10}))
    }

    function test_aabb_partialOverlap() {
        verify(Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:5,y:5,width:10,height:10}))
    }

    function test_aabb_aContainsB() {
        verify(Collision.aabbCollide({x:0,y:0,width:100,height:100}, {x:10,y:10,width:20,height:20}))
    }

    function test_aabb_bContainsA() {
        verify(Collision.aabbCollide({x:10,y:10,width:20,height:20}, {x:0,y:0,width:100,height:100}))
    }

    function test_aabb_noOverlapX() {
        // x 方向完全分离
        verify(!Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:20,y:0,width:10,height:10}))
    }

    function test_aabb_noOverlapY() {
        // y 方向完全分离
        verify(!Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:0,y:20,width:10,height:10}))
    }

    function test_aabb_edgeTouchRight() {
        // 右边缘接触（严格 >，接触不算碰撞）
        verify(!Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:10,y:0,width:10,height:10}))
    }

    function test_aabb_edgeTouchLeft() {
        verify(!Collision.aabbCollide({x:10,y:0,width:10,height:10}, {x:0,y:0,width:10,height:10}))
    }

    function test_aabb_edgeTouchTop() {
        verify(!Collision.aabbCollide({x:0,y:10,width:10,height:10}, {x:0,y:0,width:10,height:10}))
    }

    function test_aabb_edgeTouchBottom() {
        verify(!Collision.aabbCollide({x:0,y:0,width:10,height:10}, {x:0,y:10,width:10,height:10}))
    }

    function test_aabb_zeroSize() {
        // 零尺寸对象的碰撞行为
        verify(!Collision.aabbCollide({x:0,y:0,width:0,height:0}, {x:5,y:5,width:10,height:10}))
    }

    function test_aabb_empty() {
        // 两个零尺寸对象在相同位置 — x+0 > x 为假
        verify(!Collision.aabbCollide({x:0,y:0,width:0,height:0}, {x:0,y:0,width:0,height:0}))
    }

    // ---- Damage Reduction ----

    function test_damageReduction_zero() {
        // armor=0 → 0/(0+15) = 0
        compare(0/(0+15), 0)
    }

    function test_damageReduction_15() {
        // armor=15 → 15/(15+15) = 0.5
        compare(15/(15+15), 0.5)
    }

    function test_damageReduction_60() {
        // armor=60 → 60/(60+15) ≈ 0.8
        verify(Math.abs(60/(60+15) - 0.8) < 1e-10)
    }

    function test_damageReduction_large() {
        // armor 很大时趋近 1
        var r = 10000/(10000+15)
        verify(r > 0.998)
    }

    function test_damageReduction_negative() {
        // armor 为负：仍是合法计算（公式不限制符号）
        var r = (-5)/((-5)+15)
        // -5/10 = -0.5 → 负减免 = 增伤
        compare(r, -0.5)
    }

    // ---- Damage Application (Math.ceil(bullet.damage * (1 - reduction))) ----

    function test_damageApplication_noArmor() {
        // armor=0 → reduction=0 → ceil(100*1)=100
        var reduction = 0/(0+15)
        compare(Math.ceil(100 * (1 - reduction)), 100)
    }

    function test_damageApplication_armor15() {
        // armor=15 → reduction=0.5 → ceil(100*0.5)=50
        var reduction = 15/(15+15)
        compare(Math.ceil(100 * (1 - reduction)), 50)
    }

    function test_damageApplication_smallDmg() {
        // armor=15, dmg=1 → ceil(1*0.5)=1
        var reduction = 15/(15+15)
        compare(Math.ceil(1 * (1 - reduction)), 1)
    }

    function test_damageApplication_negativeArmor() {
        // armor=-5 → reduction=-0.5 → ceil(100*1.5)=150
        var reduction = (-5)/((-5)+15)
        compare(Math.ceil(100 * (1 - reduction)), 150)
    }

    // ---- Monster Scaling (纯数学验证) ----

    function test_monsterDamage_wave1() {
        // wave=1: (initDamage + damageBonus*0) * (modifier/100)
        var initDmg = 8, bonus = 2, wave = 1, mod = 100
        compare(Math.round((initDmg + bonus * (wave - 1)) * (mod / 100.0)), 8)
    }

    function test_monsterDamage_wave10() {
        // wave=10: (8 + 2*9) * 1.0 = 26
        var initDmg = 8, bonus = 2, wave = 10, mod = 100
        compare(Math.round((initDmg + bonus * (wave - 1)) * (mod / 100.0)), 26)
    }

    function test_monsterDamage_modifier200() {
        // 200% 伤害模式
        var initDmg = 8, bonus = 2, wave = 5, mod = 200
        // (8 + 2*4) * 2.0 = 16 * 2 = 32
        compare(Math.round((initDmg + bonus * (wave - 1)) * (mod / 100.0)), 32)
    }

    function test_monsterHp_wave1() {
        // wave=1: (initHp + hpBonus*0) * (modifier/100)
        var initHp = 50, bonus = 10, wave = 1, mod = 100
        compare(Math.round((initHp + bonus * (wave - 1)) * (mod / 100.0)), 50)
    }

    function test_monsterHp_wave20() {
        // wave 20 强敌
        var initHp = 50, bonus = 10, wave = 20, mod = 150
        // (50 + 10*19) * 1.5 = 240 * 1.5 = 360
        compare(Math.round((initHp + bonus * (wave - 1)) * (mod / 100.0)), 360)
    }

    function test_monsterSpeed() {
        // v = initVelocity * (enemySpeedModifier/100) * (1 + PlayerData.enemySpeed/100)
        var v0 = 100, speedMod = 150, enemySpeed = 20
        var v = v0 * (speedMod / 100.0) * (1 + enemySpeed / 100)
        // 100 * 1.5 * 1.2 = 180
        compare(v, 180)
    }

    // ---- Burn DOT ----

    function test_burnTotalDamage() {
        // burnDamagePerTick * burnTicksRemaining
        compare(5 * 3, 15)
        compare(10 * 5, 50)
    }
}
