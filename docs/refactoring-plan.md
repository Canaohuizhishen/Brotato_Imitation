# Brotato_Imitation 重构计划

> **目标**：解决严重性能卡顿 + 架构腐化问题，使游戏可流畅运行（稳定 60 FPS），同时提升可维护性、可测试性和数据可编辑性。
>
> **总预计**：7 个 Phase，24 个 Step，约 80 次编辑操作。每个 Phase 完成后可独立构建、运行、验证，可随时暂停。
>
> **适用对象**：AI agent（flash 执行，pro 审查）。每步标注了精确的文件路径、操作类型、验收标准和禁止事项。

---

## 文档使用指南（给 AI agent）

- **每步开始前**：`read_file` 读取本 Step 列出的所有目标文件
- **每步完成后**：跑验收标准中的命令，确认通过再进行下一步
- **遇到 SEARCH 不匹配**：说明文件已被之前的步骤修改，重新 `read_file` 确认当前内容
- **禁止跨 Step 操作**：一个 Step 做完并验收通过，才能开始下一个
- **禁止超出范围**：每个 Step 的「禁止事项」列表是硬约束

---

## 依赖关系图

```
Phase 0 (Bug修复) ──→ Phase 1 (数据外提) ──→ Phase 2 (Timer整合) ──→ Phase 4 (碰撞优化)
                          │                         │
                          └──→ Phase 5 (拆分)       └──→ Phase 3 (对象池)
                                                        │
                                                        └──→ Phase 6 (渲染优化)
                                                              │
                                                              └──→ Phase 7 (测试)
```

- Phase 2 和 Phase 3 可并行（不冲突）
- Phase 4 依赖 Phase 2（需要 GameLoop 框架）
- Phase 5 与 Phase 1 无依赖（提取 SaveManager.js 不涉及数据格式变更）
- Phase 6 可与 Phase 3/4 并行

---

## Phase 0：紧急 Bug 修复

**目标**：修复 4 个确定性的运行时 bug，零架构改动，零风险。

**总预计编辑次数**：5

---

### Step 0.1 — 修复拼写错误 bug

**目标文件**：
- `data/PropCustomizationCore.qml`

**操作**：3 处精确修改

| # | 当前代码（SEARCH） | 替换为（REPLACE） | 位置线索 |
|---|-------------------|-------------------|----------|
| 1 | `PlayerData.elementalDamag+=2` | `PlayerData.elementalDamage+=2` | 沸水（boiling_water）道具的 `apply()` 函数内 |
| 2 | `PlayerData.Damage-=2` | `PlayerData.damage-=2` | 螺旋桨帽子（propeller_hat）道具的 `apply()` 函数内 |
| 3 | 不做代码修改，仅在肥料（fertilizer）道具的 `apply()` 上一行加注释 | `// TODO: 数值与talentText描述不一致（代码-2近战伤害，描述-1近战伤害）` | 肥料道具 |

**SEARCH 策略**：使用 `search_content` 分别搜索 `elementalDamag`、`PlayerData.Damage`、`PlayerData\.Damage` 确保无其他遗漏。注意 `PlayerData.Damage` 中的 `.Damage` 是大写 D。

**验收**：
```
search_content "elementalDamag" → 零结果
search_content "PlayerData\.Damage" → 确认只剩小写 damage 用法
```

**禁止**：
- 不要改任何 `apply()` 里的数值
- 不要改 talentText 字符串
- 不要重构其他代码

**回滚**：`git checkout -- data/PropCustomizationCore.qml`

---

### Step 0.2 — 修复 getMonster/getWeapon/getRole 查找失败返回垃圾值

**目标文件**：
- `singleton/MonstersData.qml` — `getMonster()` 函数
- `data/WeaponCustomizationCore.qml` — `getWeapon()` 函数
- `data/RoleCustomizationCore.qml` — `getRole()` 函数

**当前代码模式**（三个文件类似，以 `getMonster` 为例）：
```javascript
function getMonster(monsterName){
    for(var i=0;i<core.children.length;i++){
        if(core.children[i].objectName===monsterName || core.children[i].monsterName===monsterName)break
    }
    return core.children[i]
}
```

**修改为**（三个文件模式一致）：
```javascript
function getMonster(monsterName){
    for(var i=0;i<core.children.length;i++){
        if(core.children[i].objectName===monsterName || core.children[i].monsterName===monsterName){
            return core.children[i]
        }
    }
    console.error("MonstersData.getMonster: '" + monsterName + "' not found")
    return null
}
```

**三个函数各自的 error 前缀**：
| 文件 | 函数 | error 前缀 |
|------|------|-----------|
| `singleton/MonstersData.qml` | `getMonster` | `MonstersData.getMonster` |
| `data/WeaponCustomizationCore.qml` | `getWeapon` | `WeaponCustomizationCore.getWeapon` |
| `data/RoleCustomizationCore.qml` | `getRole` | `RoleCustomizationCore.getRole` |

**验收**：
- 代码审查：三个函数都采用 `找到即 return + 末尾 console.error + return null` 模式
- 游戏启动不报错

**禁止**：
- 不要改调用方（Monster.qml 等）——调用方会在后续 Phase 逐步加固
- 不要顺带"优化"其他函数

**回滚**：`git checkout -- singleton/MonstersData.qml data/WeaponCustomizationCore.qml data/RoleCustomizationCore.qml`

---

## Phase 1：游戏数据外提

**目标**：将硬编码在 5 个 QML 文件中的游戏数据（武器、道具、角色、升级选项、怪物、波次配置）迁移到 JSON 配置文件，通过纯 JS 模块 `DataLoader.js` 加载和查询。

**为什么先做**：后续所有优化（Phase 3 对象池、Phase 5 PlayerData 拆分）都依赖清晰的数据结构。数据外提后，策划和数值设计可以直接编辑 JSON。

**总预计编辑次数**：12+

---

### Step 1.1 — 创建 JSON 数据文件

**操作类型**：新增文件（6 个 JSON + 1 个 qrc）

**新建文件清单**：

| 文件路径 | 内容 | 来源（当前数据所在） | 大致条目数 |
|----------|------|---------------------|-----------|
| `data/weapons.json` | 武器基础定义 | `data/WeaponCustomizationCore.qml` 的嵌套 Item | ~6 |
| `data/props.json` | 道具定义 | `data/PropCustomizationCore.qml` 的 50+ 个 Item | ~50 |
| `data/roles.json` | 角色天赋定义 | `data/RoleCustomizationCore.qml` 的嵌套 Item | ~2(+扩展预留) |
| `data/upgradeOptions.json` | 升级选项定义 | `data/UpgradeOptionCustomizationCore.qml` 的嵌套 Item | ~20 |
| `data/monsters.json` | 怪物基础属性 | `singleton/MonstersData.qml` 的 15 个嵌套 Item | ~15 |
| `data/waves.json` | 每波出怪配置 | `singleton/MonstersData.qml` 的 `onWaveNumberChanged` switch 语句 | 20 波 |

**JSON Schema 定义**：

#### weapons.json

```json
[
  {
    "objectName": "spear",
    "weaponName": "长矛",
    "type": "原始",
    "source": "Spear.qml",
    "aspectRatio": 0.1634,
    "scaleRatio": 2.5,
    "xOffset": -22,
    "yOffset": -5,
    "handX": 22.5,
    "handY": 7.5,
    "grades": [
      { "grade": 1, "baseDamage": 15, "meleeDamageMultiplier": 1.0, "baseCooldown": 1.52, "baseRange": 350, "basePrice": 20 },
      { "grade": 2, "baseDamage": 25, "meleeDamageMultiplier": 1.0, "baseCooldown": 1.40, "baseRange": 375, "basePrice": 39 },
      { "grade": 3, "baseDamage": 40, "meleeDamageMultiplier": 1.0, "baseCooldown": 1.28, "baseRange": 400, "basePrice": 74 },
      { "grade": 4, "baseDamage": 60, "meleeDamageMultiplier": 1.0, "baseCooldown": 1.24, "baseRange": 500, "basePrice": 149 }
    ]
  },
  {
    "objectName": "smg",
    "weaponName": "冲锋枪",
    "type": "枪械",
    "source": "SMG.qml",
    "aspectRatio": 0.683,
    "scaleRatio": 1.0,
    "xOffset": -2,
    "yOffset": 0,
    "handX": 9,
    "handY": 16,
    "grades": [
      { "grade": 1, "baseDamage": 3, "rangedDamageMultiplier": 0.5, "basePrice": 20 },
      { "grade": 2, "baseDamage": 4, "rangedDamageMultiplier": 0.6, "basePrice": 39 },
      { "grade": 3, "baseDamage": 5, "rangedDamageMultiplier": 0.7, "basePrice": 74 },
      { "grade": 4, "baseDamage": 8, "rangedDamageMultiplier": 0.8, "basePrice": 149 }
    ]
  }
]
```

SMG 的 `baseCooldown`、`baseRange` 等属性在不同等级中保持不变，但仍在每个 grade 对象中重复声明，以保持 schema 一致性。

#### props.json

```json
[
  {
    "objectName": "bat",
    "propName": "蝙蝠",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+2</font><font color='white'>生命窃取</font><br>\n<font color='red'>-2</font><font color='white'>收获</font><br>",
    "effects": [
      { "attribute": "lifeSteal", "delta": 2 },
      { "attribute": "harvesting", "delta": -2 }
    ]
  }
]
```

**关键设计决策**：`effects` 数组替代原来的 `apply()` 函数。不再需要每个道具写一个 JS 函数——改为数据驱动，通用的 effect 应用逻辑在 Step 1.3 的 DataLoader 中实现。

#### roles.json

