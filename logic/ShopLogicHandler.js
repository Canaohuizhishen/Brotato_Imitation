//刷新商店
function refreshShop() {
    var old = []
    //将模型里面的数据复制下来，方便在锁定商品时进行保留
    //需要额外的weaponGrade来确定武器的等级
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

    //将锁定的商品压入新模型
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

    var randomItemNum = shopView.columns - lockedItemNum //需要随机生产的商品数量
    var baseItemProbability = 0.6 //道具的基础随机概率
    var waveFactor = Math.min(waveNumberText.text / 20, 1.0)
    var waveEffect = baseItemProbability + waveFactor * 0.3 //道具的概率(受波次影响)
    var randomFluctuation = (Math.random() * 0.2) - 0.1 //增加范围在-+0.1的随机率
    var itemProbability = waveEffect + randomFluctuation
    itemProbability = Math.max(0.3, Math.min(0.9, itemProbability)) //道具最终概率(确保概率不会过高或过低)

    var newWeaponCount = 0
    var maxNewWeapons = 2 //最大的武器生成数量

    for (var i = 0; i < randomItemNum; i++) {
        var isItem
        var newGoods

        if (newWeaponCount >= maxNewWeapons) {
            isItem = true
        }else {
            isItem = Math.random() < itemProbability
        }

        if (isItem) {
            var items = propCore.getPropRandomly(1) //调用道具核心，随机获取一个道具
            if (items) {
                newGoods = items
            }
        } else {
            var weapons = weaponCore.getWeaponRandomly(1) //调用武器核心，随机获取一个武器
            if (weapons.length > 0) {
                newGoods = weapons[0]
                newWeaponCount++
            }
        }

        //将获得的物品压入模型
        if (newGoods) {
            shopModel.append({
                                 goods: newGoods,
                                 isLockedModel: false,
                                 weaponGrade: newGoods.grade
                             })
        }
    }

    // var actualItemCount = 0
    // var actualWeaponCount = 0
    // for (var j = lockedItemNum; j < shopModel.count; j++) {
    //     var good = shopModel.get(j).goods
    //     if (good.type === "道具") {
    //         actualItemCount++
    //     } else {
    //         actualWeaponCount++
    //     }
    // }
}

//购买商品 进行数据分发
function buyItem(itemIndex)
{
    var purchasedItem = shopModel.get(itemIndex)
    if(purchasedItem.goods.type === "道具") {
        // PlayerData.shopContext._purchasedPropsModel.append({propItem: purchasedItem.goods})
        mergeDuplicateProps(purchasedItem) //将道具合并，并加入模型
        purchasedItem.goods.apply()
        attributeBar.upData()
        shopItem.visible = false
        shopModel.get(itemIndex).isLockedModel = false //确保如果购买的是锁定商品，点击刷新可以把该锁定商品刷新掉
        return true

        // if(shopscreen.shopContext._purchasedWeaponsModel.count <= 6)
    } else {
        if (PlayerData.shopContext._purchasedWeaponsModel.count === 6 ) { //当武器栏已经满了6个，如果购买了一个和已拥有的武器相同的武器，那么两者自动合并
            for(var i = 0;i < PlayerData.shopContext._purchasedWeaponsModel.count;i++) {
                var weapon = PlayerData.shopContext._purchasedWeaponsModel.get(i)
                if(purchasedItem.goods.objectName === weapon.weaponItem.objectName
                        && purchasedItem.weaponGrade === weapon.weaponGrade
                        && weapon.weaponGrade !== 4) {
                    // shopscreen.shopContext._purchasedWeaponsModel.get(i).weaponGrade++
                    PlayerData.shopContext._purchasedWeaponsModel.setProperty(i, "weaponGrade", weapon.weaponGrade + 1)
                    PlayerData.shopContext._purchasedWeaponsModel.move(i, PlayerData.shopContext._purchasedWeaponsModel.count - 1, 1)
                    shopItem.visible = false //购买了该武器后商品项就该不可见
                    shopModel.get(itemIndex).isLockedModel = false
                    PlayerData.shopContext._purchasedWeaponsModel.layoutChanged() //强制模型刷新，确保合成按钮的可见性正确
                    return true //确保商品成功购买并且加入到模型才进行扣费
                }
            }
        } else if (PlayerData.shopContext._purchasedWeaponsModel.count <= 5){
            PlayerData.shopContext._purchasedWeaponsModel.append({weaponItem: purchasedItem.goods,weaponGrade: purchasedItem.weaponGrade})
            shopItem.visible = false
            shopModel.get(itemIndex).isLockedModel = false
            return true
        }
    }

    return false
}

