.pragma library

// ============================================================================
// DataLoader — 游戏数据加载与查询模块
// 内联数据由 tools/sync_data.py 从 data/json/*.json 自动同步
// 改 data/json/*.json 后运行 python3 tools/sync_data.py 或重新构建即可
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
      {
        "grade": 1,
        "baseDamage": 15,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.52,
        "baseRange": 350,
        "basePrice": 20
      },
      {
        "grade": 2,
        "baseDamage": 25,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.4,
        "baseRange": 375,
        "basePrice": 39
      },
      {
        "grade": 3,
        "baseDamage": 40,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.28,
        "baseRange": 400,
        "basePrice": 74
      },
      {
        "grade": 4,
        "baseDamage": 60,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.24,
        "baseRange": 500,
        "basePrice": 149
      }
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
      {
        "grade": 1,
        "baseDamage": 3,
        "rangedDamageMultiplier": 0.5,
        "baseCooldown": 0.17,
        "baseRange": 400,
        "basePrice": 20
      },
      {
        "grade": 2,
        "baseDamage": 4,
        "rangedDamageMultiplier": 0.6,
        "baseCooldown": 0.17,
        "baseRange": 400,
        "basePrice": 39
      },
      {
        "grade": 3,
        "baseDamage": 5,
        "rangedDamageMultiplier": 0.7,
        "baseCooldown": 0.17,
        "baseRange": 400,
        "basePrice": 74
      },
      {
        "grade": 4,
        "baseDamage": 8,
        "rangedDamageMultiplier": 0.8,
        "baseCooldown": 0.17,
        "baseRange": 400,
        "basePrice": 149
      }
    ]
  },
  {
    "objectName": "ice_cone",
    "weaponName": "冰锥",
    "type": "元素",
    "source": "IceCone.qml",
    "aspectRatio": 0.322,
    "scaleRatio": 1.0,
    "xOffset": -2,
    "yOffset": 0,
    "handX": 9,
    "handY": 16,
    "inherentPenetrate": 1,
    "inherentPenetrateMultiplier": 0.5,
    "accuracy": [
      0.85,
      0.9,
      0.95,
      1.0
    ],
    "grades": [
      {
        "grade": 1,
        "baseDamage": 10,
        "elementalDamageMultiplier": 1.0,
        "baseCooldown": 1.03,
        "baseRange": 400,
        "baseKnockback": 5,
        "basePrice": 20
      },
      {
        "grade": 2,
        "baseDamage": 20,
        "elementalDamageMultiplier": 1.0,
        "baseCooldown": 0.95,
        "baseRange": 400,
        "baseKnockback": 5,
        "basePrice": 39
      },
      {
        "grade": 3,
        "baseDamage": 30,
        "elementalDamageMultiplier": 1.0,
        "baseCooldown": 0.87,
        "baseRange": 400,
        "baseKnockback": 5,
        "basePrice": 74
      },
      {
        "grade": 4,
        "baseDamage": 40,
        "elementalDamageMultiplier": 1.0,
        "baseCooldown": 0.7,
        "baseRange": 400,
        "baseKnockback": 5,
        "basePrice": 149
      }
    ]
  },
  {
    "objectName": "wrench",
    "weaponName": "扳手",
    "implemented": false,
    "type": "工具",
    "source": "Wrench.qml",
    "aspectRatio": 0.1634,
    "scaleRatio": 2.5,
    "xOffset": -22,
    "yOffset": -5,
    "handX": 22.5,
    "handY": 7.5,
    "grades": [
      {
        "grade": 1,
        "baseDamage": 12,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.7,
        "baseRange": 175,
        "basePrice": 20
      },
      {
        "grade": 2,
        "baseDamage": 16,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.64,
        "baseRange": 175,
        "basePrice": 39
      },
      {
        "grade": 3,
        "baseDamage": 20,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.55,
        "baseRange": 175,
        "basePrice": 74
      },
      {
        "grade": 4,
        "baseDamage": 24,
        "meleeDamageMultiplier": 1.0,
        "baseCooldown": 1.49,
        "baseRange": 175,
        "basePrice": 149
      }
    ]
  },
  {
    "objectName": "screwdriver",
    "weaponName": "螺丝刀",
    "implemented": false,
    "type": "工具",
    "source": "Screwdriver.qml",
    "aspectRatio": 0.1634,
    "scaleRatio": 2.5,
    "xOffset": -22,
    "yOffset": -5,
    "handX": 22.5,
    "handY": 7.5,
    "grades": [
      {
        "grade": 1,
        "baseDamage": 8,
        "meleeDamageMultiplier": 0.5,
        "baseCooldown": 1.05,
        "baseRange": 125,
        "basePrice": 10
      },
      {
        "grade": 2,
        "baseDamage": 12,
        "meleeDamageMultiplier": 0.5,
        "baseCooldown": 1.0,
        "baseRange": 125,
        "basePrice": 22
      },
      {
        "grade": 3,
        "baseDamage": 16,
        "meleeDamageMultiplier": 0.5,
        "baseCooldown": 0.97,
        "baseRange": 125,
        "basePrice": 45
      },
      {
        "grade": 4,
        "baseDamage": 20,
        "meleeDamageMultiplier": 0.5,
        "baseCooldown": 0.87,
        "baseRange": 125,
        "basePrice": 91
      }
    ]
  },
  {
    "objectName": "flamethrower",
    "weaponName": "火焰喷射器",
    "implemented": false,
    "type": "元素",
    "source": "SMG.qml",
    "aspectRatio": 0.683,
    "scaleRatio": 1.0,
    "xOffset": -2,
    "yOffset": 0,
    "handX": 9,
    "handY": 16,
    "grades": [
      {
        "grade": 1,
        "baseDamage": 4,
        "elementalDamageMultiplier": 1.0,
        "baseCooldown": 0.25,
        "baseRange": 300,
        "basePrice": 25
      },
      {
        "grade": 2,
        "baseDamage": 6,
        "elementalDamageMultiplier": 1.2,
        "baseCooldown": 0.25,
        "baseRange": 320,
        "basePrice": 45
      },
      {
        "grade": 3,
        "baseDamage": 9,
        "elementalDamageMultiplier": 1.5,
        "baseCooldown": 0.25,
        "baseRange": 340,
        "basePrice": 85
      },
      {
        "grade": 4,
        "baseDamage": 14,
        "elementalDamageMultiplier": 2.0,
        "baseCooldown": 0.25,
        "baseRange": 360,
        "basePrice": 169
      }
    ]
  }
]

