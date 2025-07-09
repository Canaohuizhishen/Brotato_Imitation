//刷新商店
function refreshShop() {
    var old = []
    //将模型里面的数据复制下来，方便在锁定商品时进行保留
    //需要额外的weaponGrade来确定武器的等级
    for (var i = 0; i < shopModel.count; i++) {
        var item = shopModel.get(i)
        old.push({
                     goods: item.goods,
                     isLockedModel: item.isLockedModel,
                     weaponGrade: item.weaponGrade,
                     isPurchased: item.isPurchased
                 })
    }


    var lockedItemNum = 0
    shopModel.clear()

    //将锁定的商品压入新模型
    for (var idx = 0; idx < shopView.columns; idx++) {
        if (old[idx] && old[idx].isLockedModel) {
            lockedItemNum++
            shopModel.append({
                                 goods: old[idx].goods,
                                 isLockedModel: true,
                                 weaponGrade: old[idx].weaponGrade,
                                 isPurchased: old[idx].isPurchased
                             })
        }
    }

    var randomItemNum = shopView.columns - lockedItemNum //需要随机生产的商品数量
    var baseItemProbability = 0.6 //道具的基础随机概率
    var waveFactor = Math.min(waveNumberText.text / 20, 1.0)
    var waveEffect = baseItemProbability + waveFactor * 0.3 //道具的概率(受波次影响)
    var randomFluctuation = (Math.random() * 0.2) - 0.1 //增加范围在-+0.1的随机率
    var itemProbability = waveEffect + randomFluctuation
    itemProbability = Math.max(0.3, Math.min(0.9, itemProbability)) //道具最终概率(确保概率不会过高或过低)

    var weaponCount = 0
    for (i = 0; i < randomItemNum; i++) {
        if (Math.random() >= itemProbability && weaponCount < 2) {
            weaponCount++
        }
    }

    var weaponList = weaponCore.getWeaponRandomly(weaponCount)
    for (i = 0; i < weaponList.length; i++) {
        shopModel.append({
                             goods: weaponList[i],
                             isLockedModel: false,
                             weaponGrade: weaponList[i].grade,
                             isPurchased: false
                         })
    }

    var propCount = randomItemNum - weaponCount
    var propList = propCore.getPropRandomly(propCount)
    for (i = 0; i < propCount; i++) {
        if(propCount === 1) {
            shopModel.append({
                                 goods: propList,
                                 isLockedModel: false,
                                 weaponGrade: propList.grade,
                                 isPurchased: false
                             })
        } else {
            shopModel.append({
                                 goods: propList[i],
                                 isLockedModel: false,
                                 weaponGrade: propList[i].grade,
                                 isPurchased: false
                             })
        }
    }

    //同步数据到角色数据
    PlayerData.lastStoreGoods.clear()
    for(var l = 0;l < shopModel.count;l++) {
        var good = shopModel.get(l)
        PlayerData.lastStoreGoods.append({
                                             goods: good.goods,
                                             isLockedModel: good.isLockedModel,
                                             weaponGrade: good.weaponGrade,
                                             isPurchased: good.isPurchased
                                         })
        // console.log("good",PlayerData.lastStoreGoods.get(l).goods)
        // console.log("isLockedModel",PlayerData.lastStoreGoods.get(l).isLockedModel)
        //  console.log("weaponGrade",PlayerData.lastStoreGoods.get(l).weaponGrade)
        // console.log("isPurchased",PlayerData.lastStoreGoods.get(l).isPurchased)
    }

}