//将相同的道具进行合并
function mergeDuplicateProps(purchasedItem)
{
    var exitingIndex = -1
    //寻找模型中是否有所和购买道具相同的道具
    for( var i = 0;i < PlayerData.shopContext._duplicatePropsCountModel.count;i++) {
        if( PlayerData.shopContext._duplicatePropsCountModel.get(i).propItem.objectName === purchasedItem.goods.objectName) {
            exitingIndex = i
        }
    }
    if(exitingIndex === -1) {
        PlayerData.shopContext._duplicatePropsCountModel.insert(0,{propItem: purchasedItem.goods, count: 1})
    } else {
        for(var l = 0;l < PlayerData.shopContext._duplicatePropsCountModel.count; l++) {
            if(PlayerData.shopContext._duplicatePropsCountModel.get(l).propItem.objectName === purchasedItem.goods.objectName) {
                var currentCount = PlayerData.shopContext._duplicatePropsCountModel.get(l).count
                PlayerData.shopContext._duplicatePropsCountModel.set(l,{propItem: purchasedItem.goods,count: currentCount + 1})
            }
        }
    }
}

//合成武器
//移除一个与该武器相同的武器，并将该武器等级提高1,然后移动到模型尾部
function compositeWeapon(wIndex)
{
    // console.log(wIndex)
    var currentWeapon = PlayerData.shopContext._purchasedWeaponsModel.get(wIndex)
    // console.log(wIndex)
    var matchIndex = -1
    for(var i = 0; i < PlayerData.shopContext._purchasedWeaponsModel.count; i++) {
        if(i === wIndex) {
            continue
        }

        if(PlayerData.shopContext._purchasedWeaponsModel.get(i).weaponItem.objectName === currentWeapon.weaponItem.objectName
                && PlayerData.shopContext._purchasedWeaponsModel.get(i).weaponGrade === currentWeapon.weaponGrade) {
            matchIndex = i
            break
        }
    }

    if(matchIndex === -1) {
        return
    } else {
        PlayerData.shopContext._purchasedWeaponsModel.remove(matchIndex)
    }

    //如果移除的项在当前项之前，就把当前项的索引-1
    //如果在其之后，不进行操作，避免移除了在其之前的项后model的大小减少导致wIndex指引错误
    if(matchIndex < wIndex) {
        wIndex--
    }

    PlayerData.shopContext._purchasedWeaponsModel.move(wIndex, PlayerData.shopContext._purchasedWeaponsModel.count -1, 1)
    var movedItem = PlayerData.shopContext._purchasedWeaponsModel.get(PlayerData.shopContext._purchasedWeaponsModel.count - 1)
    // movedItem.weaponGrade++;
    PlayerData.shopContext._purchasedWeaponsModel.setProperty(PlayerData.shopContext._purchasedWeaponsModel.count - 1, "weaponGrade", currentWeapon.weaponGrade + 1)

    PlayerData.shopContext._purchasedWeaponsModel.layoutChanged() //强制模型更新，触发按钮可见性的重新计算
}

//控制合成按钮的可见性
//武器等级<=3合成按钮才可见
function isCompositeVisible(wIndex)
{
    var currentWeapon = PlayerData.shopContext._purchasedWeaponsModel.get(wIndex)

    if (!currentWeapon || !currentWeapon.weaponItem) {
        return false
    }

    for(var i = 0; i < PlayerData.shopContext._purchasedWeaponsModel.count; i++) {
        if(i === wIndex) {
            continue
        }

        var weapon = PlayerData.shopContext._purchasedWeaponsModel.get(i)
        if (!weapon || !weapon.weaponItem) {
            continue
        }

        if(PlayerData.shopContext._purchasedWeaponsModel.get(i).weaponItem.objectName === currentWeapon.weaponItem.objectName
                && PlayerData.shopContext._purchasedWeaponsModel.get(i).weaponGrade === currentWeapon.weaponGrade
                && currentWeapon.weaponGrade !== 4) {
            return true
        }
    }

    return false
}