// ============================================================
// 2. 道具数据
// ============================================================
var _PROPS_DATA = [
  {
    "objectName": "wellRounded",
    "propName": "全能者",
    "grade": 5,
    "type": "角色",
    "basePrice": 0,
    "talentText": "<font color='lime'>+5</font><font color='white'> 最大生命值</font><br>\n<font color='lime'>+5</font><font color='white'> %速度</font><br>\n<font color='lime'>+8</font><font color='white'> 收获</font>",
    "effects": [
      {
        "attribute": "maxHp",
        "condition": "lt",
        "conditionValue": 15,
        "setTo": 15
      },
      {
        "attribute": "curHp",
        "setToProp": "maxHp"
      },
      {
        "attribute": "speed",
        "condition": "lt",
        "conditionValue": 5,
        "setTo": 5
      },
      {
        "attribute": "harvesting",
        "condition": "lt",
        "conditionValue": 8,
        "setTo": 8
      }
    ]
  },
  {
    "objectName": "mutant",
    "propName": "异变体",
    "grade": 5,
    "type": "角色",
    "basePrice": 0,
    "talentText": "<font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>\n<font color='red'>+50</font><font color='white'> %道具价格</font>",
    "effects": [
      {
        "attribute": "expDiscountRate",
        "condition": "lt",
        "conditionValue": 0.33,
        "setTo": 0.33
      },
      {
        "attribute": "goodsDiscountRate",
        "condition": "lt",
        "conditionValue": 1.5,
        "setTo": 1.5
      }
    ]
  },
  {
    "objectName": "bat",
    "propName": "蝙蝠",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+2</font><font color='white'>生命窃取</font><br>\n<font color='red'>-2</font><font color='white'>收获</font><br>",
    "effects": [
      {
        "attribute": "lifeSteal",
        "delta": 2
      },
      {
        "attribute": "harvesting",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "hedgehog",
    "propName": "刺猬",
    "grade": 1,
    "type": "道具",
    "basePrice": 30,
    "talentText": "<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+1</font><font color='white'>远程伤害</font><br>\n<font color='red'>-1</font><font color='white'>生命恢复</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 2
      },
      {
        "attribute": "rangedDamage",
        "delta": 1
      },
      {
        "attribute": "hpRegeneration",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "helmet",
    "propName": "头盔",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='red'>-2</font><font color='white'>速度</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "delta": 1
      },
      {
        "attribute": "speed",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "rubber_berserker",
    "propName": "橡皮狂暴战士",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+5</font><font color='white'> 攻击速度</font><br>\n<font color='lime'>+15</font><font color='white'>射程</font><br>\n<font color='red'>-1</font><font color='white'>护甲</font><br>",
    "effects": [
      {
        "attribute": "attackSpeed",
        "delta": 5
      },
      {
        "attribute": "range",
        "delta": 15
      },
      {
        "attribute": "armor",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "brain_injury",
    "propName": "颅脑损伤",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+6</font><font color='white'>伤害</font><br>\n<font color='red'>-8</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "damage",
        "delta": 6
      },
      {
        "attribute": "attackSpeed",
        "delta": -8
      }
    ]
  },
  {
    "objectName": "coffee",
    "propName": "咖啡",
    "grade": 1,
    "type": "道具",
    "basePrice": 15,
    "talentText": "<font color='lime'>+10</font><font color='white'>攻速</font><br>\n<font color='red'>-2</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "attackSpeed",
        "delta": 10
      },
      {
        "attribute": "damage",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "claw_tree",
    "propName": "爪子树",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+1</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+3</font><font color='white'>暴击率</font><br>\n<font color='red'>-1</font><font color='white'>最大生命值</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 1
      },
      {
        "attribute": "critChance",
        "delta": 3
      },
      {
        "attribute": "maxHp",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "boiling_water",
    "propName": "沸水",
    "grade": 1,
    "type": "道具",
    "basePrice": 30,
    "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-1</font><font color='white'>最大生命值</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "delta": 2
      },
      {
        "attribute": "maxHp",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "book",
    "propName": "书",
    "grade": 1,
    "type": "道具",
    "basePrice": 8,
    "talentText": "<font color='lime'>+1</font><font color='white'>工程</font><br>",
    "effects": [
      {
        "attribute": "engineering",
        "delta": 1
      }
    ]
  },
  {
    "objectName": "break_through",
    "propName": "破口",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+5</font><font color='white'>最大生命值</font><br>\n<font color='red'>-1</font><font color='white'>生命恢复</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 5
      },
      {
        "attribute": "hpRegeneration",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "butterfly",
    "propName": "蝴蝶",
    "grade": 1,
    "type": "道具",
    "basePrice": 30,
    "talentText": "<font color='lime'>+2</font><font color='white'>生命偷取</font><br>\n<font color='red'>-1</font><font color='white'>元素伤害</font><br>",
    "effects": [
      {
        "attribute": "lifeSteal",
        "delta": 2
      },
      {
        "attribute": "elementalDamage",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "defective_steroids",
    "propName": "有缺陷的类固醇",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+2</font><font color='white'>最大生命值</font><br>\n<font color='red'>-3</font><font color='white'>攻击速度</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 2
      },
      {
        "attribute": "maxHp",
        "delta": 2
      },
      {
        "attribute": "attackSpeed",
        "delta": -3
      }
    ]
  },
  {
    "objectName": "duct_tape",
    "propName": "牛皮胶布",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='lime'>+1</font><font color='white'>工程</font><br>\n<font color='red'>-2</font><font color='white'>最大生命</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "delta": 1
      },
      {
        "attribute": "engineering",
        "delta": 1
      },
      {
        "attribute": "maxHp",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "cake",
    "propName": "蛋糕",
    "grade": 1,
    "type": "道具",
    "basePrice": 15,
    "talentText": "<font color='lime'>+3</font><font color='white'>最大生命</font><br>\n<font color='red'>-1</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 3
      },
      {
        "attribute": "damage",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "glasses",
    "propName": "眼镜",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+20</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "range",
        "delta": 20
      }
    ]
  },
  {
    "objectName": "goat_skull",
    "propName": "山羊头骨",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>暴击率</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 3
      },
      {
        "attribute": "critChance",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "yarmulke",
    "propName": "小圆帽",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+4</font><font color='white'>速度</font><br>\n<font color='red'>-6</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "speed",
        "delta": 4
      },
      {
        "attribute": "range",
        "delta": -6
      }
    ]
  },
  {
    "objectName": "injection",
    "propName": "注射",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+7</font><font color='white'>伤害</font><br>\n<font color='red'>-2</font><font color='white'>最大生命</font><br>",
    "effects": [
      {
        "attribute": "damage",
        "delta": 7
      },
      {
        "attribute": "maxHp",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "insane",
    "propName": "精神错乱",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+6</font><font color='white'>暴击率</font><br>\n<font color='red'>-3</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "critChance",
        "delta": 6
      },
      {
        "attribute": "damage",
        "delta": -3
      }
    ]
  },
  {
    "objectName": "lens",
    "propName": "镜头",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+1</font><font color='white'>远程伤害</font><br>\n<font color='red'>-5</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "rangedDamage",
        "delta": 1
      },
      {
        "attribute": "range",
        "delta": -5
      }
    ]
  },
  {
    "objectName": "lost_duck",
    "propName": "迷失之鸭",
    "grade": 1,
    "type": "道具",
    "basePrice": 25,
    "talentText": "<font color='lime'>+10</font><font color='white'>运气</font><br>\n<font color='red'>-1</font><font color='white'>元素伤害</font><br>",
    "effects": [
      {
        "attribute": "luck",
        "delta": 10
      },
      {
        "attribute": "elementalDamage",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "propeller_hat",
    "propName": "螺旋桨帽子",
    "grade": 1,
    "type": "道具",
    "basePrice": 28,
    "talentText": "<font color='lime'>+10</font><font color='white'>运气</font><br>\n<font color='red'>-2</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "luck",
        "delta": 10
      },
      {
        "attribute": "damage",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "terrifying_onion",
    "propName": "恐怖洋葱",
    "grade": 1,
    "type": "道具",
    "basePrice": 15,
    "talentText": "<font color='lime'>+4</font><font color='white'>速度</font><br>\n<font color='red'>-6</font><font color='white'>运气</font><br>",
    "effects": [
      {
        "attribute": "speed",
        "delta": 4
      },
      {
        "attribute": "luck",
        "delta": -6
      }
    ]
  },
  {
    "objectName": "toxic_sludge",
    "propName": "有毒的烂泥",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-2</font><font color='white'>闪避</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "delta": 2
      },
      {
        "attribute": "dodge",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "coal",
    "propName": "煤炭",
    "grade": 1,
    "type": "道具",
    "basePrice": 20,
    "talentText": "<font color='lime'>+1</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>收获</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "delta": 1
      },
      {
        "attribute": "meleeDamage",
        "delta": 2
      },
      {
        "attribute": "harvesting",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "fertilizer",
    "propName": "肥料",
    "grade": 1,
    "type": "道具",
    "basePrice": 15,
    "talentText": "<font color='lime'>+8</font><font color='white'>收获</font><br>\n<font color='red'>-2</font><font color='white'>近战伤害</font><br>",
    "effects": [
      {
        "attribute": "harvesting",
        "delta": 8
      },
      {
        "attribute": "meleeDamage",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "acid_liquor",
    "propName": "酸液",
    "grade": 2,
    "type": "道具",
    "basePrice": 65,
    "talentText": "<font color='lime'>+8</font><font color='white'>最大生命值</font><br>\n<font color='red'>-4</font><font color='white'>闪避</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 8
      },
      {
        "attribute": "dodge",
        "delta": -4
      }
    ]
  },
  {
    "objectName": "energy_bracelet",
    "propName": "能量手镯",
    "grade": 2,
    "type": "道具",
    "basePrice": 55,
    "talentText": "<font color='lime'>+4</font><font color='white'>暴击率</font><br>\n<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='red'>-2</font><font color='white'>远程伤害</font><br>",
    "effects": [
      {
        "attribute": "critChance",
        "delta": 4
      },
      {
        "attribute": "elementalDamage",
        "delta": 2
      },
      {
        "attribute": "rangedDamage",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "gear",
    "propName": "齿轮",
    "grade": 2,
    "type": "道具",
    "basePrice": 35,
    "talentText": "<font color='lime'>+4</font><font color='white'>工程</font><br>\n<font color='red'>-4</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "engineering",
        "delta": 4
      },
      {
        "attribute": "damage",
        "delta": -4
      }
    ]
  },
  {
    "objectName": "cyclops_beetle",
    "propName": "独眼虫",
    "grade": 2,
    "type": "道具",
    "basePrice": 45,
    "talentText": "<font color='lime'>+12</font><font color='white'>伤害</font><br>\n<font color='red'>-12</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "damage",
        "delta": 12
      },
      {
        "attribute": "range",
        "delta": -12
      }
    ]
  },
  {
    "objectName": "fuel_tank",
    "propName": "燃料箱",
    "grade": 2,
    "type": "道具",
    "basePrice": 45,
    "talentText": "<font color='lime'>+4</font><font color='white'>元素伤害</font><br>\n<font color='red'>-1</font><font color='white'>近战伤害</font><br>\n<font color='red'>-1</font><font color='white'>远程伤害</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "delta": 4
      },
      {
        "attribute": "meleeDamage",
        "delta": -1
      },
      {
        "attribute": "rangedDamage",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "chip",
    "propName": "筹码",
    "grade": 2,
    "type": "道具",
    "basePrice": 60,
    "talentText": "<font color='lime'>+8</font><font color='white'>闪避</font><br>\n<font color='red'>-1</font><font color='white'>护甲</font><br>",
    "effects": [
      {
        "attribute": "dodge",
        "delta": 8
      },
      {
        "attribute": "armor",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "campfire",
    "propName": "营火",
    "grade": 2,
    "type": "道具",
    "basePrice": 40,
    "talentText": "<font color='lime'>+2</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>速度</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "delta": 2
      },
      {
        "attribute": "hpRegeneration",
        "delta": 2
      },
      {
        "attribute": "speed",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "black_belt",
    "propName": "黑带",
    "grade": 2,
    "type": "道具",
    "basePrice": 50,
    "talentText": "<font color='lime'>+25</font><font color='white'>经验获取</font><br>\n<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='red'>-8</font><font color='white'>运气</font><br>",
    "notes": "TODO: 经验获取属性未实现",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 3
      },
      {
        "attribute": "luck",
        "delta": -8
      },
      {
        "attribute": "gainExperience",
        "delta": 25
      }
    ]
  },
  {
    "objectName": "patch",
    "propName": "眼罩",
    "grade": 2,
    "type": "道具",
    "basePrice": 45,
    "talentText": "<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+5</font><font color='white'>闪避</font><br>\n<font color='red'>-15</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "critChance",
        "delta": 5
      },
      {
        "attribute": "dodge",
        "delta": 5
      },
      {
        "attribute": "range",
        "delta": -15
      }
    ]
  },
  {
    "objectName": "flag",
    "propName": "旗帜",
    "grade": 2,
    "type": "道具",
    "basePrice": 55,
    "talentText": "<font color='lime'>+20</font><font color='white'>射程</font><br>\n<font color='lime'>+10</font><font color='white'>攻击速度</font><br>\n<font color='red'>-2</font><font color='white'>生命窃取</font><br>",
    "effects": [
      {
        "attribute": "range",
        "delta": 20
      },
      {
        "attribute": "attackSpeed",
        "delta": 10
      },
      {
        "attribute": "lifeSteal",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "leather_vest",
    "propName": "皮制背心",
    "grade": 2,
    "type": "道具",
    "basePrice": 45,
    "talentText": "<font color='lime'>+2</font><font color='white'>护甲</font><br>\n<font color='lime'>+6</font><font color='white'>闪避</font><br>\n<font color='red'>-3</font><font color='white'>最大生命</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "delta": 2
      },
      {
        "attribute": "dodge",
        "delta": 6
      },
      {
        "attribute": "maxHp",
        "delta": -3
      }
    ]
  },
  {
    "objectName": "small_muscle_man",
    "propName": "小肌肉男",
    "grade": 2,
    "type": "道具",
    "basePrice": 50,
    "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+5</font><font color='white'>最大生命</font><br>\n<font color='red'>-15</font><font color='white'>射程</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 3
      },
      {
        "attribute": "maxHp",
        "delta": 5
      },
      {
        "attribute": "range",
        "delta": -15
      }
    ]
  },
  {
    "objectName": "master",
    "propName": "精通",
    "grade": 2,
    "type": "道具",
    "basePrice": 55,
    "talentText": "<font color='lime'>+6</font><font color='white'>近战伤害</font><br>\n<font color='red'>-3</font><font color='white'>远程伤害</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 6
      },
      {
        "attribute": "rangedDamage",
        "delta": -3
      }
    ]
  },
  {
    "objectName": "medal",
    "propName": "奖牌",
    "grade": 2,
    "type": "道具",
    "basePrice": 55,
    "talentText": "<font color='lime'>+3</font><font color='white'>伤害</font><br>\n<font color='lime'>+3</font><font color='white'>速度</font><br>\n<font color='lime'>+1</font><font color='white'>护甲</font><br>\n<font color='lime'>+3</font><font color='white'>最大生命</font><br>\n<font color='red'>-4</font><font color='white'>暴击率</font><br>",
    "effects": [
      {
        "attribute": "damage",
        "delta": 3
      },
      {
        "attribute": "speed",
        "delta": 3
      },
      {
        "attribute": "armor",
        "delta": 1
      },
      {
        "attribute": "maxHp",
        "delta": 3
      },
      {
        "attribute": "critChance",
        "delta": -4
      }
    ]
  },
  {
    "objectName": "alien_baby",
    "propName": "外星人宝宝",
    "grade": 3,
    "type": "道具",
    "basePrice": 80,
    "talentText": "<font color='lime'>+15</font><font color='white'>最大生命值</font><br>\n<font color='lime'>+8</font><font color='white'>敌人移动速度</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 15
      },
      {
        "attribute": "enemySpeed",
        "delta": 8
      }
    ]
  },
  {
    "objectName": "alien_magic",
    "propName": "外星人魔法",
    "grade": 3,
    "type": "道具",
    "basePrice": 85,
    "talentText": "<font color='lime'>+8</font><font color='white'>最大生命值</font><br>\n<font color='lime'>+3</font><font color='white'>生命恢复</font><br>\n<font color='red'>-8</font><font color='white'>运气</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 8
      },
      {
        "attribute": "hpRegeneration",
        "delta": 3
      },
      {
        "attribute": "luck",
        "delta": -8
      }
    ]
  },
  {
    "objectName": "clover",
    "propName": "四叶草",
    "grade": 3,
    "type": "道具",
    "basePrice": 65,
    "talentText": "<font color='lime'>+20</font><font color='white'>运气</font><br>\n<font color='lime'>+6</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>生命偷取</font><br>",
    "effects": [
      {
        "attribute": "luck",
        "delta": 20
      },
      {
        "attribute": "dodge",
        "delta": 6
      },
      {
        "attribute": "lifeSteal",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "alloy",
    "propName": "合金",
    "grade": 3,
    "type": "道具",
    "basePrice": 80,
    "talentText": "<font color='lime'>+3</font><font color='white'>近战伤害</font><br>\n<font color='lime'>+3</font><font color='white'>远程伤害</font><br>\n<font color='lime'>+3</font><font color='white'>元素伤害</font><br>\n<font color='lime'>+3</font><font color='white'>工程</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='red'>-6</font><font color='white'>闪避</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "delta": 3
      },
      {
        "attribute": "rangedDamage",
        "delta": 3
      },
      {
        "attribute": "elementalDamage",
        "delta": 3
      },
      {
        "attribute": "engineering",
        "delta": 3
      },
      {
        "attribute": "critChance",
        "delta": 5
      },
      {
        "attribute": "dodge",
        "delta": -6
      }
    ]
  },
  {
    "objectName": "toxic_tonics",
    "propName": "有毒补药",
    "grade": 3,
    "type": "道具",
    "basePrice": 80,
    "talentText": "<font color='lime'>+10</font><font color='white'>攻速</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+15</font><font color='white'>射程</font><br>\n<font color='red'>-2</font><font color='white'>生命恢复</font><br>",
    "effects": [
      {
        "attribute": "attackSpeed",
        "delta": 10
      },
      {
        "attribute": "critChance",
        "delta": 5
      },
      {
        "attribute": "range",
        "delta": 15
      },
      {
        "attribute": "hpRegeneration",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "shmoop",
    "propName": "休穆糖",
    "grade": 3,
    "type": "道具",
    "basePrice": 60,
    "talentText": "<font color='lime'>+6</font><font color='white'>最大生命</font><br>\n<font color='lime'>+2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-1</font><font color='white'>远程伤害</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "delta": 6
      },
      {
        "attribute": "hpRegeneration",
        "delta": 2
      },
      {
        "attribute": "meleeDamage",
        "delta": -2
      },
      {
        "attribute": "rangedDamage",
        "delta": -1
      }
    ]
  },
  {
    "objectName": "toolbox",
    "propName": "工具箱",
    "grade": 3,
    "type": "道具",
    "basePrice": 55,
    "talentText": "<font color='lime'>+6</font><font color='white'>工程</font><br>\n<font color='red'>-8</font><font color='white'>攻击速度</font><br>",
    "effects": [
      {
        "attribute": "engineering",
        "delta": 6
      },
      {
        "attribute": "attackSpeed",
        "delta": -8
      }
    ]
  },
  {
    "objectName": "guard_helmet",
    "propName": "守卫头盔",
    "grade": 3,
    "type": "道具",
    "basePrice": 80,
    "talentText": "<font color='lime'>+3</font><font color='white'>护甲</font><br>\n<font color='lime'>+5</font><font color='white'>最大生命</font><br>\n<font color='red'>-5</font><font color='white'>速度</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "delta": 3
      },
      {
        "attribute": "maxHp",
        "delta": 5
      },
      {
        "attribute": "speed",
        "delta": -5
      }
    ]
  },
  {
    "objectName": "glass_cannon",
    "propName": "玻璃大炮",
    "grade": 3,
    "type": "道具",
    "basePrice": 75,
    "talentText": "<font color='lime'>+25</font><font color='white'>伤害</font><br>\n<font color='red'>-3</font><font color='white'>护甲</font><br>",
    "notes": "TODO: talentText 显示 +25 伤害但代码仅 +3，-5 护甲",
    "effects": [
      {
        "attribute": "damage",
        "delta": 3
      },
      {
        "attribute": "armor",
        "delta": -5
      }
    ]
  },
  {
    "objectName": "cloak",
    "propName": "斗篷",
    "grade": 4,
    "type": "道具",
    "basePrice": 110,
    "talentText": "<font color='lime'>+5</font><font color='white'>生命偷取</font><br>\n<font color='lime'>+20</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>近战伤害</font><br>\n<font color='red'>-2</font><font color='white'>远程伤害</font><br>\n<font color='red'>-2</font><font color='white'>元素伤害</font><br>",
    "effects": [
      {
        "attribute": "lifeSteal",
        "delta": 5
      },
      {
        "attribute": "dodge",
        "delta": 20
      },
      {
        "attribute": "meleeDamage",
        "delta": -2
      },
      {
        "attribute": "rangedDamage",
        "delta": -2
      },
      {
        "attribute": "elementalDamage",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "exoskeleton",
    "propName": "外骨骼",
    "grade": 4,
    "type": "道具",
    "basePrice": 90,
    "talentText": "<font color='lime'>+5</font><font color='white'>护甲</font><br>\n<font color='lime'>+5</font><font color='white'>暴击率</font><br>\n<font color='lime'>+5</font><font color='white'>工程</font><br>\n<font color='lime'>+5</font><font color='white'>闪避</font><br>\n<font color='red'>-2</font><font color='white'>生命恢复</font><br>\n<font color='red'>-2</font><font color='white'>生命偷取</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "delta": 5
      },
      {
        "attribute": "critChance",
        "delta": 5
      },
      {
        "attribute": "engineering",
        "delta": 5
      },
      {
        "attribute": "dodge",
        "delta": 5
      },
      {
        "attribute": "hpRegeneration",
        "delta": -2
      },
      {
        "attribute": "lifeSteal",
        "delta": -2
      }
    ]
  },
  {
    "objectName": "heavy_bullets",
    "propName": "重子弹",
    "grade": 4,
    "type": "道具",
    "basePrice": 100,
    "talentText": "<font color='lime'>+5</font><font color='white'>远程伤害</font><br>\n<font color='lime'>+10</font><font color='white'>伤害</font><br>\n<font color='lime'>+10</font><font color='white'>射程</font><br>\n<font color='red'>-5</font><font color='white'>攻击速度</font><br>\n<font color='red'>-5</font><font color='white'>暴击率</font><br>",
    "effects": [
      {
        "attribute": "rangedDamage",
        "delta": 5
      },
      {
        "attribute": "damage",
        "delta": 10
      },
      {
        "attribute": "range",
        "delta": 10
      },
      {
        "attribute": "attackSpeed",
        "delta": -5
      },
      {
        "attribute": "critChance",
        "delta": -5
      }
    ]
  }
]

