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
if [ ! -f build/tst_core ] || [ build/tst_core -ot tests/tst_core.qml ]; then
    echo "🔨 构建测试..."
    cmake -B build -DBUILD_TESTS=ON
    cmake --build build --target tst_core --parallel
fi

# 确保测试二进制存在
[ -x build/tst_core ] || { echo "❌ build/tst_core 不存在，请先构建"; exit 1; }

# 2. 运行测试，捕获输出
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
D[test_getMonster_charger]="查找怪物并验证血量属性完整性"
D[test_getMonster_notFound]="查找不存在的怪物返回 null"
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
D[test_applyEffects_deltaFromGrade]="基于等级的属性增量计算"
D[test_renderTalentText]="天赋文本模板中的变量替换"
D[test_spatial_init]="空间网格的初始化和空状态"
D[test_spatial_insertQuery]="实体插入与范围查询的一致性"
D[test_spatial_queryOutside]="范围外查询不返回无关实体"
D[test_spatial_remove]="实体移除后不再被查询到"
D[test_spatial_update]="实体位置更新后的查询一致性"
D[test_spatial_multiple]="多实体在网格中共存"
D[test_spatial_clear]="清空网格重置所有状态"
D[test_spatial_bigEntity]="大实体跨越多格子的查询覆盖"
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
D[test_getWeapon_nullKey]="null 键查找武器不崩溃"
D[test_getProp_nullKey]="null 键查找道具不崩溃"
D[test_getMonster_nullKey]="null 键查找怪物返回 null"
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
D[test_createText_doesNotCrash]="createText 基本调用不崩溃"
D[test_createText_addsChild]="createText 向 parent 添加子项"
D[test_createText_multiple]="连续多次 createText 不崩溃"
D[test_createText_defaultDuration]="默认 duration 参数兼容"
D[test_createText_qmlEscape]="含引号和换行的文本不崩溃"
D[test_create_invalidPath]="非法路径创建组件返回 null"
D[test_createWithBindings_invalidPath]="非法路径 createWithBindings 返回 null"
D[test_create_noProperties]="null properties 参数不崩溃"

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
GROUP[test_getMonster_charger]="📦 DataLoader"
GROUP[test_getMonster_notFound]="📦 DataLoader"
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
GROUP[test_applyEffects_deltaFromGrade]="📦 DataLoader"
GROUP[test_renderTalentText]="📦 DataLoader"
GROUP[test_spatial_init]="🗺️ SpatialGrid"
GROUP[test_spatial_insertQuery]="🗺️ SpatialGrid"
GROUP[test_spatial_queryOutside]="🗺️ SpatialGrid"
GROUP[test_spatial_remove]="🗺️ SpatialGrid"
GROUP[test_spatial_update]="🗺️ SpatialGrid"
GROUP[test_spatial_multiple]="🗺️ SpatialGrid"
GROUP[test_spatial_clear]="🗺️ SpatialGrid"
GROUP[test_spatial_bigEntity]="🗺️ SpatialGrid"
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
GROUP[test_getWeapon_nullKey]="📦 DataLoader"
GROUP[test_getProp_nullKey]="📦 DataLoader"
GROUP[test_getMonster_nullKey]="📦 DataLoader"
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
GROUP[test_createText_doesNotCrash]="📝 createText"
GROUP[test_createText_addsChild]="📝 createText"
GROUP[test_createText_multiple]="📝 createText"
GROUP[test_createText_defaultDuration]="📝 createText"
GROUP[test_createText_qmlEscape]="📝 createText"
GROUP[test_create_invalidPath]="🛡️ SafeCreate"
GROUP[test_createWithBindings_invalidPath]="🛡️ SafeCreate"
GROUP[test_create_noProperties]="🛡️ SafeCreate"
GROUP[test_color_lightenColor_mid]="🎨 Color"
GROUP[test_color_lightenColor_cap]="🎨 Color"
GROUP[test_color_getBorderColor]="🎨 Color"
GROUP[test_color_allFormats]="🎨 Color"

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
