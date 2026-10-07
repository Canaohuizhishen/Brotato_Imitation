#!/bin/bash
# ============================================================================
# run_test.sh — 运行 Brotato 测试并输出中文结果
# 用法: ./run_test.sh
# ============================================================================

set -e

# bash ≥ 4 检查（declare -A 需要）
if ! declare -A __test 2>/dev/null; then
    echo "❌ 此脚本需要 bash ≥ 4.0；macOS 请 brew install bash"
    exit 1
fi

# 颜色
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

# 切换到项目根目录
cd "$(dirname "$0")"

# 1. 构建测试（如果未构建或需要更新）
#    判定基准取 tests/main.cpp（tst_core 的唯一构建输入）；tests/*.qml 由 -input 运行时发现，不参与构建
if [ ! -x build/tst_core ] || [ build/tst_core -ot tests/main.cpp ]; then
    echo "🔨 构建测试..."
    cmake -B build -DBUILD_TESTS=ON
    # 显式限并行 4（禁止裸 --parallel：Makefile 生成器下 = 无上限 make -j，本机曾因此 OOM）
    cmake --build build --target tst_core --parallel 4
fi

# 确保测试二进制存在
[ -x build/tst_core ] || { echo "❌ build/tst_core 不存在，请先构建"; exit 1; }

# 2. 运行测试，捕获输出
# GUI 测试兜底走 offscreen（与 CI 对齐；本机规则：GUI 探针强制 offscreen，防弹到真实桌面）
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}"
RAW=$(build/tst_core -input tests/ 2>&1 || true)