// ============================================================
// 3. 角色数据
// ============================================================
var _ROLES_DATA = [
  {
    "objectName": "wellRounded",
    "roleName": "全能者",
    "talentText": "<font color='lime'>+5</font><font color='white'> 最大生命值</font><br>\n<font color='lime'>+5</font><font color='white'> %速度</font><br>\n<font color='lime'>+8</font><font color='white'> 收获</font>",
    "effects": [
      {
        "attribute": "maxHp",
        "condition": "lt",
        "conditionValue": 15,
        "setTo": 15
      },
      {
        "attribute": "curHp",
        "setToProp": "maxHp"
      },
      {
        "attribute": "speed",
        "condition": "lt",
        "conditionValue": 5,
        "setTo": 5
      },
      {
        "attribute": "harvesting",
        "condition": "lt",
        "conditionValue": 8,
        "setTo": 8
      }
    ]
  },
  {
    "objectName": "mutant",
    "roleName": "异变体",
    "talentText": "<font color='white'>升级需要</font><font color='lime'>-66%</font><font color='white'>经验值</font><br>\n<font color='red'>+50</font><font color='white'> %道具价格</font>",
    "effects": [
      {
        "attribute": "expDiscountRate",
        "condition": "lt",
        "conditionValue": 0.33,
        "setTo": 0.33
      },
      {
        "attribute": "goodsDiscountRate",
        "condition": "lt",
        "conditionValue": 1.5,
        "setTo": 1.5
      }
    ]
  }
]