```json
[
  {
    "objectName": "wellRounded",
    "roleName": "全能者",
    "talentText": "<font color='lime'>+5</font><font color='white'> 最大生命值</font><br>\n<font color='lime'>+5</font><font color='white'> %速度</font><br>\n<font color='lime'>+8</font><font color='white'> 收获</font>",
    "effects": [
      { "attribute": "maxHp", "condition": "lt", "conditionValue": 15, "setTo": 15 },
      { "attribute": "curHp", "setToProp": "maxHp" },
      { "attribute": "speed", "condition": "lt", "conditionValue": 5, "setTo": 5 },
      { "attribute": "harvesting", "condition": "lt", "conditionValue": 8, "setTo": 8 }
    ]
  }
]
```

`condition: "lt"` 表示"当前值小于 conditionValue 时才设置"，对应原来的 `if(PlayerData.xxx < N) PlayerData.xxx = N` 逻辑。`setToProp` 表示设置为某个属性的值。

#### monsters.json

```json
[
  {
    "objectName": "babyAlien",
    "monsterName": "外星婴儿",
    "source": "BabyAlien.qml",
    "attackRange": 0,
    "maxCurNumber": 50,
    "initHp": 3,
    "hpBonus": 2.0,
    "initVelocity": 250,
    "maxVelocity": 300,
    "initDamage": 1,
    "damageBonus": 0.6,
    "materialDrops": 1,
    "consumableDropRate": 0.01,
    "chestDropRate": 0.01
  }
]
```

注意 `initVelocity` 和 `maxVelocity` 是**原始值**（未乘以 `velocityRate`），乘以 `velocityRate` 的逻辑保留在 MonstersData 中。

#### waves.json

```json
[
  { "wave": 1, "spawns": [
    { "monster": "babyAlien", "initCount": 4 }
  ]},
  { "wave": 2, "spawns": [
    { "monster": "babyAlien", "initCount": 4 },
    { "monster": "chaser", "initCount": 3 }
  ]},
  { "wave": 3, "spawns": [
    { "monster": "babyAlien", "initCount": 5 },
    { "monster": "chaser", "initCount": 3 }
  ]}
]
```

依此类推，直到 wave 20。

#### upgradeOptions.json

```json
[
  {
    "objectName": "maxHpUp1",
    "optionName": "最大生命值+1",
    "grade": 1,
    "effects": [
      { "attribute": "maxHp", "delta": 1 }
    ]
  }
]
```

**验收**：
```bash
# 每个 JSON 文件都是合法 JSON
python3 -m json.tool data/weapons.json > /dev/null
python3 -m json.tool data/props.json > /dev/null
python3 -m json.tool data/roles.json > /dev/null
python3 -m json.tool data/upgradeOptions.json > /dev/null
python3 -m json.tool data/monsters.json > /dev/null
python3 -m json.tool data/waves.json > /dev/null

# 条目数验证（手动计数对照原 QML）
search_content "objectName:" data/props.json | wc -l    # 应与原 PropCustomizationCore.qml 道具数一致
search_content "objectName:" data/weapons.json | wc -l  # 应与原 WeaponCustomizationCore.qml 武器数一致
```

**禁止**：
- 不修改任何 QML 文件（那是 Step 1.2-1.4 的事）
- JSON 中不包含 `talentText` 的动态计算值（如 `damage`、`cooldown`）——这些由 DataLoader 在运行时动态生成
- props.json 中角色的 role 道具（如 wellRounded、mutant）type 为 "角色" 而非 "道具"

**回滚**：`rm data/weapons.json data/props.json data/roles.json data/upgradeOptions.json data/monsters.json data/waves.json`（尚未被引用，删掉不影响项目）

---

### Step 1.2 — 创建 DataLoader.js 纯 JS 模块

**操作类型**：新增文件

**新建文件**：`logic/DataLoader.js`

**完整模板**：

```javascript
.pragma library

// ============================================================================
// DataLoader — 游戏数据加载与查询模块
// 所有游戏数据从 JSON 文件加载，首次访问时触发懒加载，结果缓存于内存
// 所有查询接口返回深拷贝，避免调用方意外修改缓存
// ============================================================================

// ---- 数据缓存（懒加载，首次访问时填充） ----
var _weapons = null
var _props = null
var _roles = null
var _upgradeOptions = null
var _monsters = null
var _waves = null

var _propsByGrade = null  // { 1: [...], 2: [...], 3: [...], 4: [...] }
var _weaponsByGrade = null
var _upgradeOptionsByGrade = null

// ---- 内部：JSON 加载 ----
function _loadJSON(path) {
    var xhr = new XMLHttpRequest()
    xhr.open("GET", path, false)  // 同步加载 —— 仅在启动时调用，阻塞可接受
    xhr.send()
    if (xhr.status === 200 || xhr.status === 0) {  // status===0 用于 qrc:// 协议
        try {
            return JSON.parse(xhr.responseText)
        } catch (e) {
            console.error("DataLoader: JSON parse error in " + path + ": " + e)
            return []
        }
    }
    console.error("DataLoader: failed to load " + path + " status=" + xhr.status)
    return []
}

// ---- 内部：确保所有数据已加载 ----
function _ensureLoaded() {
    if (_weapons !== null) return  // 已加载

    _weapons = _loadJSON("qrc:/data/weapons.json")
    _props = _loadJSON("qrc:/data/props.json")
    _roles = _loadJSON("qrc:/data/roles.json")
    _upgradeOptions = _loadJSON("qrc:/data/upgradeOptions.json")
    _monsters = _loadJSON("qrc:/data/monsters.json")
    _waves = _loadJSON("qrc:/data/waves.json")

    // 按等级分桶索引
    _propsByGrade = { 1: [], 2: [], 3: [], 4: [] }
    for (var i = 0; i < _props.length; i++) {
        var p = _props[i]
        if (p.grade >= 1 && p.grade <= 4) {
            _propsByGrade[p.grade].push(p)
        }
    }
    _weaponsByGrade = { 1: [], 2: [], 3: [], 4: [] }
    for (var j = 0; j < _weapons.length; j++) {
        // 武器按最低等级归类（1级）
        _weaponsByGrade[1].push(_weapons[j])
    }
    _upgradeOptionsByGrade = { 1: [], 2: [], 3: [], 4: [] }
    for (var k = 0; k < _upgradeOptions.length; k++) {
        var o = _upgradeOptions[k]
        if (o.grade >= 1 && o.grade <= 4) {
            _upgradeOptionsByGrade[o.grade].push(o)
        }
    }
}

// ---- 内部：深拷贝 ----
function _deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj))
}

// ---- 内部：加权随机选择 ----
// 概率权重由调用方通过 gradeWeights 参数传入
function _weightedRandomSelect(candidatesByGrade, gradeWeights, count) {
    if (count <= 0) return []
    var totalWeight = gradeWeights[1] + gradeWeights[2] + gradeWeights[3] + gradeWeights[4]
    var result = []
    var usedIndices = {}  // "grade_index" → true

    for (var n = 0; n < count; n++) {
        var random = Math.random() * totalWeight
        var probability = gradeWeights[4]
        var grade
        if (random < probability) {
            grade = 4
        } else {
            probability += gradeWeights[3]
            if (random < probability) {
                grade = 3
            } else {
                probability += gradeWeights[2]
                if (random < probability) {
                    grade = 2
                } else {
                    grade = 1
                }
            }
        }

        var pool = candidatesByGrade[grade]
        if (!pool || pool.length === 0) {
            // 回退到其他等级
            for (var g = 1; g <= 4; g++) {
                if (candidatesByGrade[g] && candidatesByGrade[g].length > 0) {
                    pool = candidatesByGrade[g]
                    grade = g
                    break
                }
            }
        }
        if (!pool || pool.length === 0) break

        // 查重：避免同一 item 被选两次
        var attempts = 0
        var index
        do {
            index = Math.floor(Math.random() * pool.length)
            attempts++
        } while (usedIndices[grade + "_" + index] && attempts < 100)

        usedIndices[grade + "_" + index] = true
        var copy = _deepCopy(pool[index])
        copy.grade = grade
        result.push(copy)
    }
    return result
}

// ============================================================================
// 公开查询接口
// ============================================================================

// ---- 武器 ----
function getWeapon(objectName, grade) {
    _ensureLoaded()
    for (var i = 0; i < _weapons.length; i++) {
        if (_weapons[i].objectName === objectName || _weapons[i].weaponName === objectName) {
            var w = _deepCopy(_weapons[i])
            _applyGradeData(w, grade)
            w.grade = grade || 1
            return w
        }
    }
    console.error("DataLoader.getWeapon: '" + objectName + "' not found")
    return null
}

function _applyGradeData(weapon, grade) {
    if (!weapon.grades) return
    for (var g = 0; g < weapon.grades.length; g++) {
        if (weapon.grades[g].grade === grade) {
            var gd = weapon.grades[g]
            for (var key in gd) {
                if (gd.hasOwnProperty(key) && key !== "grade") {
                    weapon[key] = gd[key]
                }
            }
            return
        }
    }
}

function getWeaponRandomly(count, gradeWeights) {
    _ensureLoaded()
    return _weightedRandomSelect(_weaponsByGrade, gradeWeights, count)
}

// ---- 道具 ----
function getProp(objectName) {
    _ensureLoaded()
    for (var i = 0; i < _props.length; i++) {
        if (_props[i].objectName === objectName || _props[i].propName === objectName) {
            return _deepCopy(_props[i])
        }
    }
    console.error("DataLoader.getProp: '" + objectName + "' not found")
    return null
}

function getPropRandomly(count, gradeWeights) {
    _ensureLoaded()
    return _weightedRandomSelect(_propsByGrade, gradeWeights, count)
}

function getPropGradeCounts() {
    _ensureLoaded()
    return {
        1: _propsByGrade[1].length,
        2: _propsByGrade[2].length,
        3: _propsByGrade[3].length,
        4: _propsByGrade[4].length
    }
}

// ---- 角色 ----
function getRole(objectName) {
    _ensureLoaded()
    for (var i = 0; i < _roles.length; i++) {
        if (_roles[i].objectName === objectName || _roles[i].roleName === objectName) {
            return _deepCopy(_roles[i])
        }
    }
    console.error("DataLoader.getRole: '" + objectName + "' not found")
    return null
}

// ---- 升级选项 ----
function getUpgradeOption(grade, objectName) {
    _ensureLoaded()
    for (var i = 0; i < _upgradeOptions.length; i++) {
        if (_upgradeOptions[i].objectName === objectName || _upgradeOptions[i].optionName === objectName) {
            var o = _deepCopy(_upgradeOptions[i])
            o.grade = grade
            return o
        }
    }
    console.error("DataLoader.getUpgradeOption: '" + objectName + "' not found")
    return null
}

function getUpgradeOptionRandomly(count, gradeWeights) {
    _ensureLoaded()
    return _weightedRandomSelect(_upgradeOptionsByGrade, gradeWeights, count)
}

// ---- 怪物 ----
function getMonster(objectName) {
    _ensureLoaded()
    for (var i = 0; i < _monsters.length; i++) {
        if (_monsters[i].objectName === objectName || _monsters[i].monsterName === objectName) {
            return _deepCopy(_monsters[i])
        }
    }
    console.error("DataLoader.getMonster: '" + objectName + "' not found")
    return null
}

// ---- 波次 ----
function getWaveConfig(waveNumber) {
    _ensureLoaded()
    for (var i = 0; i < _waves.length; i++) {
        if (_waves[i].wave === waveNumber) {
            return _deepCopy(_waves[i])
        }
    }
    console.error("DataLoader.getWaveConfig: wave " + waveNumber + " not found")
    return null
}

// ---- 通用 effect 应用 ----
// 由 PropCustomizationCore 和 RoleCustomizationCore 调用
// 将道具/角色的 effects 数组应用到 PlayerData
function applyEffects(effects, playerData) {
    if (!effects || !playerData) return
    for (var i = 0; i < effects.length; i++) {
        var eff = effects[i]
        if (eff.condition === "lt") {
            // 当前值小于阈值时设置
            if (playerData[eff.attribute] < eff.conditionValue) {
                playerData[eff.attribute] = eff.setTo
            }
        } else if (eff.setToProp) {
            // 设置为某属性的值
            playerData[eff.attribute] = playerData[eff.setToProp]
        } else if (eff.delta !== undefined) {
            // 加减法
            playerData[eff.attribute] += eff.delta
        }
    }
}
```