# 3. 中文映射表（函数名 → 测试要点描述）
declare -A D
D[test_getAllWeapons]="获取全部武器列表及数量"
D[test_getWeapon_spear]="按 objectName 精确查找武器及其完整属性"
D[test_getWeapon_smg]="不同武器的基础属性读取"
D[test_getWeapon_grade3]="指定等级过滤获取武器数据"
D[test_getWeapon_notFound]="查找不存在的武器返回 null"
D[test_getWeapon_deepCopy]="返回值与缓存的隔离性（深拷贝）"
D[test_getProp_bat]="按 objectName 精确查找道具及其效果"
D[test_getProp_wellRounded]="查找高稀有度道具"
D[test_getProp_empty]="空字符串键的边界处理"
D[test_getProp_notFoundFallback]="查找不存在道具返回默认值"
D[test_getAllRoles]="获取全部角色列表"
D[test_getRole_wellRounded]="按 objectName 精确查找角色"
D[test_getUpgradeOption_lung]="按等级+名称精确查找升级选项"
D[test_getUpgradeOption_reflexes]="查找高等级升级选项"
D[test_getUpgradeOption_notFound]="查找不存在的升级选项返回 null"
D[test_waveData]="波次配置数据的完整性与越界处理"
D[test_getWeaponRandomly]="按权重随机抽取指定数量武器"
D[test_getPropRandomly]="按权重随机抽取指定数量道具"
D[test_getUpgradeOptionRandomly]="按权重随机抽取指定数量升级选项"
D[test_renderWeapon_spear]="近战武器面板伤害计算（含近战加成）"
D[test_renderWeapon_spear_melee]="近战伤害加成对武器面板的影响"
D[test_renderWeapon_smg]="远程武器面板伤害计算"
D[test_renderWeapon_smg_damage]="全局百分比伤害加成对面板的影响"
D[test_renderWeapon_null]="非法武器参数安全处理"
D[test_applyEffects_delta]="属性增量/减量的叠加效果"
D[test_applyEffects_conditionLt]="条件触发型效果（低于阈值时生效）"
D[test_applyEffects_setToProp]="将属性值同步为另一属性的值"
D[test_renderTalentText]="天赋文本模板中的变量替换"
D[test_effectValue_concreteDelta]="升级选项显示值取值规则（首个增量效果）"
D[test_upgradeOption_migrationParity]="升级选项迁移对等（16 项 × 4 级 = 旧基数 × 等级）"
D[test_upgradeOption_expandByGrade]="升级选项按等级展开与字段清理"
D[test_upgradeOption_noCrossGradeDuplicates]="升级选项跨等级不重复（30 轮四选一）"
D[test_upgradeDisplayValueMatchesApplied]="升级卡片显示值 = 实际生效值（回归）"
D[test_spatial_init]="空间网格的初始化和空状态"
D[test_spatial_insertQuery]="实体插入与范围查询的一致性"
D[test_spatial_queryOutside]="范围外查询不返回无关实体"
D[test_spatial_remove]="实体移除后不再被查询到"
D[test_spatial_update]="实体位置更新后的查询一致性"
D[test_spatial_multiple]="多实体在网格中共存"
D[test_spatial_clear]="清空网格重置所有状态"
D[test_spatial_bigEntity]="大实体跨越多格子的查询覆盖"
D[test_spatial_reinitRebuilds]="空间网格重复 init 重建（每帧用法锁定）"
D[test_tool_getDistance]="两点间欧几里得距离计算"
D[test_tool_reduceAbs]="数值向零方向的绝对值缩减"
D[test_tool_getQuadrant]="标准角度转象限（四个象限）"
D[test_tool_getQuadrant_boundary]="边界角度（轴线上）的象限判定"
D[test_tool_getQuadrant_negative]="负角度的象限归一化处理"
D[test_tool_approximatelyEqual]="浮点数近似相等的容差比较"
D[test_tool_getMirrorX]="水平镜像坐标计算"
D[test_color_lightenColor_blackWhite]="纯黑/纯白色值在变亮时保持不变"
D[test_color_lightenColor_mid]="中间色按比例变亮"
D[test_color_lightenColor_cap]="变亮不超过纯白色值上限"
D[test_color_getBorderColor]="各稀有度等级的边框颜色映射"
D[test_color_allFormats]="各级别按钮/背景/图片背景色的格式正确性"
D[test_getWeaponGradeCounts]="各等级武器数量统计"
D[test_getPropGradeCounts]="各等级道具数量统计"
D[test_getTheme_valid]="获取有效主题配置（梦幻之地）"
D[test_getTheme_invalid]="越界索引获取主题返回 null"
D[test_getTheme_noData]="未定义主题索引返回 null"
D[test_getAllThemes]="获取全部主题列表及深拷贝隔离"
D[test_weaponsToArray]="武器列表模型转纯数组"
D[test_propsToArray]="道具列表模型转纯数组"
D[test_lastStoreGoodsToArray]="商店历史商品模型转纯数组"
D[test_refreshPrice_wave1]="第一波商店刷新定价"
D[test_refreshPrice_wave10]="第十波商店刷新定价（含递增）"
D[test_resetRefreshTimes]="刷新次数重置对定价的影响"
D[test_refreshShop_noUiDependency]="商店刷新不依赖外部界面元素（作用域回归）"
D[test_getWeapon_nullKey]="null 键查找武器不崩溃"
D[test_getProp_nullKey]="null 键查找道具不崩溃"
D[test_getRole_nullKey]="null 键查找角色不崩溃"
D[test_getUpgradeOption_nullKey]="null 键查找升级选项返回 null"
D[test_getWaveConfig_edge]="越界波次查询返回 null"
D[test_applyEffects_null]="null 参数 applyEffects 不崩溃"
D[test_saveLoad_roundtrip]="存档 JSON 往返：40+ 字段保存→加载一致性"
D[test_saveLoad_empty]="空存档加载返回 false"
D[test_initState]="GameLoop 初始化默认状态"
D[test_registerAndTick]="注册每帧回调并验证触发"
D[test_removePerFrame]="移除回调后不再触发"
D[test_registerWithTarget]="带 target 的回调注册"
D[test_pause]="暂停期间回调不触发"
D[test_reset]="GameLoop.reset() 重置帧计数和时间"
D[test_duplicateRegistrationDeduped]="重复注册同一 target+func 被去重"
D[test_unregisterRemovesAllCopies]="一次注销后不再触发（无重复残留）"
D[test_advanceBuckets_1000ms_3000ms_cadence]="分频桶时间节拍（1000/3000ms 确定性驱动）"
D[test_advanceBuckets_100ms_200ms_cadence]="分频桶时间节拍（100/200ms 确定性驱动）"
D[test_advanceBuckets_frameRateIndependent]="分频桶触发次数与帧率无关（同总时长不同步长）"
D[test_advanceBuckets_resetClears]="reset() 清零分频桶余数"
D[test_bucketFiresInRealLoop]="真实帧循环下 200ms 桶正常触发（接线回归）"
D[test_createText_poolFills]="文本池填充 30 个池对象（常量回归）"
D[test_createText_reusesPool]="池复用期间大小稳定不增长"
D[test_createText_reparentPooledItem]="复用重设 parent（坐标空间随调用方）"
D[test_createText_poolSelfHealsAfterParentDestroy]="父销毁后池自愈：失效槽位重建且不抛错"
D[test_createText_multiple]="连续多次 createText 不崩溃"
D[test_createText_defaultDuration]="默认 duration 参数兼容"
D[test_createText_qmlEscape]="含引号和换行的文本不崩溃"
D[test_createText_releaseResetsPool]="release 清空池并支持惰性重建"
D[test_createText_releaseWithDeadRefs]="死引用槽位下 release 不中断并完整复位（守卫回归）"
D[test_particlePool_releaseReinit]="粒子池 release 清空与 spawn 惰性重建"
D[test_particlePool_releaseWithDeadRefs]="死引用槽位下粒子池 release 不中断（守卫回归）"
D[test_bulletHitPlayer_noDoubleHitInDestroyWindow]="子弹命中玩家后异步删除窗口内不重复扣血（双击回归）"
D[test_bulletHitMonster_noDoubleHitInDestroyWindow]="子弹命中怪物后异步删除窗口内不重复结算（双击回归）"
D[test_aabb_fullOverlap]="完全重叠的 AABB 碰撞检测"
D[test_aabb_partialOverlap]="部分重叠的 AABB 碰撞检测"
D[test_aabb_aContainsB]="大包围盒内含小包围盒的碰撞检测"
D[test_aabb_bContainsA]="小包围盒内嵌大包围盒的碰撞检测"
D[test_aabb_noOverlapX]="X 方向分离无碰撞"
D[test_aabb_noOverlapY]="Y 方向分离无碰撞"
D[test_aabb_edgeTouchRight]="右边缘接触不算碰撞"
D[test_aabb_edgeTouchLeft]="左边缘接触不算碰撞"
D[test_aabb_edgeTouchTop]="上边缘接触不算碰撞"
D[test_aabb_edgeTouchBottom]="下边缘接触不算碰撞"
D[test_aabb_zeroSize]="零尺寸对象不碰撞"
D[test_aabb_empty]="两个零尺寸同位置不碰撞"
D[test_damageReduction_zero]="护甲为 0 时减伤为 0"
D[test_damageReduction_15]="护甲 15 时减伤 50%"
D[test_damageReduction_60]="护甲 60 时减伤约 80%"
D[test_damageReduction_large]="护甲极大时减伤趋近 100%"
D[test_damageReduction_negative]="负护甲造成增伤"
D[test_damageApplication_noArmor]="无护甲时满额受伤"
D[test_damageApplication_armor15]="护甲 15 时伤害减半"
D[test_damageApplication_smallDmg]="小伤害经减伤后 ceil 仍为 1"
D[test_damageApplication_negativeArmor]="负护甲使伤害增加"
D[test_monsterDamage_wave1]="第 1 波怪物基础伤害"
D[test_monsterDamage_wave10]="第 10 波怪物伤害随波次增长"
D[test_monsterDamage_modifier200]="200% 伤害倍率下怪物伤害翻倍"
D[test_monsterHp_wave1]="第 1 波怪物基础血量"
D[test_monsterHp_wave20]="第 20 波怪物血量随波次增长"
D[test_monsterSpeed]="怪物速度受倍率和属性叠加影响"
D[test_burnTotalDamage]="灼烧 DOT 总伤害 = 每跳伤害 × 跳数"
D[test_renderWeapon_flamethrower]="火焰喷射器基础面板（元素远程，伤害 4）"
D[test_renderWeapon_flamethrower_elemental]="元素加成×1.0 计入火焰喷射器面板"
D[test_renderWeapon_flamethrower_grade4]="四级火焰喷射器（倍率 2.0＋增伤 10%，取整）"
D[test_renderWeapon_iceCone]="冰锥基础面板（元素远程，伤害 10）"
D[test_renderWeapon_iceCone_elemental]="元素加成×1.0 计入冰锥面板"
D[test_applyEffects_enemySpeed]="敌方属性增量（速度/数量/树）的叠加"
D[test_applyEffects_burning]="灼烧速率与百分比属性增量的叠加"
D[test_applyEffects_penetrateRebound]="穿透/反弹/穿透伤害增量的叠加"
D[test_push_sets_visible_z_top]="push 置可见、z=500，成为栈顶"
D[test_push_order_onEnter_before_visible]="onEnter 先于 visible=true 执行（钩子次序）"
D[test_push_duplicate_ignored]="重复 push 同一页面被忽略"
D[test_push_unregistered_ignored]="push 未注册页面被忽略"
D[test_pop_hides_top_and_reveals_lower]="pop 隐藏栈顶并揭开下层页面"
D[test_push_pop_not_write_lower_visible]="栈操作不写下层页面 visible（核心不变量）"
D[test_replace]="replace = pop + push，z 序号重算"
D[test_clear_to_base]="clearToBase 清栈并触发全部 onExit"
D[test_z_recalc_after_pop]="pop 后全栈 z 按序号重算"
D[test_no_hooks_page_ok]="无钩子页面 push/pop 正常工作"
D[test_pop_empty_warns_no_crash]="空栈 pop 仅告警不崩溃"
D[test_resetSpawnPhase_clearsOnly3000Bucket]="出怪桶相位复位：仅清 3000ms 桶（不瞬刷、不扰动其他分频）"
D[test_resetForWave_resetsRuntimeCounters]="出怪运行时计数按波配置复位且幂等（重试波号不变）"
D[test_rollbackWaveGains_exactAndPoolSnapshot]="重试收益回退：材料/经验精确回退＋余料池还原波初快照"
D[test_rollbackWaveGains_bulkWriteFairWalk]="批量跨级公平走账：单次大额经验逐级扣除且回退精确互逆"
D[test_rollbackWaveGains_levelDemotionInverse]="跨级升级回退互逆：等级/经验/最大生命精确还原"
D[test_rollbackWaveGains_idempotent]="重试收益回退幂等：重复调用不再改变状态"