// ============================================================
// 4. 升级选项数据
// ============================================================
var _UPGRADE_OPTIONS_DATA = [
  {
    "objectName": "leg",
    "optionName": "腿",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>%速度</font><br>",
    "effects": [
      {
        "attribute": "speed",
        "deltaByGrade": [
          3,
          6,
          9,
          12
        ]
      }
    ]
  },
  {
    "objectName": "chest",
    "optionName": "胸",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>护甲</font><br>",
    "effects": [
      {
        "attribute": "armor",
        "deltaByGrade": [
          1,
          2,
          3,
          4
        ]
      }
    ]
  },
  {
    "objectName": "skull",
    "optionName": "头骨",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>工程学</font><br>",
    "effects": [
      {
        "attribute": "engineering",
        "deltaByGrade": [
          2,
          4,
          6,
          8
        ]
      }
    ]
  },
  {
    "objectName": "lung",
    "optionName": "肺",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>生命恢复</font><br>",
    "effects": [
      {
        "attribute": "hpRegeneration",
        "deltaByGrade": [
          2,
          4,
          6,
          8
        ]
      }
    ]
  },
  {
    "objectName": "finger",
    "optionName": "手指",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>暴击率</font><br>",
    "effects": [
      {
        "attribute": "critChance",
        "deltaByGrade": [
          3,
          6,
          9,
          12
        ]
      }
    ]
  },
  {
    "objectName": "back",
    "optionName": "背",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>闪避</font><br>",
    "effects": [
      {
        "attribute": "dodge",
        "deltaByGrade": [
          3,
          6,
          9,
          12
        ]
      }
    ]
  },
  {
    "objectName": "teeth",
    "optionName": "牙齿",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>生命窃取</font><br>",
    "effects": [
      {
        "attribute": "lifeSteal",
        "deltaByGrade": [
          1,
          2,
          3,
          4
        ]
      }
    ]
  },
  {
    "objectName": "heart",
    "optionName": "心脏",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>最大生命值</font><br>",
    "effects": [
      {
        "attribute": "maxHp",
        "deltaByGrade": [
          3,
          6,
          9,
          12
        ]
      },
      {
        "attribute": "curHp",
        "deltaByGrade": [
          3,
          6,
          9,
          12
        ]
      }
    ]
  },
  {
    "objectName": "brain",
    "optionName": "脑",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>元素伤害</font><br>",
    "effects": [
      {
        "attribute": "elementalDamage",
        "deltaByGrade": [
          1,
          2,
          3,
          4
        ]
      }
    ]
  },
  {
    "objectName": "reflexes",
    "optionName": "反应能力",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>攻击速度</font><br>",
    "effects": [
      {
        "attribute": "attackSpeed",
        "deltaByGrade": [
          5,
          10,
          15,
          20
        ]
      }
    ]
  },
  {
    "objectName": "nose",
    "optionName": "鼻",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>幸运</font><br>",
    "effects": [
      {
        "attribute": "luck",
        "deltaByGrade": [
          5,
          10,
          15,
          20
        ]
      }
    ]
  },
  {
    "objectName": "hand",
    "optionName": "手",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>收获</font><br>",
    "effects": [
      {
        "attribute": "harvesting",
        "deltaByGrade": [
          5,
          10,
          15,
          20
        ]
      }
    ]
  },
  {
    "objectName": "shoulder",
    "optionName": "肩",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>远程伤害</font><br>",
    "effects": [
      {
        "attribute": "rangedDamage",
        "deltaByGrade": [
          1,
          2,
          3,
          4
        ]
      }
    ]
  },
  {
    "objectName": "foream",
    "optionName": "前臂",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>近战伤害</font><br>",
    "effects": [
      {
        "attribute": "meleeDamage",
        "deltaByGrade": [
          2,
          4,
          6,
          8
        ]
      }
    ]
  },
  {
    "objectName": "triceps",
    "optionName": "三头肌",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>伤害</font><br>",
    "effects": [
      {
        "attribute": "damage",
        "deltaByGrade": [
          5,
          10,
          15,
          20
        ]
      }
    ]
  },
  {
    "objectName": "eyes",
    "optionName": "眼睛",
    "type": "升级",
    "talentTextTemplate": "<font color='lime'>+{{value}}</font><font color='white'>范围</font><br>",
    "effects": [
      {
        "attribute": "range",
        "deltaByGrade": [
          15,
          30,
          45,
          60
        ]
      }
    ]
  }
]

