//刷新商店
// function refreshShop() {
//     var old = [];
//     for (var i = 0; i < shopModel.count; ++i) {
//         var item = shopModel.get(i)
//         old.push({
//                      goods: item.goods,
//                      isLockedModel: item.isLockedModel
//                  })
//     }

//     var lockedItemNum = 0
//     shopModel.clear()
//     for (var idx = 0; idx < shopView.columns; ++idx) {
//         if (old[idx] && old[idx].isLockedModel) {
//             // 保留旧项
//             lockedItemNum++
//             // console.log(old[idx].isLockedModel)
//             shopModel.append({
//                 goods:     old[idx].goods,
//                 isLockedModel: true
//             })
//         }
//     }
//     // else {
//     // for (var l = 0; l < shopView.columns; ++l) {
//     //     // console.log(old[idx].isLockedModel)
//     //     if (old[l] && old[l].isLockedModel) {
//     //         // var p = core.getPropRandomly(1)[0]
//     //         // shopModel.append({
//     //         //                      propItem:     p,
//     //         //                      isLockedModel: false
//     //         //                  })
//     //         // console.log(shopModel.get(idx).isLockedModel,"111")
//     //     } else {
//     //         var p = core.getPropRandomly(1)[0]
//     //         shopModel.append({
//     //                              propItem:     p,
//     //                              isLockedModel: false
//     //                          })
//     //     }
//     // }
//     var randomItemNum = shopView.columns - lockedItemNum
//     var p = propCore.getPropRandomly(randomItemNum)
//     var w = weaponCore.getWeaponRandomly(randomItemNum)

//     for(var l = 0; l < randomItemNum; ++l) {
//         var singleItem = p[l]
//         shopModel.append({
//                              goods:     singleItem,
//                              isLockedModel: false
//                          })
//     }
//     // delete(p)
// }
function refreshShop() {
    var old = []
    for (var i = 0; i < shopModel.count; ++i) {
        var item = shopModel.get(i)
        old.push({
                     goods: item.goods,
                     isLockedModel: item.isLockedModel,
                     weaponGrade: item.weaponGrade
                 })
    }


    var lockedItemNum = 0
    shopModel.clear()

    for (var idx = 0; idx < shopView.columns; ++idx) {
        if (old[idx] && old[idx].isLockedModel) {
            lockedItemNum++
            shopModel.append({
                                 goods: old[idx].goods,
                                 isLockedModel: true,
                                 weaponGrade: old[idx].weaponGrade
                             })
        }
    }

    var randomItemNum = shopView.columns - lockedItemNum
    var baseItemProbability = 0.6
    var waveFactor = Math.min(waveNumberText.text / 20, 1.0)
    var waveEffect = baseItemProbability + waveFactor * 0.3
    var randomFluctuation = (Math.random() * 0.2) - 0.1
    var itemProbability = waveEffect + randomFluctuation
    itemProbability = Math.max(0.3, Math.min(0.9, itemProbability))

    var newWeaponCount = 0
    var maxNewWeapons = 2

    for (var i = 0; i < randomItemNum; i++) {
        var isItem
        var newGoods

        if (newWeaponCount >= maxNewWeapons) {
            isItem = true
        }else {
            isItem = Math.random() < itemProbability
        }

        if (isItem) {
            var items = propCore.getPropRandomly(1)
            if (items.length > 0) {
                newGoods = items[0]
            }
        } else {
            var weapons = weaponCore.getWeaponRandomly(1)
            if (weapons.length > 0) {
                newGoods = weapons[0]
                newWeaponCount++
            }
        }

        if (newGoods) {
            shopModel.append({
                                 goods: newGoods,
                                 isLockedModel: false,
                                 weaponGrade: newGoods.grade
                             })
        }
    }

    var actualItemCount = 0
    var actualWeaponCount = 0
    for (var j = lockedItemNum; j < shopModel.count; j++) {
        var good = shopModel.get(j).goods
        if (good.type === "道具") {
            actualItemCount++
        } else {
            actualWeaponCount++
        }
    }

    // console.log(`刷新商店: 波次=${waveNumberText.text}, ` +
    //             `道具=${actualItemCount}, 武器=${actualWeaponCount}, ` +
    //             `概率=${(itemProbability*100).toFixed(1)}%, ` +
    //             `新武器数量=${newWeaponCount}/${maxNewWeapons}`);
}