**验收**：
```bash
search_content ".pragma library" logic/DataLoader.js  # 确认存在
search_content "function get.*(" logic/DataLoader.js   # 确认所有公开接口存在
```

**禁止**：
- 不要 import QtQuick（纯 JS 模块，.pragma library）
- 不要在 DataLoader 中直接引用 PlayerData（由调用方传入）

---

### Step 1.3 — 替换各个 CustomizationCore

**目标文件**（修改 5 个）：

| 文件 | 操作类型 | 原大致行数 | 目标行数 |
|------|----------|-----------|---------|
| `data/WeaponCustomizationCore.qml` | 重写 | ~150 | ~50 |
| `data/PropCustomizationCore.qml` | 重写 | ~1000 | ~60 |
| `data/RoleCustomizationCore.qml` | 重写 | ~50 | ~35 |
| `data/UpgradeOptionCustomizationCore.qml` | 重写 | ~300 | ~55 |
| `singleton/MonstersData.qml` | 大幅删改 | ~350 | ~70 |

---

#### 1.3a — WeaponCustomizationCore.qml 重写

**文件**：`data/WeaponCustomizationCore.qml`

```qml
import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    // 概率权重属性（保留在 QML 侧，因为它们绑定到 PlayerData 的动态值）
    property double grade_one_weapon_spawn_probability: 0.5065 * (1 - PlayerData.luck / 1000)
    property double grade_two_weapon_spawn_probability: 0.25 * (1 - PlayerData.luck / 500)
    property double grade_three_weapon_spawn_probability: 0.125 * (1 + PlayerData.luck / 250)
    property double grade_four_weapon_spawn_probability: 0.065 * (1 + PlayerData.luck / 125)

    function getWeaponRandomly(n) {
        var weights = {
            1: core.grade_one_weapon_spawn_probability,
            2: core.grade_two_weapon_spawn_probability,
            3: core.grade_three_weapon_spawn_probability,
            4: core.grade_four_weapon_spawn_probability
        }
        return DataLoader.getWeaponRandomly(n, weights)
    }

    function getWeapon(weaponName, grade) {
        return DataLoader.getWeapon(weaponName, grade || 1)
    }
}
```

---

#### 1.3b — PropCustomizationCore.qml 重写

**文件**：`data/PropCustomizationCore.qml`

```qml
import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    property double grade_one_prop_spawn_probability: 0.5065 * (1 - PlayerData.luck / 1000)
    property double grade_two_prop_spawn_probability: 0.25 * (1 - PlayerData.luck / 500)
    property double grade_three_prop_spawn_probability: 0.125 * (1 + PlayerData.luck / 250)
    property double grade_four_prop_spawn_probability: 0.065 * (1 + PlayerData.luck / 125)

    function getPropRandomly(number) {
        var weights = {
            1: core.grade_one_prop_spawn_probability,
            2: core.grade_two_prop_spawn_probability,
            3: core.grade_three_prop_spawn_probability,
            4: core.grade_four_prop_spawn_probability
        }
        var result = DataLoader.getPropRandomly(number, weights)
        if (number === 1) return result.length > 0 ? result[0] : []
        return result
    }

    function getProp(propName) {
        return DataLoader.getProp(propName)
    }

    // 通用 applyEffect —— 替代原来每个道具的 apply() 函数
    function applyEffects(effects) {
        DataLoader.applyEffects(effects, PlayerData)
    }
}
```

**关于 `talentText` 动态值**：武器和道具的 `talentText` 包含动态属性值（如 `damage`、`cooldown.toFixed(2)`）。需要在 QML 侧（`WeaponCard.qml` 或 `GoodsCard.qml`）动态生成显示文本，而非在 JSON 中存储。具体做法：

1. JSON 中存 `talentTextTemplate`（占位符模式如 `"伤害 : {{damage}}(+{{meleeDamageMultiplier}}%近战伤害)"`）
2. DataLoader 提供 `renderTalentText(template, data)` 函数做模板替换

这个功能可以在 **Step 1.5**（可选补充）中实现。当前 Step 1.3 暂不在 WeaponCard/GoodsCard 中动态渲染，因为原有的 `talentText` 绑定到 QML 属性仍可工作（属性值来自 DataLoader 查询结果）。

---

#### 1.3c — RoleCustomizationCore.qml 重写

**文件**：`data/RoleCustomizationCore.qml`

```qml
import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    function getRole(roleName) {
        return DataLoader.getRole(roleName)
    }

    function applyRoleEffects(roleData) {
        DataLoader.applyEffects(roleData.effects, PlayerData)
    }
}
```

---

#### 1.3d — UpgradeOptionCustomizationCore.qml 重写

**文件**：`data/UpgradeOptionCustomizationCore.qml`

```qml
import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    property double grade_one_option_spawn_probability: 0.5065 * (1 - PlayerData.luck / 1000)
    property double grade_two_option_spawn_probability: 0.25 * (1 - PlayerData.luck / 500)
    property double grade_three_option_spawn_probability: 0.125 * (1 + PlayerData.luck / 250)
    property double grade_four_option_spawn_probability: 0.065 * (1 + PlayerData.luck / 125)

    function getOptionRandomly(n) {
        var weights = {
            1: core.grade_one_option_spawn_probability,
            2: core.grade_two_option_spawn_probability,
            3: core.grade_three_option_spawn_probability,
            4: core.grade_four_option_spawn_probability
        }
        return DataLoader.getUpgradeOptionRandomly(n, weights)
    }

    function getUpgradeOption(grade, optionName) {
        return DataLoader.getUpgradeOption(grade, optionName)
    }
}
```

---

#### 1.3e — MonstersData.qml 删减

**文件**：`singleton/MonstersData.qml`

**操作**：
1. **删除**所有 15 个嵌套 `Item{}` 块（tree, babyAlien, chaser, charger, sprayer, brute, pursuer, helmetAlien, finChaser, summoner, scavenger, helmetBrute, helmetCharger, prayer），它们的静态数据现在在 `monsters.json` 中
2. **删除** `onWaveNumberChanged` 中的巨大 switch 语句，改为调用 DataLoader
3. **保留** `velocityRate` 属性、`init()` 函数

```qml
pragma Singleton
import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core
    property double velocityRate: 0.8
    property int waveNumber: PlayerData.currentWaveNumber

    onWaveNumberChanged: {
        applyWaveConfig(waveNumber)
    }

    function getMonster(monsterName) {
        return DataLoader.getMonster(monsterName)
    }

    function getWaveConfig(waveNum) {
        return DataLoader.getWaveConfig(waveNum)
    }

    function applyWaveConfig(waveNum) {
        var config = DataLoader.getWaveConfig(waveNum)
        if (!config || !config.spawns) return
        for (var i = 0; i < config.spawns.length; i++) {
            var spawn = config.spawns[i]
            // 设置对应怪物的 initCount
            // 注意：这里需要保留原来的子 Item 引用机制
            // 实际实现时，可以保留子 Item 但数据来自 JSON
        }
    }

    function init() {
        // 重置所有怪物生成计数
        for (var i = 0; i < core.children.length; i++) {
            if (typeof core.children[i].init === "function") {
                core.children[i].init()
            }
        }
    }
    
    // ... 保留必要的子 Item（作为怪物数据容器，属性值从 DataLoader 获取）
}
```

**注意**：MonstersData.qml 的部分子 Item 在运行时被 `Monster.qml` 的 `monsterData` 动态修改（如 `curNumber`、`countRation`），这些运行时属性仍需保留在 QML 侧。JSON 只存储静态基线数据。具体设计在实施时细化。