// ============================================================
// 5. 怪物数据 —— 已迁出本管线
// 怪物数据是有状态数据（curNumber/countRation 被运行时读写），
// 静态值与运行时状态同住 singleton/MonstersData.qml（唯一来源，勿在此重新添加）。
// ============================================================

// ============================================================
// 6. 地图主题数据
// ============================================================
var _THEMES_DATA = [
  null,  // 0=随机（无数据）
  null,  // 1=泥地
  null,  // 2=森林
  null,  // 3=火山
  {      // 4=梦幻之地 —— 唯一有数据的主题
    "name": "梦幻之地",
    "backgroundColor": "#796461",
    "overlayColor": null,
    "stoneImages": ["stone1.png", "stone2.png", "stone3.png", "stone4.png"],
    "edgeImage": "edge.png"
  },
  null,  // 5=墓地
  null   // 6=黑暗之地
]

// ============================================================
// 7. 波次数据
// ============================================================
var _WAVES_DATA = [
  {
    "wave": 1,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      }
    ]
  },
  {
    "wave": 2,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      },
      {
        "monster": "chaser",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 3,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 5
      },
      {
        "monster": "chaser",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 4,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 6
      },
      {
        "monster": "sprayer",
        "initCount": 2
      }
    ]
  },
  {
    "wave": 5,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      },
      {
        "monster": "chaser",
        "initCount": 3
      },
      {
        "monster": "sprayer",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 6,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 7
      },
      {
        "monster": "chaser",
        "initCount": 3
      },
      {
        "monster": "charger",
        "initCount": 4
      }
    ]
  },
  {
    "wave": 7,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "charger",
        "initCount": 6
      },
      {
        "monster": "sprayer",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 8,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      },
      {
        "monster": "sprayer",
        "initCount": 2
      },
      {
        "monster": "brute",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 9,
    "spawns": [
      {
        "monster": "chaser",
        "initCount": 6
      },
      {
        "monster": "charger",
        "initCount": 2
      },
      {
        "monster": "brute",
        "initCount": 2
      }
    ]
  },
  {
    "wave": 10,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      },
      {
        "monster": "chaser",
        "initCount": 4
      },
      {
        "monster": "charger",
        "initCount": 2
      },
      {
        "monster": "brute",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 11,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 4
      },
      {
        "monster": "charger",
        "initCount": 4
      },
      {
        "monster": "sprayer",
        "initCount": 2
      },
      {
        "monster": "pursuer",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 12,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 5
      },
      {
        "monster": "charger",
        "initCount": 4
      },
      {
        "monster": "pursuer",
        "initCount": 1
      },
      {
        "monster": "brute",
        "initCount": 2
      }
    ]
  },
  {
    "wave": 13,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "charger",
        "initCount": 3
      },
      {
        "monster": "pursuer",
        "initCount": 1
      },
      {
        "monster": "brute",
        "initCount": 1
      },
      {
        "monster": "helmetBrute",
        "initCount": 2
      },
      {
        "monster": "helmetAlien",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 14,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "brute",
        "initCount": 1
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "summoner",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 15,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "sprayer",
        "initCount": 1
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "summoner",
        "initCount": 1
      },
      {
        "monster": "finChaser",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 16,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "brute",
        "initCount": 1
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "finChaser",
        "initCount": 3
      },
      {
        "monster": "helmetBrute",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 17,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "pursuer",
        "initCount": 2
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "finChaser",
        "initCount": 3
      },
      {
        "monster": "summoner",
        "initCount": 1
      }
    ]
  },
  {
    "wave": 18,
    "spawns": [
      {
        "monster": "sprayer",
        "initCount": 2
      },
      {
        "monster": "helmetAlien",
        "initCount": 5
      },
      {
        "monster": "summoner",
        "initCount": 1
      },
      {
        "monster": "helmetCharger",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 19,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "sprayer",
        "initCount": 2
      },
      {
        "monster": "pursuer",
        "initCount": 2
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "summoner",
        "initCount": 1
      },
      {
        "monster": "helmetBrute",
        "initCount": 2
      },
      {
        "monster": "helmetCharger",
        "initCount": 3
      }
    ]
  },
  {
    "wave": 20,
    "spawns": [
      {
        "monster": "babyAlien",
        "initCount": 3
      },
      {
        "monster": "sprayer",
        "initCount": 2
      },
      {
        "monster": "pursuer",
        "initCount": 2
      },
      {
        "monster": "helmetAlien",
        "initCount": 4
      },
      {
        "monster": "finChaser",
        "initCount": 3
      },
      {
        "monster": "summoner",
        "initCount": 1
      },
      {
        "monster": "helmetBrute",
        "initCount": 2
      },
      {
        "monster": "prayer",
        "initCount": 1
      }
    ]
  }
]

