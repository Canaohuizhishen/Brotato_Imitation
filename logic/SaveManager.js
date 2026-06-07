.pragma library

function saveGame(data, fileManager, appDataPath) {
    try {
        const saveData = {
            "curLevel": data.curLevel,
            "curXp": data.curXp,
            "maxHp": data.maxHp,
            "curHp": data.curHp,
            "hpRegeneration": data.hpRegeneration,
            "lifeSteal": data.lifeSteal,
            "damage": data.damage,
            "meleeDamage": data.meleeDamage,
            "rangedDamage": data.rangedDamage,
            "elementalDamage": data.elementalDamage,
            "attackSpeed": data.attackSpeed,
            "critChance": data.critChance,
            "engineering": data.engineering,
            "range": data.range,
            "armor": data.armor,
            "dodge": data.dodge,
            "speed": data.speed,
            "luck": data.luck,
            "harvesting": data.harvesting,

            "consumptiveTherapy": data.consumptiveTherapy,
            "materialTherapy": data.materialTherapy,
            "gainExperience": data.gainExperience,
            "pickingRegion": data.pickingRegion,
            "propPrices": data.propPrices,
            "explosiveDamage": data.explosiveDamage,
            "explosionRange": data.explosionRange,
            "rebound": data.rebound,
            "penetrate": data.penetrate,
            "penetratingDamage": data.penetratingDamage,
            "damageToBoss": data.damageToBoss,
            "burningRatePercentage": data.burningRatePercentage,
            "burningRate": data.burningRate,
            "repel": data.repel,
            "obtainingDoubleMaterial": data.obtainingDoubleMaterial,
            "materialsInTheBox": data.materialsInTheBox,
            "freeRefresh": data.freeRefresh,
            "trees": data.trees,
            "enemy": data.enemy,
            "enemySpeed": data.enemySpeed,

            "roleName": data.roleName,
            "originWeaponName": data.originWeaponName,
            "difficulty": data.difficulty,
            "currentWaveNumber": data.currentWaveNumber,

            "materialsNumber": data.materialsNumber,
            "remainingMaterialsNumber": data.remainingMaterialsNumber,
            "goodsDiscountRate": data.goodsDiscountRate,
            "expDiscountRate": data.expDiscountRate,

            "weapons": weaponsToArray(data.weapons),
            "props": propsToArray(data.props),
            "lastStoreGoods": lastStoreGoodsToArray(data.lastStoreGoods),
            "lastStoreRefreshTimes": data.lastStoreRefreshTimes,
            "maxDifficultyCompleted": data.maxDifficultyCompleted,

            "isInCombat": data.isInCombat
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

function loadGame(data, fileManager, appDataPath) {
    try {
        const savePath = appDataPath + "/savegame.json"
        const saveData = fileManager.loadGameData(savePath)
        if (Object.keys(saveData).length === 0) {
            console.warn("存档加载失败，已从备份恢复或使用默认值")
            return false
        }

        data.curLevel = saveData.curLevel ?? 0
        data.curXp = saveData.curXp ?? 0
        data.maxHp = saveData.maxHp ?? 10
        data.curHp = saveData.curHp ?? data.maxHp
        data.hpRegeneration = saveData.hpRegeneration ?? 0
        data.lifeSteal = saveData.lifeSteal ?? 0
        data.damage = saveData.damage ?? 0
        data.meleeDamage = saveData.meleeDamage ?? 0
        data.rangedDamage = saveData.rangedDamage ?? 0
        data.elementalDamage = saveData.elementalDamage ?? 0
        data.critChance = saveData.critChance ?? 0
        data.engineering = saveData.engineering ?? 0
        data.range = saveData.range ?? 0
        data.armor = saveData.armor ?? 0
        data.dodge = saveData.dodge ?? 0
        data.speed = saveData.speed ?? 0
        data.luck = saveData.luck ?? 0
        data.harvesting = saveData.harvesting ?? 0
        data.attackSpeed = saveData.attackSpeed ?? 0

        data.consumptiveTherapy = saveData.consumptiveTherapy ?? 0
        data.materialTherapy = saveData.materialTherapy ?? 0
        data.gainExperience = saveData.gainExperience ?? 0
        data.pickingRegion = saveData.pickingRegion ?? 0
        data.propPrices = saveData.propPrices ?? 0
        data.explosiveDamage = saveData.explosiveDamage ?? 0
        data.explosionRange = saveData.explosionRange ?? 0
        data.rebound = saveData.rebound ?? 0
        data.penetrate = saveData.penetrate ?? 0
        data.penetratingDamage = saveData.penetratingDamage ?? 0
        data.damageToBoss = saveData.damageToBoss ?? 0
        data.burningRatePercentage = saveData.burningRatePercentage ?? 0
        data.burningRate = saveData.burningRate ?? 0
        data.repel = saveData.repel ?? 0
        data.obtainingDoubleMaterial = saveData.obtainingDoubleMaterial ?? 0
        data.materialsInTheBox = saveData.materialsInTheBox ?? 0
        data.freeRefresh = saveData.freeRefresh ?? 0
        data.trees = saveData.trees ?? 0
        data.enemy = saveData.enemy ?? 0
        data.enemySpeed = saveData.enemySpeed ?? 0

        data.roleName = saveData.roleName ?? ""
        data.originWeaponName = saveData.originWeaponName ?? ""
        data.difficulty = saveData.difficulty ?? 0
        data.currentWaveNumber = saveData.currentWaveNumber ?? 0

        data.materialsNumber = saveData.materialsNumber ?? 0
        data.remainingMaterialsNumber = saveData.remainingMaterialsNumber ?? 0
        data.goodsDiscountRate = saveData.goodsDiscountRate ?? 1.0
        data.expDiscountRate = saveData.expDiscountRate ?? 1.0

        data.lastStoreRefreshTimes = saveData.lastStoreRefreshTimes ?? 0
        data.maxDifficultyCompleted = saveData.maxDifficultyCompleted ?? -1
        data.isInCombat = saveData.isInCombat ?? false

        data.weapons.clear()
        if (saveData.weapons && Array.isArray(saveData.weapons)) {
            saveData.weapons.forEach(function(weapon) {
                var g = parseInt(weapon.grade)
                if (isNaN(g) || g < 1 || g > 4) g = 1
                data.weapons.append({weaponName: weapon.weaponName, grade: g})
            })
        }

        data.props.clear()
        if (saveData.props && Array.isArray(saveData.props)) {
            saveData.props.forEach(function(prop) {
                data.props.append({propName: prop.propName, number: prop.number})
            })
        }

        data.lastStoreGoods.clear()
        if (saveData.lastStoreGoods && Array.isArray(saveData.lastStoreGoods)) {
            saveData.lastStoreGoods.forEach(function(item) {
                data.lastStoreGoods.append({
                    goods: item.goods,
                    isLockedModel: item.isLockedModel,
                    weaponGrade: item.weaponGrade,
                    isPurchased: item.isPurchased
                })
            })
        }

        console.log("游戏加载成功，当前波次 = " + data.currentWaveNumber + "，材料 = " + data.materialsNumber)
        return true
    } catch (e) {
        console.error("加载异常：" + e)
        return false
    }
}

function weaponsToArray(weaponsModel) {
    const arr = []
    for (let i = 0; i < weaponsModel.count; ++i) {
        const item = weaponsModel.get(i)
        arr.push({weaponName: item.weaponName, grade: item.grade})
    }
    return arr
}

function propsToArray(propsModel) {
    const arr = []
    for (let i = 0; i < propsModel.count; ++i) {
        const item = propsModel.get(i)
        arr.push({propName: item.propName, number: item.number})
    }
    return arr
}

function lastStoreGoodsToArray(goodsModel) {
    const arr = []
    for (let i = 0; i < goodsModel.count; ++i) {
        const item = goodsModel.get(i)
        arr.push({
            goods: item.goods,
            isLockedModel: item.isLockedModel,
            weaponGrade: item.weaponGrade,
            isPurchased: item.isPurchased
        })
    }
    return arr
}