function getPurchasedWNum()
{
    return PlayerData.shopContext._purchasedWeaponsModel.count
}

//回收武器
function recycleWeapons(wIndex)
{
    PlayerData.shopContext._purchasedWeaponsModel.remove(wIndex)
    // PlayerData.materialsNumber -= recycledPrice(wIndex,wGrade)
}

//武器回收价格
function recycledPrice(wIndex,wGrade)
{
    //添加这些判断的目的是：防止在武器栏并未初始化完成的时候就调用了该函数导致报错
    if (!PlayerData.shopContext._purchasedWeaponsModel || wIndex >= PlayerData.shopContext._purchasedWeaponsModel.count) {
        return
    }
    var weaponModel = PlayerData.shopContext._purchasedWeaponsModel.get(wIndex)
    if (!weaponModel || !weaponModel.weaponItem) {
        return
    }

    // console.log("111")
    return Math.floor(weaponCore.getWeapon(PlayerData.shopContext._purchasedWeaponsModel.get(wIndex).weaponItem.objectName,wGrade).basePrice * 0.7)
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

//初始化道具栏
function initPropBar()
{
    PlayerData.shopContext._duplicatePropsCountModel.clear()
    for(var i = 0;i < PlayerData.props.count; i++) {
        var propName = PlayerData.props.get(i).propName
        for(var l = 0;l < propCore.children.length;l++) {
            if(propCore.children[l].propName === propName) {
                PlayerData.shopContext._duplicatePropsCountModel.append({propItem: propCore.children[l],                                count: PlayerData.props.get(i).number})
                break
            }
        }
    }
}

//初始化武器栏
function initWeaponBar()
{
    PlayerData.shopContext._purchasedWeaponsModel.clear()
    for(var j = 0;j < PlayerData.weapons.count; j++) {
        var weaponName = PlayerData.weapons.get(j).weaponName
        // console.log(weaponName)
        for(var h = 0;h < weaponCore.children.length;h++) {
            if(weaponCore.children[h].weaponName === weaponName) {
                PlayerData.shopContext._purchasedWeaponsModel.append({weaponItem: weaponCore.children[h],
                                                                         weaponGrade: PlayerData.weapons.get(j).grade})
                break
            }
        }
    }
}

//将道具栏的道具同步到角色的道具模型中
function setPlayerProps(PlayerData)
{
    //把角色移到道具栏的首位
    for(var i = 0;i < PlayerData.shopContext._duplicatePropsCountModel.count; i++) {
        if(PlayerData.shopContext._duplicatePropsCountModel.get(i).propItem.type === "天赋") {
            PlayerData.shopContext._duplicatePropsCountModel.move(i, 0, 1)
            break
        }
    }

    PlayerData.props.clear()
    for(var l = 0; l < PlayerData.shopContext._duplicatePropsCountModel.count;l++) {
        var prop = PlayerData.shopContext._duplicatePropsCountModel.get(l)
        PlayerData.addProp(prop.propItem.propName,prop.count)
        // console.log("PlayerData prop:",PlayerData.props.get(l).propName," ",PlayerData.props.get(l).number)
    }
}

//将武器栏的武器同步到角色的武器模型中
function setPlayerWeapons(PlayerData)
{
    PlayerData.weapons.clear()
    for(var i = 0;i < PlayerData.shopContext._purchasedWeaponsModel.count;i++) {
        var weapon = PlayerData.shopContext._purchasedWeaponsModel.get(i)
        PlayerData.addWeapon(weapon.weaponItem.weaponName,weapon.weaponGrade)
        // console.log("PlayerData weapon:",PlayerData.weapons.get(i).weaponName," ",PlayerData.weapons.get(i).grade)
    }
}