// ---- 数据缓存（懒加载填充） ----
var _weapons = null
var _props = null
var _roles = null
var _upgradeOptions = null
var _waves = null
var _themes = null

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
    _waves = _WAVES_DATA
    _themes = _THEMES_DATA

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
        var w = _weapons[j]
        // 跳过未实现的武器（商店随机抽选不显示它们）
        if (w.implemented === false) continue
        if (w.grades) {
            for (var g = 0; g < w.grades.length; g++) {
                var grade = w.grades[g].grade
                if (grade >= 1 && grade <= 4) {
                    _weaponsByGrade[grade].push(w)
                }
            }
        } else {
            _weaponsByGrade[1].push(w)
        }
    }
    // 升级选项：源数据一份，按等级展开进四桶（每条自带对应等级的展开后 effects）
    _upgradeOptionsByGrade = { 1: [], 2: [], 3: [], 4: [] }
    for (var k = 0; k < _upgradeOptions.length; k++) {
        for (var ug = 1; ug <= 4; ug++) {
            _upgradeOptionsByGrade[ug].push(_expandUpgradeOption(_upgradeOptions[k], ug))
        }
    }
}

// ---- 内部：深拷贝 ----
function _deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj))
}

// ---- 内部：升级选项按等级展开 ----
// 源数据一份（deltaByGrade 描述每级增量），加载时展开为各等级独立条目：
// deltaByGrade[grade-1] → 具体 delta（applyEffects/effectValue 只认 delta）。
function _expandUpgradeOption(src, grade) {
    var o = _deepCopy(src)
    o.grade = grade
    for (var i = 0; i < o.effects.length; i++) {
        var eff = o.effects[i]
        if (eff.deltaByGrade !== undefined) {
            eff.delta = eff.deltaByGrade[grade - 1]
            delete eff.deltaByGrade
        }
    }
    return o
}