//购买商品 进行数据分发
function buyItem(itemIndex)
{
    var purchasedItem = shopModel.get(itemIndex)
    if(purchasedItem.goods.type === "道具") {
        // PlayerData.shopContext._purchasedPropsModel.append({propItem: purchasedItem.goods})
        mergeDuplicateProps(purchasedItem.goods.propName) //将道具合并，并加入模型
        purchasedItem.goods.apply()
        attributeBar.upData()
        PlayerData.lastStoreGoods.get(itemIndex).isPurchased = true
        purchasedItem.isPurchased = true //购买了该商品后商品项就不可见
        shopItem.visible = !purchasedItem.isPurchased
        shopModel.get(itemIndex).isLockedModel = false //确保如果购买的是锁定商品，点击刷新可以把该锁定商品刷新掉
        return true
        // if(shopscreen.shopContext._purchasedWeaponsModel.count <= 6)
    } else {
        if (PlayerData.weapons.count === 6 ) { //当武器栏已经满了6个，如果购买了一个和已拥有的武器相同的武器，那么两者自动合并
            for(var i = 0;i < PlayerData.weapons.count;i++) {
                var weapon = PlayerData.weapons.get(i)
                if(purchasedItem.goods.weaponName === weapon.weaponName
                        && purchasedItem.weaponGrade === weapon.grade
                        && weapon.grade !== 4) {
                    // shopscreen.shopContext._purchasedWeaponsModel.get(i).weaponGrade++
                    PlayerData.weapons.setProperty(i, "grade", weapon.grade + 1)
                    PlayerData.weapons.move(i, PlayerData.weapons.count - 1, 1)
                    PlayerData.weaponsListChanged()
                    PlayerData.lastStoreGoods.get(itemIndex).isPurchased = true
                    purchasedItem.isPurchased = true //购买了该武器后商品项就不可见
                    shopItem.visible = !purchasedItem.isPurchased
                    // shopItem.visible = false
                    shopModel.get(itemIndex).isLockedModel = false
                    PlayerData.weapons.layoutChanged() //强制模型刷新，确保合成按钮的可见性正确
                    return true //确保商品成功购买并且加入到模型才进行扣费
                }
            }
        } else if (PlayerData.weapons.count <= 5){
            // PlayerData.weapons.append({weaponItem: purchasedItem.goods,weaponGrade: purchasedItem.weaponGrade})
            PlayerData.addWeapon(purchasedItem.goods.weaponName,purchasedItem.weaponGrade)
            PlayerData.weaponsListChanged()
            purchasedItem.isPurchased = true //购买了该武器后商品项就不可见
            shopItem.visible = !purchasedItem.isPurchased
            shopModel.get(itemIndex).isLockedModel = false
            return true
        }
    }

    return false
}

//将相同的道具进行合并
function mergeDuplicateProps(propName)
{
    var exitingIndex = -1
    //寻找模型中是否有所和购买道具相同的道具
    for( var i = 0;i < PlayerData.props.count;i++) {
        if( PlayerData.props.get(i).propName === propName) {
            exitingIndex = i
        }
    }
    if(exitingIndex === -1) {
        PlayerData.props.append({"propName": propName,"number": 1})
    } else {
        for(var l = 0;l < PlayerData.props.count; l++) {
            if(PlayerData.props.get(l).propName === propName) {
                var currentCount = PlayerData.props.get(l).number
                PlayerData.props.set(l,{propName: propName,number: currentCount + 1})
            }
        }
    }
}

//合成武器
//移除一个与该武器相同的武器，并将该武器等级提高1,然后移动到模型尾部
function compositeWeapon(wIndex)
{
    // console.log(wIndex)
    var currentWeapon = PlayerData.weapons.get(wIndex)
    // console.log(wIndex)
    var matchIndex = -1
    for(var i = 0; i < PlayerData.weapons.count; i++) {
        if(i === wIndex) {
            continue
        }

        if(PlayerData.weapons.get(i).weaponName === currentWeapon.weaponName
                && PlayerData.weapons.get(i).grade === currentWeapon.grade) {
            matchIndex = i
            break
        }
    }

    if(matchIndex === -1) {
        return
    } else {
        PlayerData.weapons.remove(matchIndex)
    }

    //如果移除的项在当前项之前，就把当前项的索引-1
    //如果在其之后，不进行操作，避免移除了在其之前的项后model的大小减少导致wIndex指引错误
    if(matchIndex < wIndex) {
        wIndex--
    }

    PlayerData.weapons.move(wIndex, PlayerData.weapons.count -1, 1)
    var movedItem = PlayerData.weapons.get(PlayerData.weapons.count - 1)
    // movedItem.weaponGrade++;
    PlayerData.weapons.setProperty(PlayerData.weapons.count - 1, "grade", currentWeapon.grade + 1)
    PlayerData.weaponsListChanged()
    PlayerData.weapons.layoutChanged() //强制模型更新，触发按钮可见性的重新计算
}

//控制合成按钮的可见性
//武器等级<=3合成按钮才可见
function isCompositeVisible(wIndex)
{
    var currentWeapon = PlayerData.weapons.get(wIndex)

    if (!currentWeapon || !currentWeapon.weaponName || currentWeapon.grade === 4) {
        return false
    }

    for(var i = 0; i < PlayerData.weapons.count; i++) {
        if(i === wIndex) {
            continue
        }
        var weapon = PlayerData.weapons.get(i)
        if (!weapon || !weapon.weaponName) {
            continue
        }
        if((PlayerData.weapons.get(i).weaponName === currentWeapon.weaponName
            || PlayerData.weapons.get(i).weaponName === currentWeapon.objectName)
                && PlayerData.weapons.get(i).grade === currentWeapon.grade) {
            return true
        }
    }

    return false
}

function getPurchasedWNum()
{
    return PlayerData.weapons.count
}

