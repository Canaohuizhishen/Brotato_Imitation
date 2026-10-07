import QtQuick
import QtTest
import singleton.PlayerData
import singleton.MonstersData
import "../logic/DataLoader.js" as DataLoader

// 死亡重试核心逻辑回归——
// 用真实单例（tests/main.cpp 以 app 同款注册机制加载）锁定：
//   PlayerData.rollbackWaveGains：本波收益精确回退（材料/经验精确口径、
//     余料池还原波初快照、跨级升级的等级/经验/maxHp 精确互逆、幂等）
//   MonstersData.resetForWave：出怪运行时计数按波配置复位（重试时波次号不变，
//     须显式调用；波次切换则由 onWaveNumberChanged 自动走同一函数）
// 注意：qmltestrunner 按函数名字母序执行且单例跨用例共享——每个用例先 init() 自清。
TestCase {
    name: "RetryTests"

    function init() {
        PlayerData.init()   // 等级/经验/材料/余料池/波次 全归零（含 _waveStartRemainingMaterials）
    }

    // —— resetForWave：按波配置复位出怪运行时计数且幂等 ——
    function test_resetForWave_resetsRuntimeCounters() {
        var chaser = MonstersData.getMonster("chaser")
        verify(chaser, "chaser 数据项应存在")

        // 模拟战斗残余：初始化计数偏离配置、计数比率被出怪逻辑累积
        chaser.initCount = 99
        chaser.countRation = 2.5

        MonstersData.resetForWave()   // 重试语义：波次号不变，须显式调用

        // 期望值从当前波配置动态读取（随配置数据演进自适应）
        var expected = 0
        var config = DataLoader.getWaveConfig(PlayerData.currentWaveNumber)
        if (config && config.spawns) {
            for (var i = 0; i < config.spawns.length; i++) {
                if (config.spawns[i].monster === "chaser")
                    expected = config.spawns[i].initCount
            }
        }
        compare(chaser.initCount, expected, "initCount 应复位为波配置值")
        compare(chaser.countRation, 1, "countRation 应复位为 1")

        // 幂等：再次调用结果不变
        MonstersData.resetForWave()
        compare(chaser.initCount, expected)
        compare(chaser.countRation, 1)
    }

    // —— 精确回退 + 余料池快照还原 ——
    function test_rollbackWaveGains_exactAndPoolSnapshot() {
        var pd = PlayerData
        pd.curLevel = 10            // maxXp=150（10²+50），给后续数值留出免升级余量
        pd.materialsNumber = 100
        pd.curXp = 10
        pd.remainingMaterialsNumber = 30
        pd.isInCombat = true        // 波次开始：快照余料池=30
        compare(pd._waveStartRemainingMaterials, 30, "波初快照应记录余料池")

        // 模拟本波中途收益：材料+7（curWave 计数同步）、经验+20（未升级）、余料池被生成消耗 -3
        pd.materialsNumber = 107
        pd.curWaveMaterialsNumber = 7
        pd.curXp = 30
        pd.curWaveXpNumber = 20
        pd.remainingMaterialsNumber = 27

        pd.rollbackWaveGains()

        compare(pd.materialsNumber, 100, "材料应精确回退到波初")
        compare(pd.curXp, 10, "经验应精确回退到波初")
        compare(pd.curWaveMaterialsNumber, 0, "本波材料计数应清零")
        compare(pd.curWaveXpNumber, 0, "本波经验计数应清零")
        compare(pd.remainingMaterialsNumber, 30, "余料池应还原到波初快照")
        compare(pd.curLevel, 10, "未升级时等级不变")
    }

    // —— 幂等：重复调用不再改变状态（重试多次/防御性重复调用场景） ——
    function test_rollbackWaveGains_idempotent() {
        var pd = PlayerData
        pd.curLevel = 10            // 避开 L0 的 5 点升阈，保持“未升级”简单态
        pd.materialsNumber = 50
        pd.curXp = 10
        pd.remainingMaterialsNumber = 12
        pd.isInCombat = true
        pd.materialsNumber = 55
        pd.curWaveMaterialsNumber = 5
        pd.curXp = 13
        pd.curWaveXpNumber = 3
        pd.remainingMaterialsNumber = 10

        pd.rollbackWaveGains()
        var snap = [pd.materialsNumber, pd.curXp, pd.curLevel,
                    pd.curWaveMaterialsNumber, pd.curWaveXpNumber,
                    pd.remainingMaterialsNumber]

        pd.rollbackWaveGains()   // 第二次：全部状态应不变
        compare(pd.materialsNumber, snap[0])
        compare(pd.curXp, snap[1])
        compare(pd.curLevel, snap[2])
        compare(pd.curWaveMaterialsNumber, snap[3])
        compare(pd.curWaveXpNumber, snap[4])
        compare(pd.remainingMaterialsNumber, snap[5])
    }

    // —— 跨级升级回退互逆：等级/经验/maxHp 精确还原（锁定负经验降级循环） ——
    // （模拟与生产同构：经验按拾取逐笔写入、每次至多跨一个阈值；批量跨级路径另见 bulk 用例）
    function test_rollbackWaveGains_levelDemotionInverse() {
        var pd = PlayerData
        pd.curLevel = 10            // maxXp=150（10²+50）
        var maxHp0 = pd.maxHp        // 记录波初
        pd.curXp = 149              // 距升级差 1 点

        // 拾取 +10：跨 L10 阈值 150 → L11、余 9
        pd.curXp = 159
        compare(pd.curLevel, 11, "跨 150 应升到 L11")
        compare(pd.curXp, 9, "升级后余量应为 9")

        // 拾取 +171：跨 L11 阈值 171 → L12、余 9
        pd.curXp = 180
        compare(pd.curLevel, 12, "跨 171 应升到 L12")
        compare(pd.curXp, 9, "升级后余量应为 9")

        // 拾取 +6：不跨阈值
        pd.curXp = 15
        pd.curWaveXpNumber = 187    // 本波经验账：10+171+6
        compare(pd.maxHp, maxHp0 + 2, "每升一级 maxHp+1")

        pd.rollbackWaveGains()

        compare(pd.curLevel, 10, "等级应精确降回波初")
        compare(pd.curXp, 149, "经验应精确降回波初（负经验循环逐级撤销）")
        compare(pd.maxHp, maxHp0, "maxHp 应精确还原（降级补偿 -2/级）")
    }

    // —— 批量跨级（单次大额写入）：按各级阈值公平走账，回退精确互逆 ——
    // 回归锁定：onCurXpChanged 曾因处理器内写 curXp 同步递归触发自身，递归帧里
    // curLevel++ 未执行、maxXp 按旧级阈值重复扣除（批量跨级账目错误、回退不可逆）；
    // 防重入守卫（_xpAdjusting）修正后，批量与逐笔同一套“各级自己的阈值”走账。
    function test_rollbackWaveGains_bulkWriteFairWalk() {
        var pd = PlayerData
        pd.curLevel = 10            // maxXp=150
        var maxHp0 = pd.maxHp
        pd.curXp = 149

        pd.curXp = 349              // 单次 +200：跨 150 与 171 两级
        compare(pd.curLevel, 12, "批量写入应按各级阈值走账升两级")
        compare(pd.curXp, 28, "余量应为 349-150-171=28（非旧递归路径的 49）")
        compare(pd.maxHp, maxHp0 + 2, "每升一级 maxHp+1")

        pd.curWaveXpNumber = 200
        pd.rollbackWaveGains()
        compare(pd.curLevel, 10, "等级应精确降回波初")
        compare(pd.curXp, 149, "批量路径同样严格互逆（旧递归语义下为 11/20 回不去）")
        compare(pd.maxHp, maxHp0)

        // 低等级极端例：L0 单次 +45（阈值 5/15/25）——修前递归会连扣 9 次“5”暴涨 9 级
        pd.init()
        pd.curXp = 45
        compare(pd.curLevel, 3, "L0+45 应按 5→15→25 走账升到 3 级")
        compare(pd.curXp, 0)
        pd.curWaveXpNumber = 45
        pd.rollbackWaveGains()
        compare(pd.curLevel, 0, "等级应精确降回 0")
        compare(pd.curXp, 0)
    }
}