// ---- 内部：加权随机选择 ----
// dedupKeyFn 可选：给定候选条目返回查重键（跨等级去重，如升级选项按 objectName）；
// 不传时沿用（等级_桶内索引）查重——武器/道具路径行为不变。
function _weightedRandomSelect(candidatesByGrade, gradeWeights, count, dedupKeyFn) {
    if (count <= 0) return []
    var totalWeight = gradeWeights[1] + gradeWeights[2] + gradeWeights[3] + gradeWeights[4]
    var result = []
    var usedKeys = {}

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
        var key
        do {
            index = Math.floor(Math.random() * pool.length)
            attempts++
            key = dedupKeyFn ? dedupKeyFn(pool[index]) : grade + "_" + index
        } while (usedKeys[key] && attempts < 100)

        usedKeys[key] = true
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

function isWeaponImplemented(objectName) {
    _ensureLoaded()
    for (var i = 0; i < _weapons.length; i++) {
        if (_weapons[i].objectName === objectName) {
            return _weapons[i].implemented !== false
        }
    }
    return false
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
    weapon._appliedGrade = grade
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
    var result = _weightedRandomSelect(_weaponsByGrade, gradeWeights, count)
    for (var i = 0; i < result.length; i++) {
        _applyGradeData(result[i], result[i].grade)
    }
    return result
}

function getWeaponGradeCounts() {
    _ensureLoaded()
    return {
        1: _weaponsByGrade[1].length,
        2: _weaponsByGrade[2].length,
        3: _weaponsByGrade[3].length,
        4: _weaponsByGrade[4].length
    }
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
    var bucket = _upgradeOptionsByGrade[grade]
    if (bucket) {
        for (var i = 0; i < bucket.length; i++) {
            if (bucket[i].objectName === objectName || bucket[i].optionName === objectName) {
                return _deepCopy(bucket[i])
            }
        }
    }
    console.error("DataLoader.getUpgradeOption: '" + objectName + "' not found")
    return null
}

function getUpgradeOptionRandomly(count, gradeWeights) {
    _ensureLoaded()
    // 四等级桶直接参与加权选择，结果自带正确等级与展开后的效果（无二次滚级补丁）；
    // 查重键取 objectName——跨等级去重，避免同选项的不同等级同时出现
    return _weightedRandomSelect(_upgradeOptionsByGrade, gradeWeights, count, function(item) {
        return item.objectName
    })
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

// ---- 地图主题 ----
function getTheme(index) {
    _ensureLoaded()
    if (index < 0 || index >= _themes.length) return null
    return _themes[index] ? _deepCopy(_themes[index]) : null
}

function getAllThemes() {
    _ensureLoaded()
    return _deepCopy(_themes)
}

// ---- 通用 effect 应用 ----
// 升级选项的效果在加载时已按等级展开为具体 delta，此处只处理三种形态：
// lt 保底 / setToProp / delta
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
        }
    }
}