//购买商品 进行数据分发
function buyItem(itemIndex)
{
    var purchasedItem = shopModel.get(itemIndex)
    if(purchasedItem.goods.type === "道具") {
        shopscreen.shopContext._purchasedPropsModel.append({propItem: purchasedItem.goods})
        mergeDuplicateProps(purchasedItem)


        if(shopscreen.shopContext._purchasedWeaponsModel.count <= 5) {
            shopscreen.shopContext._purchasedWeaponsModel.append({weaponItem: purchasedItem.goods})
        }

    } else if(shopscreen.shopContext._purchasedWeaponsModel.count <= 5) {
        shopscreen.shopContext._purchasedWeaponsModel.append({weaponItem: purchasedItem.goods})
    }
}

//将相同的道具进行合并
function mergeDuplicateProps(purchasedItem)
{
    var exitingIndex = -1
    for( var i = 0;i < shopscreen.shopContext._duplicatePropsCountModel.count;i++) {
        if( shopscreen.shopContext._duplicatePropsCountModel.get(i).propItem.objectName === purchasedItem.goods.objectName) {
            exitingIndex = i
        }
    }
    if(exitingIndex === -1) {
        shopscreen.shopContext._duplicatePropsCountModel.insert(0,{propItem: purchasedItem.goods, count: 1})
    } else {
        for(var l = 0;l < shopscreen.shopContext._duplicatePropsCountModel.count; l++) {
            if(shopscreen.shopContext._duplicatePropsCountModel.get(l).propItem.objectName === purchasedItem.goods.objectName) {
                var currentCount = shopscreen.shopContext._duplicatePropsCountModel.get(l).count
                shopscreen.shopContext._duplicatePropsCountModel.set(l,{propItem: purchasedItem.goods,count: currentCount + 1})
            }
        }
    }
}

//合成武器
//移除一个与该武器相同的武器，并将该武器等级提高1,然后移动到模型尾部
function compositeWeapon(wIndex)
{
    // console.log(wIndex)
    var currentWeapon = purchasedWeaponsModel.get(wIndex)
    // console.log(wIndex)
    var matchIndex = -1
    for(var i = 0; i < purchasedWeaponsModel.count; i++) {
        if(i === wIndex) {
            continue
        }

        if(purchasedWeaponsModel.get(i).weaponItem.objectName === currentWeapon.weaponItem.objectName
                && purchasedWeaponsModel.get(i).weaponItem.grade === currentWeapon.weaponItem.grade) {
            matchIndex = i
            break
        }
    }

    if(matchIndex === -1) {
        return
    } else {
        purchasedWeaponsModel.remove(matchIndex)
    }

    //如果移除的项在当前项之前，就把当前项的索引-1
    //如果在其之后，不进行操作，避免移除了在其之前的项后model的大小减少导致wIndex指引错误
    if(matchIndex < wIndex) {
        wIndex--
    }

    purchasedWeaponsModel.move(wIndex, purchasedWeaponsModel.count -1, 1);
    var movedItem = purchasedWeaponsModel.get(purchasedWeaponsModel.count - 1);
    movedItem.weaponItem.grade++;
}

//控制合成按钮的可见性
//武器等级<=3合成按钮才可见
function isCompositeVisible(wIndex)
{
    // console.log(wIndex)
    // console.log(purchasedWeaponsModel.count)
    var currentWeapon = purchasedWeaponsModel.get(wIndex)
    // var isVisible = false
    for(var i = 0; i < purchasedWeaponsModel.count; i++) {
        if(i === wIndex) {
            continue
        }

        //因为按钮的可视性不断在计算，当合成后purchasedWeaponsModel.count减少，可能该次循环i已经超过了模型的大小导致报错
        if(purchasedWeaponsModel.get(i).weaponItem.objectName === currentWeapon.weaponItem.objectName
                && purchasedWeaponsModel.get(i).weaponItem.grade === currentWeapon.weaponItem.grade) {
            return true
        }
    }

    return false
}

function getPurchasedWNum()
{
    return purchasedWeaponsModel.count
}

//回收武器
function recycleWeapons(wIndex)
{
    purchasedWeaponsModel.remove(wIndex)
    //...增加角色剩余货币
}

//武器回收价格
function recycledPrice(wIndex)
{

}

//全局变量存放商店刷新次数
var refreshTimes = -1

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

//刷新后扣费
function refreshDeduction()
{

}

//购买物品扣费
function purchaseDeduction(itemIndex)
{

}