**统一验收**（5 个文件全部重写后）：
```bash
cmake --build build                    # 构建通过
./appBrotato 2>&1 | grep -i "error"    # 控制台无 DataLoader 相关错误
# 手动测试：
# - 角色选择界面正常显示角色列表
# - 商店可刷新出武器和道具
# - 进入战斗正常生成怪物
```

**禁止**：
- 不要改调用方的导入路径
- 不要改 CMakeLists.txt 中的 `QML_FILES`（除非新增文件需要注册）
- 不要改 `page/StoreInterface.qml`、`components/GoodsCard.qml` 等消费者的代码

---

### Step 1.4 — CMakeLists.txt 和 qrc 注册新资源

**目标文件**：
- `CMakeLists.txt`（新增资源引用）
- **新建** `data/data.qrc`

**新建 `data/data.qrc`**：
```xml
<RCC>
    <qresource prefix="/data">
        <file>weapons.json</file>
        <file>props.json</file>
        <file>roles.json</file>
        <file>upgradeOptions.json</file>
        <file>monsters.json</file>
        <file>waves.json</file>
    </qresource>
</RCC>
```

**修改 CMakeLists.txt**：在 `RESOURCES` 附近添加 `RESOURCES data/data.qrc`

**如果 Qt 资源系统不适用**（QML/JS 环境 XMLHttpRequest 对 qrc 支持有限），备选方案：
- 将 JSON 文件放在可执行文件旁的 `data/` 目录
- DataLoader 使用相对路径加载（`"data/weapons.json"`）
- 不需要 qrc 注册

**验收**：
```bash
cmake --build build  # 构建成功
```

**禁止**：不要删除已有的 `RESOURCES images.qrc`、`RESOURCES audio.qrc`、`RESOURCES singleton.qrc`

---

## Phase 2：Timer 整合——消灭高频游戏循环

**目标**：将 150+ 个独立 Timer 整合为单一的 `GameLoop`（1 个 16ms Timer，60 FPS），使用 `deltaTime` 保证移动速度不变。

**性能收益**：**极高**——Timer 实例从 150+ 降到 ~10，事件循环压力减少 90%+。

**总预计编辑次数**：15+

---

### Step 2.1 — 创建 GameLoop 组件

**操作类型**：新增文件

**新建文件**：`logic/GameLoop.qml`

```qml
import QtQuick 2.15

Item {
    id: gameLoop

    property bool active: false
    property bool paused: false
    property double deltaTime: 0.016
    property int frameCount: 0

    // 各频率回调注册表
    property var perFrameCallbacks: []       // 每帧：怪物移动、子弹移动、玩家移动
    property var per100msCallbacks: []       // 约 100ms：武器瞄准
    property var per200msCallbacks: []       // 约 200ms：掉落拾取、怪物间碰撞
    property var per500msCallbacks: []       // 约 500ms：怪物生成决策
    property var per3000msCallbacks: []      // 约 3000ms：波次怪物生成

    property double _lastTime: 0

    Timer {
        id: tickTimer
        interval: 16  // ~62.5 FPS
        running: gameLoop.active && !gameLoop.paused
        repeat: true
        onTriggered: {
            var now = Date.now()
            gameLoop.deltaTime = gameLoop._lastTime > 0
                ? Math.min((now - gameLoop._lastTime) / 1000.0, 0.1)  // cap at 100ms to avoid spiral
                : 0.016
            gameLoop._lastTime = now
            gameLoop.frameCount++

            // -- 每帧回调 --
            var i
            for (i = 0; i < perFrameCallbacks.length; i++) {
                perFrameCallbacks[i](gameLoop.deltaTime)
            }

            // -- 约 100ms (每 ~6 帧) --
            if (frameCount % 6 === 0) {
                for (i = 0; i < per100msCallbacks.length; i++) {
                    per100msCallbacks[i]()
                }
            }

            // -- 约 200ms (每 ~12 帧) --
            if (frameCount % 12 === 0) {
                for (i = 0; i < per200msCallbacks.length; i++) {
                    per200msCallbacks[i]()
                }
            }

            // -- 约 500ms (每 ~31 帧) --
            if (frameCount % 31 === 0) {
                for (i = 0; i < per500msCallbacks.length; i++) {
                    per500msCallbacks[i]()
                }
            }

            // -- 约 3000ms (每 ~187 帧) --
            if (frameCount % 187 === 0) {
                for (i = 0; i < per3000msCallbacks.length; i++) {
                    per3000msCallbacks[i]()
                }
            }
        }
    }

    // ---- 注册/注销接口 ----
    function registerPerFrame(callback)     { perFrameCallbacks.push(callback) }
    function registerPer100ms(callback)     { per100msCallbacks.push(callback) }
    function registerPer200ms(callback)     { per200msCallbacks.push(callback) }
    function registerPer500ms(callback)     { per500msCallbacks.push(callback) }
    function registerPer3000ms(callback)    { per3000msCallbacks.push(callback) }

    function removePerFrame(callback) {
        var idx = perFrameCallbacks.indexOf(callback)
        if (idx >= 0) perFrameCallbacks.splice(idx, 1)
    }
    function removePer100ms(callback) {
        var idx = per100msCallbacks.indexOf(callback)
        if (idx >= 0) per100msCallbacks.splice(idx, 1)
    }
    function removePer200ms(callback) {
        var idx = per200msCallbacks.indexOf(callback)
        if (idx >= 0) per200msCallbacks.splice(idx, 1)
    }
    function removePer500ms(callback) {
        var idx = per500msCallbacks.indexOf(callback)
        if (idx >= 0) per500msCallbacks.splice(idx, 1)
    }
    function removePer3000ms(callback) {
        var idx = per3000msCallbacks.indexOf(callback)
        if (idx >= 0) per3000msCallbacks.splice(idx, 1)
    }

    // ---- 重置 ----
    function reset() {
        _lastTime = 0
        frameCount = 0
        deltaTime = 0.016
    }
}
```

**为什么 deltaTime cap 到 100ms**：防止窗口失焦后回来时出现巨大的 deltaTime 导致实体穿墙。

**验收**：
```bash
search_content "GameLoop" logic/GameLoop.qml
```

**禁止**：不要在 GameLoop 中导入 PlayerData 或任何游戏逻辑（它是纯粹的时钟组件）。

---

### Step 2.2 — 玩家移动改为 GameLoop 驱动

**目标文件**：`monsters/Player.qml`

**操作**：

**2.2a** — 新增键盘状态对象（在 Player 的根属性区域）：

```qml
property var keysPressed: ({ "W": false, "A": false, "S": false, "D": false })
```

**2.2b** — 修改按键处理（保留现有的 `Keys.onPressed` 和 `Keys.onReleased` 框架，只改 switch 内容）：

```qml
Keys.onPressed: function(event) {
    switch(event.key) {
        case Qt.Key_W: keysPressed.W = true; event.accepted = true; break;
        case Qt.Key_A: keysPressed.A = true; event.accepted = true; break;
        case Qt.Key_S: keysPressed.S = true; event.accepted = true; break;
        case Qt.Key_D: keysPressed.D = true; event.accepted = true; break;
        default: break;
    }
}
Keys.onReleased: function(event) {
    switch(event.key) {
        case Qt.Key_W: keysPressed.W = false; event.accepted = true; break;
        case Qt.Key_A: keysPressed.A = false; event.accepted = true; break;
        case Qt.Key_S: keysPressed.S = false; event.accepted = true; break;
        case Qt.Key_D: keysPressed.D = false; event.accepted = true; break;
        default: break;
    }
}
```

**2.2c** — 删除 8 个 Timer（方向移动 Timer，可能在 line 290-352 附近）。先在 Player.qml 中 `search_content "Timer\s*{"` 找到所有 Timer，识别并删除以下 8 个：`pressWTimer`、`pressATimer`、`pressSTimer`、`pressDTimer`、`pressWATimer`、`pressWDTimer`、`pressSATimer`、`pressSDTimer`。

**2.2d** — 新增 `updateMovement(deltaTime)` 函数：

```qml
function updateMovement(deltaTime) {
    if (isDead || !gameArea.isInCombat || !gameArea.active) return
    if (gameArea.paused) return

    var step = v * deltaTime  // v 已在 Player.qml 定义
    var dx = 0, dy = 0
    if (keysPressed.W) dy -= 1
    if (keysPressed.S) dy += 1
    if (keysPressed.A) dx -= 1
    if (keysPressed.D) dx += 1

    // 对角线归一化
    if (dx !== 0 && dy !== 0) {
        dx *= 0.707
        dy *= 0.707
    }

    // 边界约束
    var newX = x + dx * step
    var newY = y + dy * step
    // 注意：实际边界约束逻辑需要保留 Player.qml 原有的 clamp 逻辑
    // 此处为示意，实施时精确复制原有的约束计算

    x = newX
    y = newY

    // 更新朝向
    if (dx > 0) faceRight()
    else if (dx < 0) faceLeft()
}
```

**验收**：
- 玩家 WASD 移动流畅
- 松开按键角色立即停止
- 对角线移动速度与正交移动一致
- 暂停时角色无法移动

**禁止**：
- 不要改 Player.qml 的碰撞/伤害/死亡逻辑
- 不要改 `isDead`、`active`、`paused` 属性
- 不要改 `Keys.forwardTo` 相关逻辑

---

### Step 2.3 — 怪物移动改为 GameLoop 驱动

**目标文件**：`monsters/Monster.qml`

**操作**：

**2.3a** — 删除 `moveTimer`（约在 line 152，`id: moveTimer`）。

**2.3b** — 新增 `updateMovement(deltaTime)` 函数（提取自原来 `moveTimer.onTriggered` 的移动逻辑）：

