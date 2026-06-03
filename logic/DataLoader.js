.pragma library

// ============================================================================
// DataLoader — 游戏数据加载与查询模块
// 所有游戏数据以内联 JS 对象方式加载，无需 XMLHttpRequest
// 所有查询接口返回深拷贝，避免调用方意外修改缓存
// ============================================================================

// ============================================================
// 1. 武器数据
// ============================================================
var _WEAPONS_DATA = [
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
      { "grade": 1, "baseDamage": 3, "rangedDamageMultiplier": 0.5, "baseCooldown": 0.17, "baseRange": 400, "basePrice": 20 },
      { "grade": 2, "baseDamage": 4, "rangedDamageMultiplier": 0.6, "baseCooldown": 0.17, "baseRange": 400, "basePrice": 39 },
      { "grade": 3, "baseDamage": 5, "rangedDamageMultiplier": 0.7, "baseCooldown": 0.17, "baseRange": 400, "basePrice": 74 },
      { "grade": 4, "baseDamage": 8, "rangedDamageMultiplier": 0.8, "baseCooldown": 0.17, "baseRange": 400, "basePrice": 149 }
    ]
  }
]

// ============================================================
// 2. 道具数据
// ============================================================
var _PROPS_DATA = [{"objectName": "wellRounded", "propName": "全能者", "grade": 5, "type": "角色", "basePrice": 0, "talentText": "<font color='lime'>+5</font><font color='white'> 最大生命值</font><br>\n<font color='lime'>+5</font><font color='white'> %速度</font><br>\n<font color='lime'>+8</font><font color='white'> 收获</font>", "effects": [{"attribute": "maxHp", "condition": "lt", "conditionValue": 15, "setTo": 15}, {"attribute": "curHp", "setToProp": "maxHp"}, {"attribute": "speed", "condition": "lt", "conditionValue": 5, "setTo": 5}, {"attribute": "harvesting", "condition": "lt", "conditionValue": 8, "setTo": 8}]}, {"objectName": "mutant", "propName": "异变体", "grade": 5, "type": "角色", "basePrice": 0, "talentText": "<font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>\n<font color='red'>+50</font><font color='white'> %道具价格</font>", "effects": [{"attribute": "expDiscountRate", "condition": "lt", "conditionValue": 0.33, "setTo": 0.33}, {"attribute": "goodsDiscountRate", "condition": "lt", "conditionValue": 1.5, "setTo": 1.5}]}, {"objectName": "bat", "propName": "蝙蝠", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+2</font><font color='white'>生命窃取</font><br>\n<font color='red'>-2</font><font color='white'>收获</font><br>", "effects": [{"attribute": "lifeSteal", "delta": 2}, {"attribute": "harvesting", "delta": -2}]}, {"objectName": "hedgehog", "propName": "刺猬", "grade": 1, "type": "道具", "basePrice": 30, "talentText": "<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+1</font><font color='white'>远程伤害</font><br>\n<font color='red'>-1</font><font color='white'>生命恢复</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 2}, {"attribute": "rangedDamage", "delta": 1}, {"attribute": "hpRegeneration", "delta": -1}]}, {"objectName": "helmet", "propName": "头盔", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='red'>-2</font><font color='white'>速度</font><br>", "effects": [{"attribute": "armor", "delta": 1}, {"attribute": "speed", "delta": -2}]}, {"objectName": "rubber_berserker", "propName": "橡皮狂暴战士", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+5</font><font color='white'> 攻击速度</font><br>\n<font color='lime'>+15</font><font color='white'>射程</font><br>\n<font color='red'>-1</font><font color='white'>护甲</font><br>", "effects": [{"attribute": "lifeSteal", "delta": 2}, {"attribute": "attackSpeed", "delta": -2}]}, {"objectName": "brain_injury", "propName": "颅脑损伤", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+6</font><font color='white'>伤害</font><br>\n<font color='red'>-8</font><font color='white'>射程</font><br>", "effects": [{"attribute": "damage", "delta": 6}, {"attribute": "attackSpeed", "delta": -8}]}, {"objectName": "coffee", "propName": "咖啡", "grade": 1, "type": "道具", "basePrice": 15, "talentText": "<font color='lime'>+10</font><font color='white'>攻速</font><br>\n<font color='red'>-2</font><font color='white'>伤害</font><br>", "effects": [{"attribute": "attackSpeed", "delta": 10}, {"attribute": "damage", "delta": -2}]}, {"objectName": "claw_tree", "propName": "爪子树", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+1</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+3</font><font color='white'>暴击率</font><br>\n<font color='red'>-1</font><font color='white'>最大生命值</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 1}, {"attribute": "critChance", "delta": 3}, {"attribute": "maxHp", "delta": -1}]}, {"objectName": "boiling_water", "propName": "沸水", "grade": 1, "type": "道具", "basePrice": 30, "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-1</font><font color='white'>最大生命值</font><br>", "effects": [{"attribute": "elementalDamage", "delta": 2}, {"attribute": "maxHp", "delta": -1}]}, {"objectName": "book", "propName": "书", "grade": 1, "type": "道具", "basePrice": 8, "talentText": "<font color='lime'>+1</font><font color='white'>工程</font><br>", "effects": [{"attribute": "engineering", "delta": 1}]}, {"objectName": "break_through", "propName": "破口", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+5</font><font color='white'>最大生命值</font><br>\n<font color='red'>-1</font><font color='white'>生命恢复</font><br>", "effects": [{"attribute": "maxHp", "delta": 5}, {"attribute": "hpRegeneration", "delta": -1}]}, {"objectName": "butterfly", "propName": "蝴蝶", "grade": 1, "type": "道具", "basePrice": 30, "talentText": "<font color='lime'>+2</font><font color='white'>生命偷取</font><br>\n<font color='red'>-1</font><font color='white'>元素伤害</font><br>", "effects": [{"attribute": "lifeSteal", "delta": 2}, {"attribute": "elementalDamage", "delta": -1}]}, {"objectName": "defective_steroids", "propName": "有缺陷的类固醇", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+2</font><font color='white'>最大生命值</font><br>\n<font color='red'>-3</font><font color='white'>攻击速度</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 2}, {"attribute": "maxHp", "delta": 2}, {"attribute": "attackSpeed", "delta": -3}]}, {"objectName": "duct_tape", "propName": "牛皮胶布", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='lime'>+1</font><font color='white'>工程</font><br>\n<font color='red'>-2</font><font color='white'>最大生命</font><br>", "effects": [{"attribute": "armor", "delta": 1}, {"attribute": "engineering", "delta": 1}, {"attribute": "maxHp", "delta": -2}]}, {"objectName": "cake", "propName": "蛋糕", "grade": 1, "type": "道具", "basePrice": 15, "talentText": "<font color='lime'>+3</font><font color='white'>最大生命</font><br>\n<font color='red'>-1</font><font color='white'>伤害</font><br>", "effects": [{"attribute": "maxHp", "delta": 3}, {"attribute": "damage", "delta": -1}]}, {"objectName": "glasses", "propName": "眼镜", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+20</font><font color='white'>射程</font><br>", "effects": [{"attribute": "range", "delta": 20}]}, {"objectName": "goat_skull", "propName": "山羊头骨", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>暴击率</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 3}, {"attribute": "critChance", "delta": -2}]}, {"objectName": "yarmulke", "propName": "小圆帽", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+4</font><font color='white'>速度</font><br>\n<font color='red'>-6</font><font color='white'>射程</font><br>", "effects": [{"attribute": "speed", "delta": 4}, {"attribute": "range", "delta": -6}]}, {"objectName": "injection", "propName": "注射", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+7</font><font color='white'>伤害</font><br>\n<font color='red'>-2</font><font color='white'>最大生命</font><br>", "effects": [{"attribute": "damage", "delta": 7}, {"attribute": "maxHp", "delta": -2}]}, {"objectName": "insane", "propName": "精神错乱", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+6</font><font color='white'>暴击率</font><br>\n<font color='red'>-3</font><font color='white'>伤害</font><br>", "effects": [{"attribute": "critChance", "delta": 6}, {"attribute": "damage", "delta": -3}]}, {"objectName": "lens", "propName": "镜头", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+1</font><font color='white'>远程伤害</font><br>\n<font color='red'>-5</font><font color='white'>射程</font><br>", "effects": [{"attribute": "rangedDamage", "delta": 1}, {"attribute": "range", "delta": -5}]}, {"objectName": "lost_duck", "propName": "迷失之鸭", "grade": 1, "type": "道具", "basePrice": 25, "talentText": "<font color='lime'>+10</font><font color='white'>运气</font><br>\n<font color='red'>-1</font><font color='white'>元素伤害</font><br>", "effects": [{"attribute": "luck", "delta": 10}, {"attribute": "elementalDamage", "delta": -1}]}, {"objectName": "propeller_hat", "propName": "螺旋桨帽子", "grade": 1, "type": "道具", "basePrice": 28, "talentText": "<font color='lime'>+10</font><font color='white'>运气</font><br>\n<font color='red'>-2</font><font color='white'>伤害</font><br>", "effects": [{"attribute": "luck", "delta": 10}, {"attribute": "damage", "delta": -2}]}, {"objectName": "terrifying_onion", "propName": "恐怖洋葱", "grade": 1, "type": "道具", "basePrice": 15, "talentText": "<font color='lime'>+4</font><font color='white'>速度</font><br>\n<font color='red'>-6</font><font color='white'>运气</font><br>", "effects": [{"attribute": "speed", "delta": 4}, {"attribute": "luck", "delta": -6}]}, {"objectName": "toxic_sludge", "propName": "有毒的烂泥", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-2</font><font color='white'>闪避</font><br>", "effects": [{"attribute": "elementalDamage", "delta": 2}, {"attribute": "dodge", "delta": -2}]}, {"objectName": "coal", "propName": "煤炭", "grade": 1, "type": "道具", "basePrice": 20, "talentText": "<font color='lime'>+1</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>收获</font><br>", "effects": [{"attribute": "elementalDamage", "delta": 1}, {"attribute": "meleeDamage", "delta": 2}, {"attribute": "harvesting", "delta": -2}]}, {"objectName": "fertilizer", "propName": "肥料", "grade": 1, "type": "道具", "basePrice": 15, "talentText": "<font color='lime'>+8</font><font color='white'>收获</font><br>\n<font color='red'>-1</font><font color='white'>近战伤害</font><br>", "notes": "TODO: talentText 显示 -1 近战伤害但代码实际 -2", "effects": [{"attribute": "harvesting", "delta": 8}, {"attribute": "meleeDamage", "delta": -2}]}, {"objectName": "acid_liquor", "propName": "酸液", "grade": 2, "type": "道具", "basePrice": 65, "talentText": "<font color='lime'>+8</font><font color='white'>最大生命值</font><br>\n<font color='red'>-4</font><font color='white'>闪避</font><br>", "effects": [{"attribute": "maxHp", "delta": 8}, {"attribute": "dodge", "delta": -4}]}, {"objectName": "energy_bracelet", "propName": "能量手镯", "grade": 2, "type": "道具", "basePrice": 55, "talentText": "<font color='lime'>+4</font><font color='white'>暴击率</font><br>\n<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-2</font><font color='white'>远程伤害</font><br>", "effects": [{"attribute": "critChance", "delta": 4}, {"attribute": "elementalDamage", "delta": 2}, {"attribute": "rangedDamage", "delta": -2}]}, {"objectName": "gear", "propName": "齿轮", "grade": 2, "type": "道具", "basePrice": 35, "talentText": "<font color='lime'>+4</font><font color='white'>工程</font><br>\n<font color='red'>-4</font><font color='white'>伤害</font><br>", "effects": [{"attribute": "engineering", "delta": 8}, {"attribute": "damage", "delta": -4}]}, {"objectName": "cyclops_beetle", "propName": "独眼虫", "grade": 2, "type": "道具", "basePrice": 45, "talentText": "<font color='lime'>+12</font><font color='white'>伤害</font><br>\n<font color='red'>-12</font><font color='white'>射程</font><br>", "effects": [{"attribute": "damage", "delta": 12}, {"attribute": "range", "delta": -12}]}, {"objectName": "fuel_tank", "propName": "燃料箱", "grade": 2, "type": "道具", "basePrice": 45, "talentText": "<font color='lime'>+4</font><font color='white'>元素伤害</font><br>\n<font color='red'>-1</font><font color='white'>近战伤害</font><br>\n<font color='red'>-1</font><font color='white'>远程伤害</font><br>", "effects": [{"attribute": "elementalDamage", "delta": 4}, {"attribute": "meleeDamage", "delta": -1}, {"attribute": "rangedDamage", "delta": -1}]}, {"objectName": "chip", "propName": "筹码", "grade": 2, "type": "道具", "basePrice": 60, "talentText": "<font color='lime'>+8</font><font color='white'>闪避</font><br>\n<font color='red'>-1</font><font color='white'>护甲</font><br>", "effects": [{"attribute": "dodge", "delta": 8}, {"attribute": "armor", "delta": -1}]}, {"objectName": "campfire", "propName": "营火", "grade": 2, "type": "道具", "basePrice": 40, "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>速度</font><br>", "effects": [{"attribute": "elementalDamage", "delta": 2}, {"attribute": "hpRegeneration", "delta": 2}, {"attribute": "speed", "delta": -2}]}, {"objectName": "black_belt", "propName": "黑带", "grade": 2, "type": "道具", "basePrice": 50, "talentText": "<font color='lime'>+25</font><font color='white'>经验获取</font><br>\n<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='red'>-8</font><font color='white'>运气</font><br>", "notes": "TODO: 经验获取属性未实现", "effects": [{"attribute": "meleeDamage", "delta": 3}, {"attribute": "luck", "delta": -8}]}, {"objectName": "patch", "propName": "眼罩", "grade": 2, "type": "道具", "basePrice": 45, "talentText": "<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+5</font><font color='white'>闪避</font><br>\n<font color='red'>-15</font><font color='white'>射程</font><br>", "effects": [{"attribute": "critChance", "delta": 5}, {"attribute": "dodge", "delta": 5}, {"attribute": "range", "delta": -15}]}, {"objectName": "flag", "propName": "旗帜", "grade": 2, "type": "道具", "basePrice": 55, "talentText": "<font color='lime'>+20</font><font color='white'>射程</font><br>\n<font color='lime'>+10</font><font color='white'>攻击速度</font><br>\n<font color='red'>-2</font><font color='white'>生命窃取</font><br>", "effects": [{"attribute": "range", "delta": 20}, {"attribute": "attackSpeed", "delta": 10}, {"attribute": "lifeSteal", "delta": -2}]}, {"objectName": "leather_vest", "propName": "皮制背心", "grade": 2, "type": "道具", "basePrice": 45, "talentText": "<font color='lime'>+2</font><font color='white'>护甲</font><br>\n<font color='lime'>+6</font><font color='white'>闪避</font><br>\n<font color='red'>-3</font><font color='white'>最大生命</font><br>", "effects": [{"attribute": "armor", "delta": 2}, {"attribute": "dodge", "delta": 6}, {"attribute": "maxHp", "delta": -3}]}, {"objectName": "small_muscle_man", "propName": "小肌肉男", "grade": 2, "type": "道具", "basePrice": 50, "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+5</font><font color='white'>最大生命</font><br>\n<font color='red'>-15</font><font color='white'>射程</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 3}, {"attribute": "maxHp", "delta": 5}, {"attribute": "range", "delta": -15}]}, {"objectName": "master", "propName": "精通", "grade": 2, "type": "道具", "basePrice": 55, "talentText": "<font color='lime'>+6</font><font color='white'>近战伤害</font><br>\n<font color='red'>-3</font><font color='white'>远程伤害</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 6}, {"attribute": "rangedDamage", "delta": -3}]}, {"objectName": "medal", "propName": "奖牌", "grade": 2, "type": "道具", "basePrice": 55, "talentText": "<font color='lime'>+3</font><font color='white'>伤害</font><br>\n<font color='lime'>+3</font><font color='white'>速度</font><br>\n<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='lime'>+3</font><font color='white'>最大生命</font><br>\n<font color='red'>-4</font><font color='white'>暴击率</font><br>", "effects": [{"attribute": "damage", "delta": 3}, {"attribute": "speed", "delta": 3}, {"attribute": "armor", "delta": 1}, {"attribute": "maxHp", "delta": 3}, {"attribute": "critChance", "delta": -4}]}, {"objectName": "alien_baby", "propName": "外星人宝宝", "grade": 3, "type": "道具", "basePrice": 80, "talentText": "<font color='lime'>+15</font><font color='white'>最大生命值</font><br>\n<font color='lime'>+8</font><font color='white'>敌人移动速度</font><br>", "notes": "TODO: 敌人移动速度属性未实现", "effects": [{"attribute": "maxHp", "delta": 15}]}, {"objectName": "alien_magic", "propName": "外星人魔法", "grade": 3, "type": "道具", "basePrice": 85, "talentText": "<font color='lime'>+8</font><font color='white'>最大生命值</font><br>\n<font color='lime'>+3</font><font color='white'>生命恢复</font><br>\n<font color='red'>-8</font><font color='white'>运气</font><br>", "effects": [{"attribute": "maxHp", "delta": 8}, {"attribute": "hpRegeneration", "delta": 3}, {"attribute": "luck", "delta": -8}]}, {"objectName": "clover", "propName": "四叶草", "grade": 3, "type": "道具", "basePrice": 65, "talentText": "<font color='lime'>+20</font><font color='white'>运气</font><br>\n<font color='lime'>+6</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>生命偷取</font><br>", "effects": [{"attribute": "luck", "delta": 20}, {"attribute": "dodge", "delta": 6}, {"attribute": "lifeSteal", "delta": -2}]}, {"objectName": "alloy", "propName": "合金", "grade": 3, "type": "道具", "basePrice": 80, "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+3</font><font color='white'>远程伤害</font><br>\n<font color='lime'>+3</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+3</font><font color='white'>工程</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='red'>-6</font><font color='white'>闪避</font><br>", "effects": [{"attribute": "meleeDamage", "delta": 3}, {"attribute": "rangedDamage", "delta": 3}, {"attribute": "elementalDamage", "delta": 3}, {"attribute": "engineering", "delta": 3}, {"attribute": "critChance", "delta": 5}, {"attribute": "dodge", "delta": -6}]}, {"objectName": "toxic_tonics", "propName": "有毒补药", "grade": 3, "type": "道具", "basePrice": 80, "talentText": "<font color='lime'>+10</font><font color='white'>攻速</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+15</font><font color='white'>射程</font><br>\n<font color='red'>-2</font><font color='white'>生命恢复</font><br>", "effects": [{"attribute": "attackSpeed", "delta": 10}, {"attribute": "critChance", "delta": 5}, {"attribute": "range", "delta": 15}, {"attribute": "hpRegeneration", "delta": -2}]}, {"objectName": "shmoop", "propName": "休穆糖", "grade": 3, "type": "道具", "basePrice": 60, "talentText": "<font color='lime'>+6</font><font color='white'>最大生命</font><br>\n<font color='lime'>+2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-1</font><font color='white'>远程伤害</font><br>", "effects": [{"attribute": "maxHp", "delta": 6}, {"attribute": "hpRegeneration", "delta": 2}, {"attribute": "meleeDamage", "delta": -2}, {"attribute": "rangedDamage", "delta": -1}]}, {"objectName": "toolbox", "propName": "工具箱", "grade": 3, "type": "道具", "basePrice": 55, "talentText": "<font color='lime'>+6</font><font color='white'>工程</font><br>\n<font color='red'>-8</font><font color='white'>攻击速度</font><br>", "effects": [{"attribute": "engineering", "delta": 6}, {"attribute": "attackSpeed", "delta": -8}]}, {"objectName": "guard_helmet", "propName": "守卫头盔", "grade": 3, "type": "道具", "basePrice": 80, "talentText": "<font color='lime'>+3</font><font color='white'>护甲</font><br>\n<font color='lime'>+5</font><font color='white'>最大生命</font><br>\n<font color='red'>-5</font><font color='white'>速度</font><br>", "effects": [{"attribute": "armor", "delta": 3}, {"attribute": "maxHp", "delta": 5}, {"attribute": "speed", "delta": -5}]}, {"objectName": "glass_cannon", "propName": "玻璃大炮", "grade": 3, "type": "道具", "basePrice": 75, "talentText": "<font color='lime'>+25</font><font color='white'>伤害</font><br>\n<font color='red'>-3</font><font color='white'>护甲</font><br>", "effects": [{"attribute": "damage", "delta": 3}, {"attribute": "armor", "delta": -5}]}, {"objectName": "cloak", "propName": "斗篷", "grade": 4, "type": "道具", "basePrice": 110, "talentText": "<font color='lime'>+5</font><font color='white'>生命偷取</font><br>\n<font color='lime'>+20</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>远程伤害</font><br>\n<font color='red'>-2</font><font color='white'>元素伤害</font><br>", "effects": [{"attribute": "lifeSteal", "delta": 5}, {"attribute": "dodge", "delta": 20}, {"attribute": "meleeDamage", "delta": -2}, {"attribute": "rangedDamage", "delta": -2}, {"attribute": "elementalDamage", "delta": -2}]}, {"objectName": "exoskeleton", "propName": "外骨骼", "grade": 4, "type": "道具", "basePrice": 90, "talentText": "<font color='lime'>+5</font><font color='white'>护甲</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+5</font><font color='white'>工程</font><br>\n<font color='lime'>+5</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>生命偷取</font><br>", "effects": [{"attribute": "armor", "delta": 5}, {"attribute": "critChance", "delta": 5}, {"attribute": "engineering", "delta": 5}, {"attribute": "dodge", "delta": 5}, {"attribute": "hpRegeneration", "delta": -2}, {"attribute": "lifeSteal", "delta": -2}]}, {"objectName": "heavy_bullets", "propName": "重子弹", "grade": 4, "type": "道具", "basePrice": 100, "talentText": "<font color='lime'>+5</font><font color='white'>远程伤害</font><br>\n<font color='lime'>+10</font><font color='white'>伤害</font><br>\n<font color='lime'>+10</font><font color='white'>射程</font><br>\n<font color='red'>-5</font><font color='white'>攻击速度</font><br>\n<font color='red'>-5</font><font color='white'>暴击率</font><br>", "effects": [{"attribute": "rangedDamage", "delta": 5}, {"attribute": "damage", "delta": 10}, {"attribute": "range", "delta": 10}, {"attribute": "attackSpeed", "delta": -5}, {"attribute": "critChance", "delta": -5}]}]

// ============================================================
// 3. 角色数据
// ============================================================
var _ROLES_DATA = [
  { "objectName": "wellRounded", "roleName": "全能者", "talentText": "<font color='lime'>+5</font><font color='white'> 最大生命值</font><br>\n<font color='lime'>+5</font><font color='white'> %速度</font><br>\n<font color='lime'>+8</font><font color='white'> 收获</font>", "effects": [{ "attribute": "maxHp", "condition": "lt", "conditionValue": 15, "setTo": 15 }, { "attribute": "curHp", "setToProp": "maxHp" }, { "attribute": "speed", "condition": "lt", "conditionValue": 5, "setTo": 5 }, { "attribute": "harvesting", "condition": "lt", "conditionValue": 8, "setTo": 8 }] },
  { "objectName": "mutant", "roleName": "异变体", "talentText": "<font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>\n<font color='red'>+50</font><font color='white'> %道具价格</font>", "effects": [{ "attribute": "expDiscountRate", "condition": "lt", "conditionValue": 0.33, "setTo": 0.33 }, { "attribute": "goodsDiscountRate", "condition": "lt", "conditionValue": 1.5, "setTo": 1.5 }] }
]

// ============================================================
// 4. 升级选项数据
// ============================================================
var _UPGRADE_OPTIONS_DATA = [
  { "objectName": "leg", "optionName": "腿", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>%速度</font><br>", "effects": [{ "attribute": "speed", "deltaFromGrade": 3 }] },
  { "objectName": "chest", "optionName": "胸", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>护甲</font><br>", "effects": [{ "attribute": "armor", "deltaFromGrade": 1 }] },
  { "objectName": "skull", "optionName": "头骨", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>工程学</font><br>", "effects": [{ "attribute": "engineering", "deltaFromGrade": 2 }] },
  { "objectName": "lung", "optionName": "肺", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>生命恢复</font><br>", "effects": [{ "attribute": "hpRegeneration", "deltaFromGrade": 2 }] },
  { "objectName": "finger", "optionName": "手指", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>暴击率</font><br>", "effects": [{ "attribute": "critChance", "deltaFromGrade": 3 }] },
  { "objectName": "back", "optionName": "背", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>闪避</font><br>", "effects": [{ "attribute": "dodge", "deltaFromGrade": 3 }] },
  { "objectName": "teeth", "optionName": "牙齿", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>生命窃取</font><br>", "effects": [{ "attribute": "lifeSteal", "deltaFromGrade": 1 }] },
  { "objectName": "heart", "optionName": "心脏", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>最大生命值</font><br>", "effects": [{ "attribute": "maxHp", "deltaFromGrade": 3 }, { "attribute": "curHp", "deltaFromGrade": 3 }] },
  { "objectName": "brain", "optionName": "脑", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>元素伤害</font><br>", "effects": [{ "attribute": "elementalDamage", "deltaFromGrade": 1 }] },
  { "objectName": "reflexes", "optionName": "反应能力", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>攻击速度</font><br>", "effects": [{ "attribute": "attackSpeed", "deltaFromGrade": 5 }] },
  { "objectName": "nose", "optionName": "鼻", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>幸运</font><br>", "effects": [{ "attribute": "luck", "deltaFromGrade": 5 }] },
  { "objectName": "hand", "optionName": "手", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>收获</font><br>", "effects": [{ "attribute": "harvesting", "deltaFromGrade": 5 }] },
  { "objectName": "shoulder", "optionName": "肩", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>远程伤害</font><br>", "effects": [{ "attribute": "rangedDamage", "deltaFromGrade": 1 }] },
  { "objectName": "foream", "optionName": "前臂", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>近战伤害</font><br>", "effects": [{ "attribute": "meleeDamage", "deltaFromGrade": 2 }] },
  { "objectName": "triceps", "optionName": "三头肌", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>伤害</font><br>", "effects": [{ "attribute": "damage", "deltaFromGrade": 5 }] },
  { "objectName": "eyes", "optionName": "眼睛", "grade": 1, "type": "升级", "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>范围</font><br>", "effects": [{ "attribute": "range", "deltaFromGrade": 15 }] }
]

// ============================================================
// 5. 怪物数据
// ============================================================
var _MONSTERS_DATA = [
  { "objectName": "tree", "monsterName": "树", "source": "Tree.qml", "attackRange": 0, "maxCurNumber": 20, "initHp": 3, "hpBonus": 2, "initVelocity": 0, "maxVelocity": 0, "initDamage": 0, "damageBonus": 0, "materialDrops": 3, "consumableDropRate": 1, "chestDropRate": 0.05 },
  { "objectName": "babyAlien", "monsterName": "外星婴儿", "source": "BabyAlien.qml", "attackRange": 0, "maxCurNumber": 50, "initHp": 3, "hpBonus": 2, "initVelocity": 250, "maxVelocity": 300, "initDamage": 1, "damageBonus": 0.6, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "chaser", "monsterName": "追逐者", "source": "Chaser.qml", "attackRange": 0, "maxCurNumber": 25, "initHp": 1, "hpBonus": 1, "initVelocity": 380, "maxVelocity": 380, "initDamage": 1, "damageBonus": 0.6, "materialDrops": 1, "consumableDropRate": 0.02, "chestDropRate": 0.03 },
  { "objectName": "sprayer", "monsterName": "喷射者", "source": "Sprayer.qml", "attackRange": 400, "maxCurNumber": 15, "initHp": 8, "hpBonus": 1, "initVelocity": 200, "maxVelocity": 200, "initDamage": 1, "damageBonus": 0.6, "materialDrops": 1, "consumableDropRate": 0.03, "chestDropRate": 0.1 },
  { "objectName": "charger", "monsterName": "冲锋者", "source": "Charger.qml", "attackRange": 200, "maxCurNumber": 15, "initHp": 4, "hpBonus": 2.5, "initVelocity": 400, "maxVelocity": 400, "initDamage": 1, "damageBonus": 0.85, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "brute", "monsterName": "大块头", "source": "Brute.qml", "attackRange": 300, "maxCurNumber": 10, "initHp": 20, "hpBonus": 11, "initVelocity": 300, "maxVelocity": 300, "initDamage": 2, "damageBonus": 0.85, "materialDrops": 3, "consumableDropRate": 0.03, "chestDropRate": 0.03 },
  { "objectName": "pursuer", "monsterName": "追击者", "source": "Pursuer.qml", "attackRange": 0, "maxCurNumber": 10, "initHp": 10, "hpBonus": 2.4, "initVelocity": 150, "maxVelocity": 600, "initDamage": 1, "damageBonus": 1.5, "materialDrops": 3, "consumableDropRate": 0.03, "chestDropRate": 0.03 },
  { "objectName": "helmetAlien", "monsterName": "戴头盔的外星人", "source": "HelmetAlien.qml", "attackRange": 0, "maxCurNumber": 30, "initHp": 8, "hpBonus": 3, "initVelocity": 225, "maxVelocity": 275, "initDamage": 1, "damageBonus": 1, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "finChaser", "monsterName": "鱼鳍追逐者", "source": "FinChaser.qml", "attackRange": 0, "maxCurNumber": 25, "initHp": 12, "hpBonus": 2, "initVelocity": 400, "maxVelocity": 400, "initDamage": 1, "damageBonus": 1, "materialDrops": 1, "consumableDropRate": 0.02, "chestDropRate": 0.03 },
  { "objectName": "summoner", "monsterName": "召唤者", "source": "Summoner.qml", "attackRange": 0, "maxCurNumber": 10, "initHp": 10, "hpBonus": 1, "initVelocity": 120, "maxVelocity": 120, "initDamage": 1, "damageBonus": 0.85, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "scavenger", "monsterName": "拾荒者", "source": "Scavenger.qml", "attackRange": 10000, "maxCurNumber": 30, "initHp": 20, "hpBonus": 5, "initVelocity": 350, "maxVelocity": 350, "initDamage": 1, "damageBonus": 1, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "helmetBrute", "monsterName": "头盔大块头", "source": "HelmetBrute.qml", "attackRange": 300, "maxCurNumber": 10, "initHp": 30, "hpBonus": 22, "initVelocity": 300, "maxVelocity": 300, "initDamage": 1, "damageBonus": 1.15, "materialDrops": 3, "consumableDropRate": 0.03, "chestDropRate": 0.03 },
  { "objectName": "helmetCharger", "monsterName": "头盔冲锋者", "source": "HelmetCharger.qml", "attackRange": 200, "maxCurNumber": 15, "initHp": 12, "hpBonus": 5, "initVelocity": 425, "maxVelocity": 425, "initDamage": 1, "damageBonus": 1, "materialDrops": 1, "consumableDropRate": 0.01, "chestDropRate": 0.01 },
  { "objectName": "prayer", "monsterName": "祈祷者", "source": "Prayer.qml", "attackRange": 10000, "maxCurNumber": 1, "initHp": 29900, "hpBonus": 0, "initVelocity": 175, "maxVelocity": 175, "initDamage": 30, "damageBonus": 1.5, "materialDrops": 10, "consumableDropRate": 0, "chestDropRate": 0 }
]

// ============================================================
// 6. 波次数据
// ============================================================
var _WAVES_DATA = [
  { "wave": 1, "spawns": [ { "monster": "babyAlien", "initCount": 4 } ] },
  { "wave": 2, "spawns": [ { "monster": "babyAlien", "initCount": 4 }, { "monster": "chaser", "initCount": 3 } ] },
  { "wave": 3, "spawns": [ { "monster": "babyAlien", "initCount": 5 }, { "monster": "chaser", "initCount": 3 } ] },
  { "wave": 4, "spawns": [ { "monster": "babyAlien", "initCount": 6 }, { "monster": "sprayer", "initCount": 2 } ] },
  { "wave": 5, "spawns": [ { "monster": "babyAlien", "initCount": 4 }, { "monster": "chaser", "initCount": 3 }, { "monster": "sprayer", "initCount": 1 } ] },
  { "wave": 6, "spawns": [ { "monster": "babyAlien", "initCount": 7 }, { "monster": "chaser", "initCount": 3 }, { "monster": "charger", "initCount": 4 } ] },
  { "wave": 7, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "charger", "initCount": 6 }, { "monster": "sprayer", "initCount": 3 } ] },
  { "wave": 8, "spawns": [ { "monster": "babyAlien", "initCount": 4 }, { "monster": "sprayer", "initCount": 2 }, { "monster": "brute", "initCount": 3 } ] },
  { "wave": 9, "spawns": [ { "monster": "chaser", "initCount": 6 }, { "monster": "charger", "initCount": 2 }, { "monster": "brute", "initCount": 2 } ] },
  { "wave": 10, "spawns": [ { "monster": "babyAlien", "initCount": 4 }, { "monster": "chaser", "initCount": 4 }, { "monster": "charger", "initCount": 2 }, { "monster": "brute", "initCount": 1 } ] },
  { "wave": 11, "spawns": [ { "monster": "babyAlien", "initCount": 4 }, { "monster": "charger", "initCount": 4 }, { "monster": "sprayer", "initCount": 2 }, { "monster": "pursuer", "initCount": 1 } ] },
  { "wave": 12, "spawns": [ { "monster": "babyAlien", "initCount": 5 }, { "monster": "charger", "initCount": 4 }, { "monster": "pursuer", "initCount": 1 }, { "monster": "brute", "initCount": 2 } ] },
  { "wave": 13, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "charger", "initCount": 3 }, { "monster": "pursuer", "initCount": 1 }, { "monster": "brute", "initCount": 1 }, { "monster": "helmetBrute", "initCount": 2 }, { "monster": "helmetAlien", "initCount": 3 } ] },
  { "wave": 14, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "brute", "initCount": 1 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "summoner", "initCount": 1 } ] },
  { "wave": 15, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "sprayer", "initCount": 1 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "summoner", "initCount": 1 }, { "monster": "finChaser", "initCount": 3 } ] },
  { "wave": 16, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "brute", "initCount": 1 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "finChaser", "initCount": 3 }, { "monster": "helmetBrute", "initCount": 1 } ] },
  { "wave": 17, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "pursuer", "initCount": 2 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "finChaser", "initCount": 3 }, { "monster": "summoner", "initCount": 1 } ] },
  { "wave": 18, "spawns": [ { "monster": "sprayer", "initCount": 2 }, { "monster": "helmetAlien", "initCount": 5 }, { "monster": "summoner", "initCount": 1 }, { "monster": "helmetCharger", "initCount": 3 } ] },
  { "wave": 19, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "sprayer", "initCount": 2 }, { "monster": "pursuer", "initCount": 2 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "summoner", "initCount": 1 }, { "monster": "helmetBrute", "initCount": 2 }, { "monster": "helmetCharger", "initCount": 3 } ] },
  { "wave": 20, "spawns": [ { "monster": "babyAlien", "initCount": 3 }, { "monster": "sprayer", "initCount": 2 }, { "monster": "pursuer", "initCount": 2 }, { "monster": "helmetAlien", "initCount": 4 }, { "monster": "finChaser", "initCount": 3 }, { "monster": "summoner", "initCount": 1 }, { "monster": "helmetBrute", "initCount": 2 }, { "monster": "prayer", "initCount": 1 } ] }
]

// ---- 数据缓存（懒加载填充） ----
var _weapons = null
var _props = null
var _roles = null
var _upgradeOptions = null
var _monsters = null
var _waves = null

var _propsByGrade = null
var _weaponsByGrade = null
var _upgradeOptionsByGrade = null

// ---- 内部：确保所有数据已加载 ----
function _ensureLoaded() {
    if (_weapons !== null) return

    _weapons = _WEAPONS_DATA
    _props = _PROPS_DATA
    _roles = _ROLES_DATA
    _upgradeOptions = _UPGRADE_OPTIONS_DATA
    _monsters = _MONSTERS_DATA
    _waves = _WAVES_DATA

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
function _weightedRandomSelect(candidatesByGrade, gradeWeights, count) {
    if (count <= 0) return []
    var totalWeight = gradeWeights[1] + gradeWeights[2] + gradeWeights[3] + gradeWeights[4]
    var result = []
    var usedIndices = {}

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
            for (var g = 1; g <= 4; g++) {
                if (candidatesByGrade[g] && candidatesByGrade[g].length > 0) {
                    pool = candidatesByGrade[g]
                    grade = g
                    break
                }
            }
        }
        if (!pool || pool.length === 0) break

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

// ============================================================
// 公开查询接口
// ============================================================

// ---- 武器 ----
function getAllWeapons() {
    _ensureLoaded()
    return _deepCopy(_weapons)
}

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

function getWeaponGradeCounts() {
    _ensureLoaded()
    return { 1: _weaponsByGrade[1].length, 2: 0, 3: 0, 4: 0 }
}

// ---- 道具 ----
function getProp(objectName) {
    _ensureLoaded()
    for (var i = 0; i < _props.length; i++) {
        if (_props[i].objectName === objectName || _props[i].propName === objectName) {
            return _deepCopy(_props[i])
        }
    }
    if (objectName !== "") console.error("DataLoader.getProp: '" + objectName + "' not found")
    return { grade: 1, objectName: "", propName: "", type: "", talentText: "", basePrice: 0, effects: [] }
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
function getAllRoles() {
    _ensureLoaded()
    return _deepCopy(_roles)
}

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
function applyEffects(effects, playerData) {
    if (!effects || !playerData) return
    for (var i = 0; i < effects.length; i++) {
        var eff = effects[i]
        if (eff.condition === "lt") {
            if (playerData[eff.attribute] < eff.conditionValue) {
                playerData[eff.attribute] = eff.setTo
            }
        } else if (eff.setToProp) {
            playerData[eff.attribute] = playerData[eff.setToProp]
        } else if (eff.delta !== undefined) {
            playerData[eff.attribute] += eff.delta
        } else if (eff.deltaFromGrade !== undefined) {
            var grade = eff.grade || 1
            playerData[eff.attribute] += eff.deltaFromGrade * grade
        }
    }
}

// ---- 模板渲染 (升级选项 talentText) ----
function renderTalentText(template, grade) {
    if (!template) return ""
    return template.replace(/\{\{value\}\}/g, String(grade))
}

// ---- 武器 talentText 动态渲染 ----
function renderWeaponTalentText(weapon, playerData) {
    if (!weapon || !playerData) return ""
    var dmg = weapon.baseDamage
    if (weapon.meleeDamageMultiplier !== undefined) {
        dmg = Math.floor(Math.max((dmg + playerData.meleeDamage * weapon.meleeDamageMultiplier) * (1 + playerData.damage / 100), 1))
        var crit = 3 + playerData.critChance
        var cd = weapon.baseCooldown / (1 + playerData.attackSpeed / 100)
        return "<font color='#ffffc0'>伤害 : </font><font color='white'>" + dmg + "(+100%近战伤害)</font><br>\n"
            + "<font color='#ffffc0'>暴击 : </font><font color='white'>x2.0(" + crit + "%概率)</font><br>\n"
            + "<font color='#ffffc0'>冷却 : </font><font color='white'>" + cd.toFixed(2) + "</font><br>\n"
            + "<font color='#ffffc0'>范围 : </font><font color='white'>" + (weapon.baseRange + playerData.range) + "(近战)</font><br>"
    }
    if (weapon.rangedDamageMultiplier !== undefined) {
        dmg = Math.floor(Math.max((dmg + playerData.rangedDamage * weapon.rangedDamageMultiplier) * (1 + playerData.damage / 100), 1))
        var crit = 1 + playerData.critChance
        var cd = weapon.baseCooldown / (1 + playerData.attackSpeed / 100)
        return "<font color='#ffffc0'>伤害 : </font><font color='white'>" + dmg + "(+50%远程伤害)</font><br>\n"
            + "<font color='#ffffc0'>暴击 : </font><font color='white'>x1.5(" + crit + "%概率)</font><br>\n"
            + "<font color='#ffffc0'>冷却 : </font><font color='white'>" + cd.toFixed(2) + "</font><br>\n"
            + "<font color='#ffffc0'>范围 : </font><font color='white'>" + (weapon.baseRange + playerData.range) + "(远战)</font><br>"
    }
    return ""
}