# 4. 分组分类
declare -A GROUP
GROUP[test_getAllWeapons]="📦 DataLoader"
GROUP[test_getWeapon_spear]="📦 DataLoader"
GROUP[test_getWeapon_smg]="📦 DataLoader"
GROUP[test_getWeapon_grade3]="📦 DataLoader"
GROUP[test_getWeapon_notFound]="📦 DataLoader"
GROUP[test_getWeapon_deepCopy]="📦 DataLoader"
GROUP[test_getProp_bat]="📦 DataLoader"
GROUP[test_getProp_wellRounded]="📦 DataLoader"
GROUP[test_getProp_empty]="📦 DataLoader"
GROUP[test_getProp_notFoundFallback]="📦 DataLoader"
GROUP[test_getAllRoles]="📦 DataLoader"
GROUP[test_getRole_wellRounded]="📦 DataLoader"
GROUP[test_getUpgradeOption_lung]="📦 DataLoader"
GROUP[test_getUpgradeOption_reflexes]="📦 DataLoader"
GROUP[test_getUpgradeOption_notFound]="📦 DataLoader"
GROUP[test_waveData]="📦 DataLoader"
GROUP[test_getWeaponRandomly]="📦 DataLoader"
GROUP[test_getPropRandomly]="📦 DataLoader"
GROUP[test_getUpgradeOptionRandomly]="📦 DataLoader"
GROUP[test_renderWeapon_spear]="📦 DataLoader"
GROUP[test_renderWeapon_spear_melee]="📦 DataLoader"
GROUP[test_renderWeapon_smg]="📦 DataLoader"
GROUP[test_renderWeapon_smg_damage]="📦 DataLoader"
GROUP[test_renderWeapon_null]="📦 DataLoader"
GROUP[test_applyEffects_delta]="📦 DataLoader"
GROUP[test_applyEffects_conditionLt]="📦 DataLoader"
GROUP[test_applyEffects_setToProp]="📦 DataLoader"
GROUP[test_renderTalentText]="📦 DataLoader"
GROUP[test_effectValue_concreteDelta]="📦 DataLoader"
GROUP[test_upgradeOption_migrationParity]="📦 DataLoader"
GROUP[test_upgradeOption_expandByGrade]="📦 DataLoader"
GROUP[test_upgradeOption_noCrossGradeDuplicates]="📦 DataLoader"
GROUP[test_upgradeDisplayValueMatchesApplied]="📦 DataLoader"
GROUP[test_spatial_init]="🗺️ SpatialGrid"
GROUP[test_spatial_insertQuery]="🗺️ SpatialGrid"
GROUP[test_spatial_queryOutside]="🗺️ SpatialGrid"
GROUP[test_spatial_remove]="🗺️ SpatialGrid"
GROUP[test_spatial_update]="🗺️ SpatialGrid"
GROUP[test_spatial_multiple]="🗺️ SpatialGrid"
GROUP[test_spatial_clear]="🗺️ SpatialGrid"
GROUP[test_spatial_bigEntity]="🗺️ SpatialGrid"
GROUP[test_spatial_reinitRebuilds]="🗺️ SpatialGrid"
GROUP[test_tool_getDistance]="🔧 Tool"
GROUP[test_tool_reduceAbs]="🔧 Tool"
GROUP[test_tool_getQuadrant]="🔧 Tool"
GROUP[test_tool_getQuadrant_boundary]="🔧 Tool"
GROUP[test_tool_getQuadrant_negative]="🔧 Tool"
GROUP[test_tool_approximatelyEqual]="🔧 Tool"
GROUP[test_tool_getMirrorX]="🔧 Tool"
GROUP[test_getWeaponGradeCounts]="📦 DataLoader"
GROUP[test_getPropGradeCounts]="📦 DataLoader"
GROUP[test_getTheme_valid]="📦 DataLoader"
GROUP[test_getTheme_invalid]="📦 DataLoader"
GROUP[test_getTheme_noData]="📦 DataLoader"
GROUP[test_getAllThemes]="📦 DataLoader"
GROUP[test_weaponsToArray]="💾 SaveManager"
GROUP[test_propsToArray]="💾 SaveManager"
GROUP[test_lastStoreGoodsToArray]="💾 SaveManager"
GROUP[test_refreshPrice_wave1]="🏪 Shop"
GROUP[test_refreshPrice_wave10]="🏪 Shop"
GROUP[test_resetRefreshTimes]="🏪 Shop"
GROUP[test_refreshShop_noUiDependency]="🏪 Shop"
GROUP[test_getWeapon_nullKey]="📦 DataLoader"
GROUP[test_getProp_nullKey]="📦 DataLoader"
GROUP[test_getRole_nullKey]="📦 DataLoader"
GROUP[test_getUpgradeOption_nullKey]="📦 DataLoader"
GROUP[test_getWaveConfig_edge]="📦 DataLoader"
GROUP[test_applyEffects_null]="📦 DataLoader"
GROUP[test_color_lightenColor_blackWhite]="🎨 Color"
GROUP[test_saveLoad_roundtrip]="💾 SaveManager"
GROUP[test_saveLoad_empty]="💾 SaveManager"
GROUP[test_initState]="🎮 GameLoop"
GROUP[test_registerAndTick]="🎮 GameLoop"
GROUP[test_removePerFrame]="🎮 GameLoop"
GROUP[test_registerWithTarget]="🎮 GameLoop"
GROUP[test_pause]="🎮 GameLoop"
GROUP[test_reset]="🎮 GameLoop"
GROUP[test_duplicateRegistrationDeduped]="🎮 GameLoop"
GROUP[test_unregisterRemovesAllCopies]="🎮 GameLoop"
GROUP[test_advanceBuckets_1000ms_3000ms_cadence]="🎮 GameLoop"
GROUP[test_advanceBuckets_100ms_200ms_cadence]="🎮 GameLoop"
GROUP[test_advanceBuckets_frameRateIndependent]="🎮 GameLoop"
GROUP[test_advanceBuckets_resetClears]="🎮 GameLoop"
GROUP[test_bucketFiresInRealLoop]="🎮 GameLoop"
GROUP[test_createText_poolFills]="📝 createText"
GROUP[test_createText_reusesPool]="📝 createText"
GROUP[test_createText_reparentPooledItem]="📝 createText"
GROUP[test_createText_poolSelfHealsAfterParentDestroy]="📝 createText"
GROUP[test_createText_multiple]="📝 createText"
GROUP[test_createText_defaultDuration]="📝 createText"
GROUP[test_createText_qmlEscape]="📝 createText"
GROUP[test_createText_releaseResetsPool]="📝 createText"
GROUP[test_createText_releaseWithDeadRefs]="📝 createText"
GROUP[test_particlePool_releaseReinit]="🧪 ParticlePool"
GROUP[test_particlePool_releaseWithDeadRefs]="🧪 ParticlePool"
GROUP[test_bulletHitPlayer_noDoubleHitInDestroyWindow]="🎯 子弹命中"
GROUP[test_bulletHitMonster_noDoubleHitInDestroyWindow]="🎯 子弹命中"
GROUP[test_color_lightenColor_mid]="🎨 Color"
GROUP[test_color_lightenColor_cap]="🎨 Color"
GROUP[test_color_getBorderColor]="🎨 Color"
GROUP[test_color_allFormats]="🎨 Color"
GROUP[test_aabb_fullOverlap]="💥 碰撞检测"
GROUP[test_aabb_partialOverlap]="💥 碰撞检测"
GROUP[test_aabb_aContainsB]="💥 碰撞检测"
GROUP[test_aabb_bContainsA]="💥 碰撞检测"
GROUP[test_aabb_noOverlapX]="💥 碰撞检测"
GROUP[test_aabb_noOverlapY]="💥 碰撞检测"
GROUP[test_aabb_edgeTouchRight]="💥 碰撞检测"
GROUP[test_aabb_edgeTouchLeft]="💥 碰撞检测"
GROUP[test_aabb_edgeTouchTop]="💥 碰撞检测"
GROUP[test_aabb_edgeTouchBottom]="💥 碰撞检测"
GROUP[test_aabb_zeroSize]="💥 碰撞检测"
GROUP[test_aabb_empty]="💥 碰撞检测"
GROUP[test_damageReduction_zero]="🛡️ 伤害计算"
GROUP[test_damageReduction_15]="🛡️ 伤害计算"
GROUP[test_damageReduction_60]="🛡️ 伤害计算"
GROUP[test_damageReduction_large]="🛡️ 伤害计算"
GROUP[test_damageReduction_negative]="🛡️ 伤害计算"
GROUP[test_damageApplication_noArmor]="🛡️ 伤害计算"
GROUP[test_damageApplication_armor15]="🛡️ 伤害计算"
GROUP[test_damageApplication_smallDmg]="🛡️ 伤害计算"
GROUP[test_damageApplication_negativeArmor]="🛡️ 伤害计算"
GROUP[test_monsterDamage_wave1]="👾 怪物属性"
GROUP[test_monsterDamage_wave10]="👾 怪物属性"
GROUP[test_monsterDamage_modifier200]="👾 怪物属性"
GROUP[test_monsterHp_wave1]="👾 怪物属性"
GROUP[test_monsterHp_wave20]="👾 怪物属性"
GROUP[test_monsterSpeed]="👾 怪物属性"
GROUP[test_burnTotalDamage]="🔥 灼烧 DOT"
GROUP[test_renderWeapon_flamethrower]="📦 DataLoader"
GROUP[test_renderWeapon_flamethrower_elemental]="📦 DataLoader"
GROUP[test_renderWeapon_flamethrower_grade4]="📦 DataLoader"
GROUP[test_renderWeapon_iceCone]="📦 DataLoader"
GROUP[test_renderWeapon_iceCone_elemental]="📦 DataLoader"
GROUP[test_applyEffects_enemySpeed]="📦 DataLoader"
GROUP[test_applyEffects_burning]="📦 DataLoader"
GROUP[test_applyEffects_penetrateRebound]="📦 DataLoader"
GROUP[test_push_sets_visible_z_top]="🧭 PageManager"
GROUP[test_push_order_onEnter_before_visible]="🧭 PageManager"
GROUP[test_push_duplicate_ignored]="🧭 PageManager"
GROUP[test_push_unregistered_ignored]="🧭 PageManager"
GROUP[test_pop_hides_top_and_reveals_lower]="🧭 PageManager"
GROUP[test_push_pop_not_write_lower_visible]="🧭 PageManager"
GROUP[test_replace]="🧭 PageManager"
GROUP[test_clear_to_base]="🧭 PageManager"
GROUP[test_z_recalc_after_pop]="🧭 PageManager"
GROUP[test_no_hooks_page_ok]="🧭 PageManager"
GROUP[test_pop_empty_warns_no_crash]="🧭 PageManager"
GROUP[test_resetSpawnPhase_clearsOnly3000Bucket]="🎮 GameLoop"
GROUP[test_resetForWave_resetsRuntimeCounters]="🔁 死亡重试"
GROUP[test_rollbackWaveGains_exactAndPoolSnapshot]="🔁 死亡重试"
GROUP[test_rollbackWaveGains_bulkWriteFairWalk]="🔁 死亡重试"
GROUP[test_rollbackWaveGains_levelDemotionInverse]="🔁 死亡重试"
GROUP[test_rollbackWaveGains_idempotent]="🔁 死亡重试"