```qml
function updateMovement(deltaTime) {
    if (isDead || isDestroy) return
    if (isFrontHaveOtherMonster || isMoveStoped) return
    if (!active || paused) return

    var dx = (target.x + target.width / 2) - (x + width / 2)
    var dy = (target.y + target.height / 2) - (y + height / 2)
    var distance = Math.sqrt(dx * dx + dy * dy)

    if (distance < target.width / 2) {
        // 已碰撞
        hit()
    } else {
        var stepSize = v * deltaTime  // v 已在 Monster.qml 定义
        var stepX = (dx / distance) * stepSize
        var stepY = (dy / distance) * stepSize
        if (moveDirectionConverse) {
            if (x > 0 && x < parent.width - width) x -= stepX
            if (y > 0 && y < parent.height - height) y -= stepY
        } else {
            x += stepX
            y += stepY
        }
    }

    z = y + height  // Y 排序
}
```

**2.3c** — 保持 `checkFaceDirectionTimer`（175ms 频率合理，不需要整合）。

**2.3d** — Monster.qml 的 `v` 属性调整：

原 `stepSize = v * interval / 1200 = v * 10 / 1200 = v / 120`。  
新 `stepSize = v * deltaTime = v * 0.016`。  
要使两者相等：`v_new * 0.016 = v_old / 120` → `v_new = v_old / (120 * 0.016) = v_old / 1.92`。

所以 `v` 的计算公式改为：`property double v: core.initVelocity * core.velocityRate / 1.92`

**验收**：
- 怪物按原有速度向玩家移动
- 暂停时怪物停止移动
- 怪物死亡后不再移动
- 怪物间碰撞行为保留

**禁止**：
- 不要改 Monster.qml 中的碰撞/死亡动画/飙血/白闪逻辑
- 不要改子类怪物（Charger.qml 等）的特殊移动逻辑——它们将在 Step 2.3e 统一处理

---

#### Step 2.3e — 子类怪物的特殊 Timer 整合

**涉及文件**：

| 文件 | 需整合的 Timer | 频率 | GameLoop 频率 |
|------|---------------|------|--------------|
| `monsters/Charger.qml` | `collisionDetectionTimer` | 10ms | perFrame |
| `monsters/Charger.qml` | `checkTimer` | 150ms | per200ms |
| `monsters/Charger.qml` | `coolDownTimer` | 一次性 | 保留（用 TimerCanPause） |
| `monsters/Sprayer.qml` | `checkTimer` | ~500ms | per500ms |
| `monsters/Sprayer.qml` | `coolDownTimer` | 一次性 | 保留 |
| `monsters/Prayer.qml` | `timer` | 500ms | per500ms |
| `monsters/Prayer.qml` | `attackTimer` | 500ms | per500ms |
| `monsters/Scavenger.qml` | `setGoalRandomlyTimer` | 2000ms | per2000ms（在 GameLoop 中添加） |
| `monsters/Summoner.qml` | `checkTimer` | 500ms | per500ms |
| `monsters/Pursuer.qml` | `accelerateTimer` | 2000ms | per2000ms |

**操作**：
1. 删除 Timer 声明
2. 将 `onTriggered` 逻辑提取为命名函数（如 `checkChargeCollision()`）
3. 在 `Monsters.qml` 的 `spawnMonster` 中将该函数注册到 GameLoop 对应频率
4. 在 `monster.destroy` 前从 GameLoop 注销

**每个子类怪物只做一次编辑**：删除 Timer + 提取函数名。注册/注销在 `Monsters.qml` 统一处理。

**验收**：
- Charger 仍能正常冲锋和检测碰撞
- Sprayer 仍能正常喷涂
- Prayer 仍能正常攻击
- Scavenger 仍能随机移动

---

### Step 2.4 — 全局 Timer 整合到 GameLoop

**目标文件**和**操作**：

| 文件 | 原 Timer | 间隔 | 操作 |
|------|---------|------|------|
| `weapons/Weapons.qml` | `setGoalTimer` | 100ms | 删除 Timer；提取 `updateGoals()`；注册到 per100ms |
| `monsters/Monsters.qml` | `checkCollidingMonsterTimer` | 150ms | 删除 Timer；提取 `checkMonsterCollisions()`；注册到 per200ms |
| `bullets/Bullets.qml` | `collidingTimer` | 15ms(敌)/50ms(玩家) | 删除 Timer；提取 `checkBulletCollisions()`；注册到 perFrame |
| `drops/Drops.qml` | `collidingTimer` | 200ms | 删除 Timer；提取 `checkDropCollisions()`；注册到 per200ms |
| `monsters/Monsters.qml` | `createMonsterTimer` | 3000ms | 删除 Timer；提取 `createWaveMonsters()`；注册到 per3000ms |
| `monsters/Monsters.qml` | `sleepTimer` | 700ms(一次性) | 保留（这是一次性 Timer，不需要整合） |

**操作模板**（以 `setGoalTimer` 为例）：

**编辑前**（Weapons.qml）：
```qml
Timer {
    id: setGoalTimer
    interval: 100
    running: weapons.active
    repeat: true
    onTriggered: {
        // ... 瞄准逻辑 ...
    }
}
```

**编辑后**：
```qml
// 提取的函数
function updateGoals() {
    if (!active || paused) return
    // ... 原来的瞄准逻辑 ...
}
```

`GameArea.qml` 中注册：`gameLoop.registerPer100ms(function() { weapons.updateGoals() })`

**验收**：
```bash
# 统计 monsters/、weapons/、bullets/、drops/ 下的 Timer 声明
search_content "Timer\s*{" monsters/ | wc -l
search_content "Timer\s*{" weapons/ | wc -l
search_content "Timer\s*{" bullets/ | wc -l
search_content "Timer\s*{" drops/ | wc -l
# 应大幅下降（参见 Phase 6 渲染优化后还剩的 UI 动画 Timer）
```

**禁止**：
- 不要动 UI Timer（如 `WaveCountdown.qml` 的倒计时 Timer、各种 `OpacityAnimator`、`SequentialAnimation` 等）
- 不要动 `TimerCanPause` 组件
- 不要动 `sound/Sound.qml` 中的任何东西

---

## Phase 3：对象池与组件缓存

**目标**：消灭所有 `Qt.createQmlObject` 和重复的 `Qt.createComponent` 调用。这些调用每次触发完整的 QML 编译（0.5-3ms），是战斗场景中卡顿的主要来源。

**性能收益**：**极高**——消除运行时 QML 编译，对象回收将 GC 压力减少 90%+。

**总预计编辑次数**：10+

---

### Step 3.1 — 预编译全局 Component 缓存

**新建文件**：`logic/ComponentCache.qml`

```qml
import QtQuick 2.15

Item {
    id: cache

    // 怪物相关
    property Component monsterComponent: null
    property Component forkComponent: null

    // 子弹相关
    property Component bulletComponent: null
    property Component staticBulletComponent: null
    property Component movingBulletComponent: null
    property Component roundMovingBulletComponent: null
    property Component roundStaticBulletComponent: null
    property Component ellipticalMovingBulletComponent: null
    property Component meleeBulletComponent: null

    // 掉落相关
    property Component materialComponent: null
    property Component fruitComponent: null
    property Component chestComponent: null

    // 武器相关
    property Component spearComponent: null
    property Component smgComponent: null

    // 状态
    property bool allReady: false
    property int _loadedCount: 0
    property int _totalCount: 13

    Component.onCompleted: {
        // 异步预编译所有组件
        monsterComponent = Qt.createComponent("qrc:/monsters/Monster.qml", Component.Asynchronous)
        forkComponent = Qt.createComponent("qrc:/components/Fork.qml", Component.Asynchronous)
        // ... 其他组件

        // 连接状态信号
        monsterComponent.statusChanged.connect(_checkAllReady)
        forkComponent.statusChanged.connect(_checkAllReady)
        // ...
    }

    function _checkAllReady() {
        _loadedCount = 0
        if (monsterComponent && monsterComponent.status === Component.Ready) _loadedCount++
        if (forkComponent && forkComponent.status === Component.Ready) _loadedCount++
        // ...
        if (_loadedCount >= _totalCount) {
            allReady = true
            console.log("ComponentCache: all " + _loadedCount + " components ready")
        }
    }

    // ---- 工厂方法 ----
    function createMonster(parent, properties) {
        if (!monsterComponent || monsterComponent.status !== Component.Ready) {
            console.error("ComponentCache: monsterComponent not ready")
            return null
        }
        return monsterComponent.createObject(parent, properties || {})
    }

    function createFork(parent, properties) {
        if (!forkComponent || forkComponent.status !== Component.Ready) return null
        return forkComponent.createObject(parent, properties || {})
    }

    function createBullet(type, parent, properties) {
        var comp = null
        switch (type) {
            case "MovingBullet": comp = movingBulletComponent; break
            case "StaticBullet": comp = staticBulletComponent; break
            case "RoundMovingBullet": comp = roundMovingBulletComponent; break
            // ...
        }
        if (!comp || comp.status !== Component.Ready) return null
        return comp.createObject(parent, properties || {})
    }

    function createMaterial(parent, properties) { /* ... */ }
    function createFruit(parent, properties) { /* ... */ }
    function createChest(parent, properties) { /* ... */ }
}
```

**修改目标文件**（替换 `Qt.createComponent` 调用）：

| 文件 | 位置 | 当前代码 | 替换为 |
|------|------|---------|--------|
| `monsters/Monsters.qml` | `spawnMonster()` (~line 278) | `var comp = Qt.createComponent(source)` | `componentCache.createMonster(parent, props)` |
| `monsters/Monsters.qml` | Fork 创建 (~line 240) | `Qt.createComponent("Fork.qml")` | `componentCache.createFork(...)` |
| `monsters/Monsters.qml` | 掉落创建 (~line 288,307,319) | `Qt.createComponent(...)` | `componentCache.createMaterial/createFruit/createChest(...)` |
| `weapons/Weapons.qml` | 武器创建 (~line 140) | `Qt.createComponent(...)` | `componentCache.createWeapon(...)` |
| `weapons/SMG.qml` | 子弹创建 (~line 144) | `Qt.createComponent(...)` | `componentCache.createBullet("MovingBullet", ...)` |
| `weapons/Spear.qml` | 子弹创建 (~line 89) | `Qt.createComponent(...)` | `componentCache.createBullet("MeleeBullet", ...)` |
| `components/Forks.qml` | Fork 创建 (~line 26) | `Qt.createComponent(...)` | `componentCache.createFork(...)` |