//回收武器
function recycleWeapons(wIndex)
{
    PlayerData.weapons.remove(wIndex)
    PlayerData.weaponsListChanged()
    // PlayerData.materialsNumber -= recycledPrice(wIndex,wGrade)
}

//武器回收价格
function recycledPrice(wIndex,wGrade)
{
    //添加这些判断的目的是：防止在武器栏并未初始化完成的时候就调用了该函数导致报错
    if (!PlayerData.weapons || wIndex >= PlayerData.weapons.count) {
        return
    }
    var weaponModel = PlayerData.weapons.get(wIndex)
    if (!weaponModel || !weaponModel.weaponName) {
        return
    }

    // console.log("111")
    return Math.floor(weaponCore.getWeapon(PlayerData.weapons.get(wIndex).weaponName,wGrade).basePrice * 0.7)
}

//全局变量存放商店刷新次数
var refreshTimes = -1

function resetRefreshTimes()
{
    refreshTimes = -1
}


//刷新的价格
function refreshPrice(waveNum)
{
    let increment = 1
    if(waveNum === 1) {
        refreshTimes++
        // console.log(refreshTimes)
        return (waveNum + increment) + refreshTimes * increment
    } else {
        increment = Math.floor(waveNum / 2);
        // console.log(increment)
        refreshTimes++
        return (waveNum + increment) + refreshTimes * increment
    }
}

//获取武器
//一个武器需要名称和等级才能唯一标识
function getSpecificWeapon() {
    if (itemData && itemData.type !== "道具") {
        return weaponCore.getWeapon(itemData.objectName, wGrade)
    }
    return null
}

// //初始化道具栏
// function initPropBar()
// {
//     PlayerData.shopContext._duplicatePropsCountModel.clear()
//     for(var i = 0;i < PlayerData.props.count; i++) {
//         var propName = PlayerData.props.get(i).propName
//         PlayerData.shopContext._duplicatePropsCountModel.append({propItem: propCore.getProp(propName),                                count: PlayerData.props.get(i).number})
//     }
// }

// //初始化武器栏
// function initWeaponBar()
// {
//     PlayerData.shopContext._purchasedWeaponsModel.clear()
//     for(var j = 0;j < PlayerData.weapons.count; j++) {
//         var weaponName = PlayerData.weapons.get(j).weaponName
//         PlayerData.shopContext._purchasedWeaponsModel.append({weaponItem: weaponCore.getWeapon(weaponName), weaponGrade: PlayerData.weapons.get(j).grade})
//     }
// }

// //将道具栏的道具同步到角色的道具模型中
// function setPlayerProps(PlayerData)
// {
//     PlayerData.props.clear()
//     for(var l = 0; l < PlayerData.shopContext._duplicatePropsCountModel.count;l++) {
//         var prop = PlayerData.shopContext._duplicatePropsCountModel.get(l)
//         PlayerData.addProp(prop.propItem.propName,prop.count)
//         // console.log("PlayerData prop:",PlayerData.props.get(l).propName," ",PlayerData.props.get(l).number)
//     }
// }

// //将武器栏的武器同步到角色的武器模型中
// function setPlayerWeapons(PlayerData)
// {
//     PlayerData.weapons.clear()
//     for(var i = 0;i < PlayerData.shopContext._purchasedWeaponsModel.count;i++) {
//         var weapon = PlayerData.shopContext._purchasedWeaponsModel.get(i)
//         PlayerData.addWeapon(weapon.weaponItem.weaponName,weapon.weaponGrade)
//         // console.log("PlayerData weapon:",PlayerData.weapons.get(i).weaponName," ",PlayerData.weapons.get(i).grade)
//     }
// }
//     PlayerData.props.clear()
//     for(var l = 0; l < PlayerData.shopContext._duplicatePropsCountModel.count;l++) {
//         var prop = PlayerData.shopContext._duplicatePropsCountModel.get(l)
//         PlayerData.addProp(prop.propItem.propName,prop.count)
//         // console.log("PlayerData prop:",PlayerData.props.get(l).propName," ",PlayerData.props.get(l).number)
//     }
// }

// //将武器栏的武器同步到角色的武器模型中
// function setPlayerWeapons(PlayerData)
// {
//     PlayerData.weapons.clear()
//     for(var i = 0;i < PlayerData.shopContext._purchasedWeaponsModel.count;i++) {
//         var weapon = PlayerData.shopContext._purchasedWeaponsModel.get(i)
//         PlayerData.addWeapon(weapon.weaponItem.weaponName,weapon.weaponGrade)
//         // console.log("PlayerData weapon:",PlayerData.weapons.get(i).weaponName," ",PlayerData.weapons.get(i).grade)
//     }
// }