// ---- 升级选项显示值：{{value}} = 首个增量效果的实际生效值 ----
// 条目已在加载时按等级展开（effects 带具体 delta），取首个 delta。
// 现状每条升级选项的各效果数值一致（“心脏”的 maxHp/curHp 逐级同值），
// 单个 {{value}} 占位符无歧义；若将来出现“多效果且数值不同”的选项，
// 需将模板扩展为多占位符（归后续扩展处理）。
function effectValue(effects) {
    if (!effects || effects.length === 0) return 0
    for (var i = 0; i < effects.length; i++) {
        if (effects[i].delta !== undefined) return effects[i].delta
    }
    return 0
}

// ---- 模板渲染 (升级选项 talentText) ----
// 纯占位替换：{{value}} → 传入的显示值（由 effectValue 计算，替换与取值职责分离）
function renderTalentText(template, value) {
    if (!template) return ""
    return template.replace(/\{\{value\}\}/g, String(value))
}

// ---- 武器 talentText 结构化数据（由 WeaponCustomizationCore 配合 I18n.tr 渲染） ----
function renderWeaponTalentText(weapon, playerData) {
    if (!weapon || !playerData) return null
    if (weapon.meleeDamageMultiplier === undefined && weapon.rangedDamageMultiplier === undefined && weapon.elementalDamageMultiplier === undefined) return null
    
    var isMelee = weapon.meleeDamageMultiplier !== undefined
    var isElemental = weapon.elementalDamageMultiplier !== undefined
    var dmg, critChance, critMultiplier
    
    if (isMelee) {
        dmg = Math.floor(Math.max((weapon.baseDamage + playerData.meleeDamage * weapon.meleeDamageMultiplier) * (1 + playerData.damage / 100), 1))
        critChance = 3 + playerData.critChance
        critMultiplier = 2.0
    } else if (isElemental) {
        dmg = Math.floor(Math.max((weapon.baseDamage + playerData.elementalDamage * weapon.elementalDamageMultiplier) * (1 + playerData.damage / 100), 1))
        critChance = 1 + playerData.critChance
        critMultiplier = 1.5
    } else {
        dmg = Math.floor(Math.max((weapon.baseDamage + playerData.rangedDamage * weapon.rangedDamageMultiplier) * (1 + playerData.damage / 100), 1))
        critChance = 1 + playerData.critChance
        critMultiplier = 1.5
    }
    
    var cd = weapon.baseCooldown / (1 + playerData.attackSpeed / 100)
    var range = weapon.baseRange + playerData.range
    var knockback = weapon.baseKnockback || 0
    var accuracyVal = (weapon.accuracy && weapon.accuracy[(weapon._appliedGrade || 1) - 1]) || 1.0
    var inherentPen = weapon.inherentPenetrate || 0
    var inherentPenMult = weapon.inherentPenetrateMultiplier || 1.0
    
    return {
        dmg: dmg,
        critChance: critChance,
        critMultiplier: critMultiplier,
        cd: cd,
        range: range,
        knockback: knockback,
        accuracy: accuracyVal,
        inherentPenetrate: inherentPen,
        inherentPenetrateMultiplier: inherentPenMult,
        isMelee: isMelee,
        isElemental: isElemental
    }
}