**关键约束**：ComponentCache 需要在 `GameWindow.qml` 或 `GameArea.qml` 中作为顶层子组件声明，并通过 id 传递到需要它的组件。组件缓存必须使用 `Component.Asynchronous` 模式以避免启动时阻塞。

**验收**：
```bash
search_content "Qt\.createComponent" monsters/ weapons/ bullets/ drops/ components/
# 应只剩 ComponentCache.qml 内部有
```

**禁止**：
- 不要用同步模式（`Qt.createComponent(url)` 无第二个参数）——这会阻塞主线程
- 不要为不存在的组件类型创建缓存条目

---

### Step 3.2 — 血花粒子对象池

**新建文件**：`logic/ParticlePool.js`

```javascript
.pragma library

// 固定大小的粒子对象池，用于血花效果
// 预创建 N 个 Rectangle + SequentialAnimation，循环复用

var _poolSize = 50
var _pool = []
var _nextIndex = 0
var _initialized = false

function init(parent) {
    if (_initialized) return
    for (var i = 0; i < _poolSize; i++) {
        var particle = _createParticle(parent)
        particle.visible = false
        _pool.push(particle)
    }
    _initialized = true
}

function _createParticle(parent) {
    // 使用 Qt.createComponent 一次性创建，后续复用
    // 注意：这里只调用一次 createComponent（非 createQmlObject）
    var comp = Qt.createComponent("qrc:/particles/BloodParticle.qml")
    if (comp.status === Component.Ready) {
        return comp.createObject(parent)
    }
    return null
}

function spawn(x, y, dx, dy, width, parent) {
    // 从池中取出下一个粒子，设置位置和动画参数
    var particle = _pool[_nextIndex]
    if (!particle || particle.isDestroy) {
        // 如果粒子被意外销毁，重新创建
        particle = _createParticle(parent)
    }
    particle.x = x
    particle.y = y
    particle.targetDx = dx
    particle.targetDy = dy
    particle.particleWidth = width
    particle.visible = true
    particle.restartAnimation()
    _nextIndex = (_nextIndex + 1) % _poolSize
}

function release(particle) {
    particle.visible = false
}
```

**新建文件**：`particles/BloodParticle.qml`

从 `monsters/Monster.qml` 的 `makeBlood()` 函数（约 line 395）中提取血花 Rectangle + SequentialAnimation 逻辑，做成独立组件。

**修改目标文件**：`monsters/Monster.qml`

**原来** `makeBlood()` 函数：使用 `Qt.createQmlObject` 动态创建 Rectangle + 动画。

**修改为**：
```qml
function makeBlood(x, y, dx, dy, width, parent) {
    ParticlePool.spawn(x, y, dx, dy, width, parent)
}
```

**验收**：
- 击中怪物后血花效果正常显示
- 无控制台 QML 编译错误
- `search_content "Qt\.createQmlObject" monsters/Monster.qml` → 零结果

---

### Step 3.3 — 伤害文本对象池

**修改文件**：`tool.js` — `createText()` 函数

**新建文件**：`logic/TextPool.js`

与 ParticlePool 类似的固定大小池（如 30 个预先创建的 Text 组件），循环复用。

```javascript
.pragma library

var _poolSize = 30
var _pool = []
var _nextIndex = 0
var _ready = false
var _parent = null

function init(parent) {
    if (_ready) return
    _parent = parent
    for (var i = 0; i < _poolSize; i++) {
        var comp = Qt.createComponent("qrc:/particles/DamageText.qml")
        if (comp.status === Component.Ready) {
            var text = comp.createObject(parent)
            text.visible = false
            _pool.push(text)
        }
    }
    _ready = true
}

function show(text, size, color, x, y, duration, outlineColor) {
    var t = _pool[_nextIndex]
    _nextIndex = (_nextIndex + 1) % _poolSize
    if (!t || t.isDestroy) return
    t.showText(text, size, color, x, y, duration || 600, outlineColor || "black")
}
```

**修改 `tool.js` 的 `createText`** 函数签名不变，内部委托给 TextPool：

```javascript
function createText(parent, text, size, color, _x, _y, duration, OutlineColor) {
    // 确保 TextPool 已初始化
    if (!TextPool._ready) TextPool.init(parent)
    TextPool.show(text, size, color, _x, _y, duration, OutlineColor)
}
```

**注意**：`tool.js` 有 `.pragma library`，无法直接引用另一个 `.pragma library`。解决方式：
- 将 TextPool 的逻辑内联到 tool.js（简单粗暴）
- 或移除 tool.js 的 `.pragma library`，改为普通 JS 导入

**推荐方案**：在 tool.js 中直接实现池化逻辑，不需要单独文件。tool.js 已经包含 `createText`，只需改造其内部实现。

**改造后的 tool.js createText**：
```javascript
// ---- 文本对象池 ----
var _textPool = []
var _textPoolSize = 30
var _textPoolIndex = 0
var _textComp = null

function _ensureTextPool(parent) {
    if (_textComp === null) {
        _textComp = Qt.createComponent("qrc:/particles/DamageText.qml")
    }
    while (_textPool.length < _textPoolSize) {
        var t = _textComp.createObject(parent)
        t.visible = false
        _textPool.push(t)
    }
}

function createText(parent, text, size, color, _x, _y, duration, OutlineColor) {
    _ensureTextPool(parent)
    var t = _textPool[_textPoolIndex]
    _textPoolIndex = (_textPoolIndex + 1) % _textPoolSize
    if (t && !t.isDestroy) {
        t.showText(text, size, color, _x, _y, duration || 600, OutlineColor || "black")
    }
}
```

**新建 `particles/DamageText.qml`**：从 tool.js 原来的 `Qt.createQmlObject` 中提取 Text + SequentialAnimation 逻辑。

**验收**：
```bash
search_content "Qt\.createQmlObject.*Text\s*\{" tool.js  # 零结果（确认已替换）
```
- 游戏中的伤害数字、治疗数字正常显示和消失

---

### Step 3.4 — 怪物特效遮罩（红色/白色 mask）

**目标文件**：`monsters/Charger.qml`、`monsters/Prayer.qml`、`monsters/Sprayer.qml`、`monsters/Scavenger.qml`、`monsters/Monster.qml`

**问题**：这些文件在技能触发时使用 `Qt.createQmlObject` 动态创建红色遮罩 Image。

**操作**：
1. 在每个怪物的根组件中**预先声明**遮罩 Image（visible: false）
2. 技能触发时，设置 `visible = true`，播放动画
3. 动画结束后设置 `visible = false`
4. 删除所有 `Qt.createQmlObject` 调用

**以 Charger.qml 为例**：

**删除**（约 line 45 的 dynamic Image 创建）：
```javascript
var mask = Qt.createQmlObject(`import QtQuick 2.15; Image { ... }`, ...)
```

**替换为**：在 Charger 根组件中预声明：
```qml
Image {
    id: redMask
    source: charger.isFaceRight ? "/images/brute_redMask_faceRight.png" : "/images/brute_redMask_faceLeft.png"
    anchors.fill: parent
    visible: false
    opacity: 1.0
    z: 100

    OpacityAnimator {
        id: maskAnimator
        target: redMask
        from: 1.0
        to: 0
        duration: 200
        onStopped: redMask.visible = false
    }
}
```

技能触发时：
```javascript
function showRedMask() {
    redMask.visible = true
    redMask.opacity = 1.0
    maskAnimator.start()
}
```

**Monster.qml 的 whiteOverlay**：当前已经用预声明的 Image + OpacityAnimator（`Monster.qml:112-117` 的 whiteOverlay 和 `Monster.qml:288-293` 的 whiteOverlayAnimator），这部分**已经正确，不需要改**。

**验收**：
```bash
search_content "Qt\.createQmlObject" monsters/
# 零结果（Monster.qml 的 makeBlood 在 Step 3.2 已移除）
```
- Charger 冲锋时红色遮罩正常显示和消失
- Sprayer/Prayer/Scavenger 技能特效正常

---

### Step 3.5 — 材料拾取粒子

**目标文件**：`drops/Material.qml`

**问题**：每次材料拾取（`beGetedTo()` 函数，约 line 163），使用 `Qt.createQmlObject` 创建 6 个残渣 Rectangle。

**操作**：与 Step 3.2 相同模式——将残渣粒子加入 ParticlePool（或创建独立的 DebrisPool）。

**验收**：
```bash
search_content "Qt\.createQmlObject" drops/  # 零结果
```

---

## Phase 4：碰撞检测优化

**目标**：将 O(n²) 碰撞检测优化为 O(n) 量级。

**性能收益**：**高**——子弹碰撞从 ~40,000 次/秒降到 ~2,000 次/秒；怪物间碰撞从 ~6,000 次/秒降到 ~500 次/秒。

**总预计编辑次数**：8+

---

### Step 4.1 — 实现 SpatialGrid

**新建文件**：`logic/SpatialGrid.js`