# 5. 解析并输出
echo ""
echo "🧪 Brotato 核心逻辑测试"
echo "═══════════════════════"

last_group=""
passed=0
failed=0

while IFS= read -r line; do
    # 提取 PASS/FAIL 行中的函数名
    if [[ $line =~ ^(PASS|FAIL!)\ +:\ tst_core::([a-zA-Z]+)::([a-zA-Z0-9_]+)\(\) ]]; then
        status="${BASH_REMATCH[1]}"
        fname="${BASH_REMATCH[3]}"
        desc="${D[$fname]:-$fname}"
        grp="${GROUP[$fname]:-}"

        # 打印分组标题
        if [ -n "$grp" ] && [ "$grp" != "$last_group" ]; then
            echo ""
            echo "$grp"
            last_group="$grp"
        fi

        if [ "$status" = "PASS" ]; then
            echo -e "  ${GREEN}✅${RESET} $desc"
            passed=$((passed+1))
        else
            echo -e "  ${RED}❌${RESET} $desc"
            failed=$((failed+1))
        fi
    fi

    # 提取汇总（仅用于展示，不自覆盖计数）
    if [[ $line =~ ^Totals:\ ([0-9]+)\ passed,\ ([0-9]+)\ failed ]]; then
        :
    fi
done <<< "$RAW"

echo ""
echo "═══════════════════════"
if [ "$failed" -eq 0 ]; then
    echo -e "${GREEN}🎉 全部通过！${passed} 个测试${RESET}"
else
    echo -e "${RED}💥 ${failed} 个失败，${passed} 个通过${RESET}"
fi
# 守卫：没有任何测试输出说明二进制可能崩溃了
if [ "$passed" -eq 0 ] && [ "$failed" -eq 0 ]; then
    echo -e "${RED}⚠️ 未检测到任何测试输出（二进制未运行？）${RESET}"
    exit 1
fi

echo ""

# 如果有失败行，输出详细信息
if [ "$failed" -gt 0 ]; then
    echo "--- 失败详情 ---"
    while IFS= read -r line; do
        if [[ $line =~ ^FAIL! ]]; then
            echo "$line"
        fi
        if [[ $line == "   Loc:"* ]]; then
            echo "$line"
        fi
    done <<< "$RAW"
    echo ""
fi

exit $failed