```javascript
.pragma library

// 空间网格分区——将游戏区域划分为等大小网格单元
// 提供 O(1) 插入/更新/查询（在实体均匀分布的前提下）

var _cellSize = 200  // 每个单元格 200×200
var _grid = {}       // "col_row" → [entity1, entity2, ...]
var _entityCells = {} // entity.id → "col_row"（用于快速更新）

function init(cellSize) {
    _cellSize = cellSize || 200
    _grid = {}
    _entityCells = {}
}

function _getKey(x, y) {
    var col = Math.floor(x / _cellSize)
    var row = Math.floor(y / _cellSize)
    return col + "_" + row
}

function insert(entity, x, y) {
    var key = _getKey(x, y)
    if (!_grid[key]) _grid[key] = []
    _grid[key].push(entity)
    _entityCells[entity._spatialId] = key
}

function remove(entity) {
    var key = _entityCells[entity._spatialId]
    if (!key) return
    var cell = _grid[key]
    if (!cell) return
    var idx = cell.indexOf(entity)
    if (idx >= 0) cell.splice(idx, 1)
    delete _entityCells[entity._spatialId]
}

function update(entity, x, y) {
    var oldKey = _entityCells[entity._spatialId]
    var newKey = _getKey(x, y)
    if (oldKey === newKey) return  // 还在同一格
    remove(entity)
    insert(entity, x, y)
}

// 查询指定矩形范围内的所有实体（包括相邻格的实体）
function query(x, y, w, h) {
    var result = []
    var minCol = Math.floor(x / _cellSize)
    var maxCol = Math.floor((x + w) / _cellSize)
    var minRow = Math.floor(y / _cellSize)
    var maxRow = Math.floor((y + h) / _cellSize)

    for (var col = minCol; col <= maxCol; col++) {
        for (var row = minRow; row <= maxRow; row++) {
            var key = col + "_" + row
            var cell = _grid[key]
            if (cell) {
                for (var i = 0; i < cell.length; i++) {
                    result.push(cell[i])
                }
            }
        }
    }
    return result
}

function clear() {
    _grid = {}
    _entityCells = {}
}
```

**验收**：
```bash
# 确认文件存在且有 .pragma library
search_content ".pragma library" logic/SpatialGrid.js
```

---

### Step 4.2 — 重构子弹碰撞检测

**目标文件**：
- `bullets/Bullets.qml` — 修改 `collidingTimer` 回调（已在 Phase 2 整合到 GameLoop 的 perFrame 回调）
- `monsters/Monsters.qml` — 修改 `checkMonsterCollisions()` 函数

**子弹碰撞修改**（Bullets.qml 的 perFrame 回调函数）：

**原来**（O(bullets × monsters)）：
```javascript
function checkBulletCollisions() {
    for (var i = 0; i < bullets.children.length; i++) {
        var bullet = bullets.children[i]
        var hitMonster = monsters.getCollidingChild(bullet)  // 遍历所有怪物
        if (hitMonster) {
            hitMonster.onHit(bullet)
            bullet.destroy()
        }
    }
}
```

**改为**（使用 SpatialGrid）：
```javascript
function checkBulletCollisions() {
    for (var i = bullets.children.length - 1; i >= 0; i--) {
        var bullet = bullets.children[i]
        if (!bullet || bullet.isDestroy) continue
        // 从空间网格查询附近的怪物
        var nearby = SpatialGrid.query(bullet.x, bullet.y, bullet.width, bullet.height)
        for (var j = 0; j < nearby.length; j++) {
            var monster = nearby[j]
            if (monster && !monster.isDead && _aabbCollide(bullet, monster)) {
                monster.onHit(bullet)
                SpatialGrid.remove(bullet)
                bullet.destroy()
                break
            }
        }
    }
}

function _aabbCollide(a, b) {
    return a.x < b.x + b.width &&
           a.x + a.width > b.x &&
           a.y < b.y + b.height &&
           a.y + a.height > b.y
}
```

**怪物间碰撞修改**（Monsters.qml）同理：
```javascript
function checkMonsterCollisions() {
    // 遍历每个怪物，用 SpatialGrid 查询相邻怪物
    for (var i = 0; i < monsters.children.length; i++) {
        var m = monsters.children[i]
        if (m.isDead || m.isDestroy) continue
        var nearby = SpatialGrid.query(m.x, m.y, m.width, m.height)
        var blocked = false
        for (var j = 0; j < nearby.length; j++) {
            var other = nearby[j]
            if (other === m || other.isDead || other.isDestroy) continue
            if (_aabbCollide(m, other)) {
                // 两个怪物碰撞——根据原来逻辑设置 isFrontHaveOtherMonster
                if (m.y + m.height < other.y + other.height) {
                    m.isFrontHaveOtherMonster = true
                }
                blocked = true
                break
            }
        }
        if (!blocked) m.isFrontHaveOtherMonster = false
    }
}
```

**SpatialGrid 更新时机**：在 GameLoop 的 perFrame 回调中，移动实体后立即调用 `SpatialGrid.update(entity, entity.x, entity.y)`。

**实体空间 ID**：每个实体需要一个唯一 `_spatialId`。在 Monster.qml 中：
```qml
property string _spatialId: "monster_" + monsterName + "_" + Math.random().toString(36).substr(2, 8)
```
在 Bullet.qml 中同理。

**验收**：
- 子弹与怪物碰撞行为与重构前一致
- 怪物间碰撞行为一致
- 无实体穿透现象
- 帧率在中后期波次（30+ 怪物 + 20+ 子弹）明显提升

**禁止**：
- 不要改碰撞响应逻辑（`onHit`、击退角度、飙血等）
- 不要改变游戏平衡

---

## Phase 5：提取 SaveManager.js

**目标**：将 `PlayerData.qml` 中 224 行的存档/读档逻辑（JSON 序列化 + 属性恢复 + 数据校验）提取到独立的 `logic/SaveManager.js`，降低 PlayerData 的职责密度。

**性能收益**：无。纯代码组织优化。

**总预计编辑次数**：3 次文件操作

**变更文件**：`logic/SaveManager.js`（新建）+ `singleton/PlayerData.qml`（2 行 import + 2 行委托）+ `singleton.qrc` + `CMakeLists.txt`

**消费者文件**：零改动。PlayerData 的 `saveGame()` / `loadGame()` 接口签名不变。

---

### Step 5.1 — 提取 SaveManager.js

**新建文件**：`logic/SaveManager.js`

从 `PlayerData.qml` 中提取：

1. `saveGame(data, fileManager, appDataPath)` — 遍历 40+ 属性序列化为 JSON，调用 `FileManager.saveGameData()` 写盘，写入前 JSON round-trip 深拷贝
2. `loadGame(data, fileManager, appDataPath)` — 从 `FileManager.loadGameData()` 读取 JSON，逐字段用空值合并运算符（`??`）恢复属性，重建 ListModel（weapons / props / lastStoreGoods）
3. 辅助函数 `weaponsToArray()`、`propsToArray()`、`lastStoreGoodsToArray()`——Model 转纯 JS 数组

**不提取**：
- PlayerData 的属性声明（curLevel / curHp / weapons 等）
- 变更处理器（onCurXpChanged / onCurHpChanged 等）
- 业务函数（init / addWeapon / addProp / hpRegenerationPerSecond 等）
- 生命周期（Component.onCompleted / onDestruction）

**PlayerData.qml 中的改动**：

```qml
// +1 行 import
import "../logic/SaveManager.js" as SaveManager

// 原来 110 行 saveGame + 115 行 loadGame → 替换为 2 行委托
function saveGame() { SaveManager.saveGame(root, fileManager, appDataPath) }
function loadGame() { SaveManager.loadGame(root, fileManager, appDataPath) }
```

**验收**：构建通过，存档/读档功能正常。通过 `savegame.json.bak` 备份恢复机制验证。

**禁止**：不改动任何消费者文件、不改模块注册、不改 PlayerData 的属性/处理器/信号声明。

---

### 风险与回滚

- **低风险**：SaveManager 是纯 JS `.pragma library`，不涉及 QML 绑定或组件树，误改不影响运行时其他逻辑。
- **回滚**：`git checkout -- logic/SaveManager.js singleton/PlayerData.qml singleton.qrc CMakeLists.txt`

这样消费者可以逐步迁移，而不会一次性全部崩溃。

**验收**：
```bash
cmake --build build  # 构建通过
# 手动测试完整游戏流程：选择角色 → 开始战斗 → 升级 → 商店购买 → 暂停存档 → 读档
```

---

## Phase 6：渲染优化

**目标**：减少绘制调用、纹理切换和无用 GPU 计算。

**性能收益**：中高。纹理切换减少 50%，屏幕外动画暂停节省 GPU 时间。

**总预计编辑次数**：8+

---

### Step 6.1 — 怪物朝向切换改为镜像

**目标文件**：`monsters/Monster.qml` 和所有子类怪物

**当前做法**：切换 `source` 属性加载 `_faceRight.png` 或 `_faceLeft.png`，导致纹理重新加载和 GPU 上传。

**修改方案**：

在 `monsterIcon` Image 上添加：
```qml
Image {
    id: monsterIcon
    source: "/images/" + monster.monsterName + "_faceRight.png"  // 永远加载右侧
    anchors.fill: parent
    z: 1
    transform: Scale {
        origin.x: monsterIcon.width / 2
        xScale: monster.isFaceRight ? 1 : -1
    }
}
```

删除 `faceLeft()` 中的 source 切换逻辑，只保留 `isFaceRight = false`。

同样处理 mask overlay 的朝向：
```qml
Image {
    id: whiteOverlay
    source: "/images/" + monster.monsterName + "_mask_faceRight.png"
    anchors.fill: parent
    opacity: 0
    z: 100
    transform: Scale {
        origin.x: whiteOverlay.width / 2
        xScale: monster.isFaceRight ? 1 : -1
    }
}
```

**影响**：不再需要 `_faceLeft.png` 和 `_mask_faceLeft.png` 图片文件。可以保留文件不删除以免影响其他引用，但不再加载。

**验收**：
- 怪物左右朝向正确显示
- `monsterIcon.source` 不再在运行时变化
- 不再有 `_faceLeft.png` 的 URL 引用（除了纯数据的 `monsters.json` 中的 source 字段）

**禁止**：不要删除 images/ 中的 `_faceLeft.png` 文件（它们可能在 Player 或其他地方使用）。

---

### Step 6.2 — squashSequence 视口裁剪

**目标文件**：`monsters/Monster.qml`

**操作**：在 `squashSequence` 上添加条件运行逻辑：

```qml
SequentialAnimation {
    id: squashSequence
    loops: Animation.Infinite
    running: monster.active && monster._isInViewport

    // ... 原有动画 ...
}
```

新增 `_isInViewport` 属性：
```qml
property bool _isInViewport: x + width > -200 && x < parent.width + 200 &&
                              y + height > -200 && y < parent.height + 200
```

**为什么用 200px 的缓冲区**：避免在视口边缘频繁切换动画启停。

**验收**：
- 屏幕外的怪物不运行动画
- 怪物进入屏幕时动画正常启动

---

### Step 6.3 — 合并（可选）精灵表

**此 Step 可选**，因为需要工具链支持（TexturePacker 或 ImageMagick 拼接）。

**操作概要**：
1. 使用工具将所有怪物图片合并为一张精灵表（sprite sheet）
2. 使用 QML 的 `Sprite` 或 `spriteSequence` 替代 `Image` + source 切换
3. 减少 GPU 绘制调用（从 N 个怪物 × 每个 2-3 张图 → 1 个纹理）

**验收**：
- 构建通过
- 怪物显示正确
- 性能监控显示绘制调用减少

---

## Phase 7：测试与质量基础设施

**目标**：建立测试框架 + CI 流水线，防止回归。

> ⚠ **实施记录**：尝试了三种方案。
>
> 1. **Node.js 方案**（已废弃）—— `tests/test_core.js` + 4 个 JS 文件加 `module.exports`。
>    需 hack 剥离 `.pragma library`、`vm.runInNewContext`，污染生产代码，且无法测 QML 组件。
>
> 2. **自定义 QML 框架**（已废弃）—— `tests/tst_runner.qml` + `QQmlComponent`。
>    在无显示环境中 Timer/onCompleted 不触发，无法可靠退出事件循环。
>
> 3. **QtTest.TestCase + 中文包装脚本** ✅ 最终方案——
>    底层用 QtTest 生成 `build/tst_core`，外层用 `run_test.sh` 包装输出中文。

---

### Step 7.1 — QtTest.TestCase 单元测试 + 中文输出

**新建文件**：
- `tests/tst_core.qml` — 72 个 TestCase 用例（+ `tst_gameloop.qml` / `tst_createText.qml` / `tst_safecreate.qml` 共 14 个，合计 86 个）
- `tests/main.cpp` — `QUICK_TEST_MAIN(tst_core)` 入口
- `run_test.sh` — 包装脚本，运行 `build/tst_core` 并输出中文

**修改文件**：`CMakeLists.txt`
- `find_package` 增加 `QuickTest` 组件
- 新增 `tst_core` 可执行目标，注册到 CTest

测试内容（合计 86 个用例）：

| 模块 | 用例数 | 覆盖范围 |
|------|--------|----------|
| `DataLoader.js` | 30 | 武器/道具/角色/怪物/升级查找、随机、效果、伤害计算 |
| `SpatialGrid.js` | 8 | 插入/查询/删除/更新/清空/多实体/跨格 |
| `utils/tool.js` | 7 | 距离、象限、浮点比较、镜像坐标 |
| `utils/color.js` | 5 | 颜色变亮、边框/按钮/背景色 |

**中文输出原理**：`run_test.sh` 内置 86 条函数名 → 中文描述的映射表，
逐行解析 QtTest 原始输出，将 `PASS`/`FAIL` 转为 `✅`/`❌` + 中文描述。

示例：
```
原始:  PASS   : tst_core::CoreTests::test_getWeapon_spear()
输出:  ✅ getWeapon('spear') 返回长矛
```

**验收**：
```bash
./run_test.sh
# 输出：
# 🧪 Brotato 核心逻辑测试
# 📦 DataLoader
#   ✅ getWeapon('spear') 返回长矛
#   ...
# 🎉 全部通过！86 个测试

# 直接运行底层
build/tst_core
ctest --test-dir build -R tst_core
```

---

### Step 7.2 — GitHub Actions CI 配置

**新建文件**：`.github/workflows/build.yml`

两个并行 job：
- `test` — Qt Quick Test 单元测试（需 Qt 6.8 环境）
- `build` — CMake Release 构建验证

**验收**：推送到 GitHub 后 Actions 自动运行，`ctest` 通过且构建成功。

---

## 预计效果总览

| 指标 | 当前 | 目标 |
|------|------|------|
| 活跃 Timer 实例（中期波次） | 150+ | ~10 |
| 动态 QML 编译调用（每次命中/拾取） | 10-20 次 | 0（全部预编译+池化） |
| 碰撞检测/秒（中期波次） | ~46,000 次 | ~3,000 次 |
| PlayerData 行数 | 250+ | ~50（协调层） |
| PropCustomizationCore 行数 | 1000+ | ~60 |
| 游戏数据可编辑性 | 需改 QML 代码 | 编辑 JSON 文件 |
| 帧率（中期波次，30 怪物 + 6 武器） | ~10-20 FPS（推测） | 稳定 60 FPS |
| 构建时类型检查 | 无 | CI 构建 + JSON Schema 验证 |

---

## 附录 A：常见陷阱

1. **QML Timer 的 `running` 绑定不可靠**：当 `active` 或 `paused` 变化时，Timer 的 `running` 绑定可能不会立即更新。在 GameLoop 回调内部判断 `active && !paused` 比依赖 Timer 的 running 更可靠。

2. **`.pragma library` 的限制**：`.pragma library` 模块之间不能相互引用。tool.js 和 DataLoader.js 互相独立。

3. **`Qt.createComponent` 异步模式的坑**：使用 `Component.Asynchronous` 时，可能在 `createObject` 调用时组件还未 Ready。需要检查 `status === Component.Ready`，否则用 `incubateObject` 替代。

4. **SpatialGrid 内存泄漏**：实体销毁时必须调用 `SpatialGrid.remove(entity)`，否则 `_grid` 中会积累僵尸引用。

5. **deltaTime 尖峰**：窗口最小化再恢复后，第一个 deltaTime 可能高达数秒。必须 cap 到 100ms。

---

## 附录 B：每个 Phase 的文件清单

### Phase 0（2 步，5 次编辑）
- `data/PropCustomizationCore.qml`（修改）
- `singleton/MonstersData.qml`（修改）
- `data/WeaponCustomizationCore.qml`（修改）
- `data/RoleCustomizationCore.qml`（修改）

### Phase 1（4 步，12+ 次编辑）
- `data/weapons.json`（新建）
- `data/props.json`（新建）
- `data/roles.json`（新建）
- `data/upgradeOptions.json`（新建）
- `data/monsters.json`（新建）
- `data/waves.json`（新建）
- `logic/DataLoader.js`（新建）
- `data/WeaponCustomizationCore.qml`（重写）
- `data/PropCustomizationCore.qml`（重写）
- `data/RoleCustomizationCore.qml`（重写）
- `data/UpgradeOptionCustomizationCore.qml`（重写）
- `singleton/MonstersData.qml`（大幅删改）
- `data/data.qrc`（新建）
- `CMakeLists.txt`（修改）

### Phase 2（4 步，15+ 次编辑）
- `logic/GameLoop.qml`（新建）
- `monsters/Player.qml`（修改）
- `monsters/Monster.qml`（修改）
- `monsters/Charger.qml`（修改）
- `monsters/Sprayer.qml`（修改）
- `monsters/Prayer.qml`（修改）
- `monsters/Scavenger.qml`（修改）
- `monsters/Summoner.qml`（修改）
- `monsters/Pursuer.qml`（修改）
- `weapons/Weapons.qml`（修改）
- `monsters/Monsters.qml`（修改）
- `bullets/Bullets.qml`（修改）
- `drops/Drops.qml`（修改）
- `page/GameArea.qml`（修改——注册回调到 GameLoop）

### Phase 3（5 步，10+ 次编辑）
- `logic/ComponentCache.qml`（新建）
- `logic/ParticlePool.js`（新建）
- `particles/BloodParticle.qml`（新建）
- `particles/DamageText.qml`（新建）
- `tool.js`（修改——createText 池化）
- `monsters/Monster.qml`（修改）
- `monsters/Monsters.qml`（修改）
- `monsters/Charger.qml`（修改）
- `monsters/Prayer.qml`（修改）
- `monsters/Sprayer.qml`（修改）
- `monsters/Scavenger.qml`（修改）
- `weapons/Weapons.qml`（修改）
- `weapons/SMG.qml`（修改）
- `weapons/Spear.qml`（修改）
- `components/Forks.qml`（修改）
- `drops/Material.qml`（修改）

### Phase 4（2 步，8+ 次编辑）
- `logic/SpatialGrid.js`（新建）
- `bullets/Bullets.qml`（修改）
- `monsters/Monsters.qml`（修改）
- `monsters/Monster.qml`（修改——添加 _spatialId）
- `bullets/Bullet.qml`（修改——添加 _spatialId）
- `weapons/Weapons.qml`（修改——武器瞄准可用 SpatialGrid）

### Phase 5（1 步，4 次编辑）
- `logic/SaveManager.js`（新建）
- `singleton/PlayerData.qml`（修改——+import + 2 行委托，-224 行内联存档）
- `singleton.qrc`（修改——+SaveManager.js）
- `CMakeLists.txt`（修改——+SaveManager.js QML_FILES）

### Phase 6（3 步，8+ 次编辑）
- `monsters/Monster.qml`（修改——镜像 + 视口裁剪）
- 所有子类怪物（修改——删除 faceLeft/faceRight source 切换）

### Phase 7（2 步，4+ 次编辑）
- `tests/tst_core.qml`（新建——QtTest.TestCase，72 个用例；另有 3 个补充文件共 14 个用例）
- `tests/main.cpp`（新建——QUICK_TEST_MAIN 入口）
- `run_test.sh`（新建——中文输出包装脚本）
- `.github/workflows/build.yml`（新建——CI 流水线）
- `CMakeLists.txt`（修改——+QuickTest + tst_core 目标）
- `tests/test_core.js`（新建后删除——Node.js 方案已废弃）
- 4 个 JS 文件的 `module.exports` 块（添加后移除——Node.js 方案已废弃）
- `tests/tst_runner.qml`（新建后删除——自定义框架方案已废弃）
