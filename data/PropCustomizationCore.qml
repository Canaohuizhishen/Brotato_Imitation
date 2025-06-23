import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property int grade_one_prop_number: 0
    property int grade_two_prop_number: 0
    property int grade_three_prop_number: 0
    property int grade_four_prop_number: 0
    property double grade_one_prop_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_prop_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_prop_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_prop_spawn_probability: 0.065*(1+PlayerData.luck/125)

    Component.onCompleted: {
        countPropNumber()
        // console.log(grade_one_prop_number)
        // console.log(grade_two_prop_number)
        // console.log(grade_three_prop_number)
        // console.log(grade_four_prop_number)
    }

    function countPropNumber(){
        for(var i=0;i<core.children.length;i++){
            var prop=core.children[i]
            switch(prop.grade){
            case 1: grade_one_prop_number++;break;
            case 2: grade_two_prop_number++;break;
            case 3: grade_three_prop_number++;break;
            case 4: grade_four_prop_number++;break;
            default: console.log("无效的等级:",prop.objectName,":",prop.grade)
            }
        }
    }

    //返回随机不重复的n个道具信息结构体
    function getPropRandomly(number=1){
        if(grade_one_prop_number==0)countPropNumber()
        var result=[]//存储所有选中的道具
        var array=[]//存储所有选中的道具的等级和索引，便于查重
        var random//存储随机数
        var probability
        var grade
        var index
        var isSame
        for(var i=0;i<number;i++){
            //获得随机等级
            random=Math.random()*(grade_one_prop_spawn_probability+grade_two_prop_spawn_probability+grade_three_prop_spawn_probability+grade_four_prop_spawn_probability)
            probability=grade_four_prop_spawn_probability
            if(random<probability){
                grade=4
            }else{
                probability+=grade_three_prop_spawn_probability
                if(random<probability){
                    grade=3
                }else{
                    probability+=grade_two_prop_spawn_probability
                    if(random<probability){
                        grade=2
                    }else grade=1
                }
            }

            //获得随机索引
            switch(grade){
            case 1: index=Math.floor(Math.random()*grade_one_prop_number);break;
            case 2: index=Math.floor(Math.random()*grade_two_prop_number);break;
            case 3: index=Math.floor(Math.random()*grade_three_prop_number);break;
            case 4: index=Math.floor(Math.random()*grade_four_prop_number);break;
            default: console.log("getPropRandomly():无效的等级:",grade)
            }

            //查重
            isSame=false
            for(var a=0;a<array.length;a++){
                if(array[a][0]===grade && array[a][1]===index){
                    isSame=true
                    break
                }
            }

            //存储结果
            if(!isSame){
                for(var b=0,n=0;b<core.children.length;b++){
                    var prop=core.children[b]
                    if(prop.grade===grade){
                        if(n===index){
                            array.push([grade,index])
                            result.push(prop)
                            break
                        }else n++
                    }
                }
            }else i--
        }

        if(number===1)return result[0]
        else return result
    }

    //返回指定道具名对应的道具信息结构体
    function getProp(propName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName===propName)break
        }
        return core.children[i]
    }

    Item{
        //蝙蝠 1
        id: bat
        objectName: "bat"
        readonly property string propName: "蝙蝠"
        readonly property int grade: 1
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>生命窃取</font><br>
        <font color='red'>-2</font><font color='white'>收获</font><br>
        `
        function apply(){
            PlayerData.lifeSteal+=2
            PlayerData.harvesting-=2
        }
    }
    Item{
        //刺猬 2
        id:hedgehog
        objectName: "hedgehog"
        readonly property string propName: "刺猬"
        readonly property int grade: 1
        readonly property int basePrice: 30
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>近战伤害</font><br>
        <font color='green'>+1</font><font color='white'>远程伤害</font><br>
        <font color='red'>-1</font><font color='white'>生命恢复</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=2
            PlayerData.rangedDamage+=1
            PlayerData.hpRegeneration-=1
        }
    }
    Item{
        //头盔 3
        id:helmet
        objectName: "helmet"
        readonly property string propName: "头盔"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>护甲</font><br>
        <font color='red'>-2</font><font color='white'>速度</font><br>
        `
        function apply(){
            PlayerData.armor+=1
            PlayerData.speed-=2
        }
    }
    Item{
        //橡皮狂暴战士 4
        id: rubber_berserker
        objectName: "rubber_berserker"
        readonly property string propName: "橡皮狂暴战士"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'> 攻击速度</font><br>
        <font color='green'>+15</font><font color='white'>射程</font><br>
        <font color='red'>-1</font><font color='white'>护甲</font><br>
        `
        function apply(){
            PlayerData.lifeSteal+=2
            PlayerData.attackSpeed-=2
        }
    }
    Item{
        //颅脑损伤 5
        id: brain_injury
        objectName: "brain_injury"
        readonly property string propName: "颅脑损伤"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+6</font><font color='white'>伤害</font><br>
        <font color='red'>-8</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.damage+=6
            PlayerData.attackSpeed-=8
        }
    }
    Item{
        //咖啡 6
        id: coffee
        objectName: "coffee"
        readonly property string propName: "咖啡"
        readonly property int grade: 1
        readonly property int basePrice: 15
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+10</font><font color='white'>攻速</font><br>
        <font color='red'>-2</font><font color='white'>伤害</font><br>
        `
        function apply(){
            PlayerData.attackSpeed+=10
            PlayerData.damage-=2
        }
    }
    Item{
        //爪子树 7
        id:claw_tree
        objectName: "claw_tree"
        readonly property string propName: "爪子树"
        readonly property int grade: 1
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>近战伤害</font><br>
        <font color='green'>+3</font><font color='white'>暴击率</font><br>
        <font color='red'>-1</font><font color='white'>最大生命值</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=1
            PlayerData.critChance+=3
            PlayerData.maxHp-=1
        }
    }

    Item{
        //沸水 8
        id: boiling_water
        objectName: "boiling_water"
        readonly property string propName: "沸水"
        readonly property int grade: 1
        readonly property int basePrice: 30
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>元素伤害</font><br>
        <font color='red'>-1</font><font color='white'>最大生命值</font><br>
        `
        function apply(){
            PlayerData.elementalDamag+=2
            PlayerData.maxHp-=1
        }
    }

    Item{
        //书 9
        id: book
        objectName: "book"
        readonly property string propName: "书"
        readonly property int grade: 1
        readonly property int basePrice: 8
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>工程</font><br>
        `
        function apply(){
            PlayerData.engineering+=1
        }
    }
    Item{
        //破口 10
        id: break_through
        objectName: "break_through"
        readonly property string propName: "破口"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'>最大生命值</font><br>
        <font color='red'>-1</font><font color='white'>生命恢复</font><br>
        `
        function apply(){
            PlayerData.maxHp+=5
            PlayerData.hpRegeneration-=1
        }
    }
    Item{
        //蝴蝶 11
        id: butterfly
        objectName: "butterfly"
        readonly property string propName: "蝴蝶"
        readonly property int grade: 1
        readonly property int basePrice: 30
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>生命偷取</font><br>
        <font color='red'>-1</font><font color='white'>元素伤害</font><br>
        `
        function apply(){
            PlayerData.lifeSteal+=2
            PlayerData.elementalDamage-=1
        }
    }
    Item{
        //有缺陷的类固醇 12
        id: defective_steroids
        objectName: "defective_steroids"
        readonly property int grade: 1
        readonly property string propName: "有缺陷的类固醇"
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>近战伤害</font><br>
        <font color='green'>+2</font><font color='white'>最大生命值</font><br>
        <font color='red'>-3</font><font color='white'>攻击速度</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=2
            PlayerData.maxHp+=2
            PlayerData.attackSpeed-=3
        }
    }
    Item{
        //牛皮胶布 13
        id: duct_tape
        objectName: "duct_tape"
        readonly property string propName: "牛皮胶布"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>护甲</font><br>
        <font color='green'>+1</font><font color='white'>工程</font><br>
        <font color='red'>-2</font><font color='white'>最大生命</font><br>
        `
        function apply(){
            PlayerData.armor+=1
            PlayerData.engineering+=1
            PlayerData.maxHp-=2
        }
    }


    Item{
        //蛋糕 14
        id: cake
        objectName: "cake"
        readonly property string propName: "蛋糕"
        readonly property int grade: 1
        readonly property int basePrice: 15
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>最大生命</font><br>
        <font color='red'>-1</font><font color='white'>伤害</font><br>
        `
        function apply(){
            PlayerData.maxHp+=3
            PlayerData.damage-=1
        }
    }
    Item{
        //眼镜 15
        id: glasses
        objectName: "glasses"
        readonly property string propName: "眼镜"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+20</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.range+=20
        }
    }
    Item{
        //山羊头骨 16
        id: goat_skull
        objectName: "goat_skull"
        readonly property string propName: "山羊头骨"
        readonly property int grade: 1
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>近战伤害</font><br>
        <font color='red'>-2</font><font color='white'>暴击率</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=3
            PlayerData.critChance-=2
        }
    }

    Item{
        //小圆帽 17
        id: yarmulke
        objectName: "yarmulke"
        readonly property int grade: 1
        readonly property string propName: "小圆帽"
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+4</font><font color='white'>速度</font><br>
        <font color='red'>-6</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.speed+=4
            PlayerData.range-=6
        }
    }

    Item{
        //注射 18
        id: injection
        objectName: "injection"
        readonly property int grade: 1
        readonly property string propName: "注射"
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+7</font><font color='white'>伤害</font><br>
        <font color='red'>-2</font><font color='white'>最大生命</font><br>
        `
        function apply(){
            PlayerData.damage+=7
            PlayerData.maxHp-=2
        }
    }

    Item{
        //精神错乱 19
        id: insane
        objectName: "insane"
        readonly property string propName: "精神错乱"
        readonly property int grade: 1
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+6</font><font color='white'>暴击率</font><br>
        <font color='red'>-3</font><font color='white'>伤害</font><br>
        `
        function apply(){
            PlayerData.critChance+=6
            PlayerData.damage-=3
        }
    }
    Item{
        //镜头 20
        id: lens
        objectName: "lens"
        readonly property string propName: "镜头"
        readonly property int grade: 1
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>远程伤害</font><br>
        <font color='red'>-5</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.rangedDamage+=1
            PlayerData.range-=5
        }
    }
    Item{
        //迷失之鸭 21
        id: lost_duck
        objectName: "lost_duck"
        readonly property int grade: 1
        readonly property string propName: "迷失之鸭"
        readonly property int basePrice: 25
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+10</font><font color='white'>运气</font><br>
        <font color='red'>-1</font><font color='white'>元素伤害</font><br>
        `
        function apply(){
            PlayerData.luck+=10
            PlayerData.elementalDamage-=1
        }
    }
    Item{
        //螺旋桨帽子 22
        id: propeller_hat
        objectName: "propeller_hat"
        readonly property int grade: 1
        readonly property string propName: "螺旋桨帽子"
        readonly property int basePrice: 28
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+10</font><font color='white'>运气</font><br>
        <font color='red'>-2</font><font color='white'>伤害</font><br>
        `
        function apply(){
            PlayerData.luck+=10
            PlayerData.Damage-=2
        }
    }
    Item{
        //恐怖洋葱 23
        id: terrifying_onion
        objectName: "terrifying_onion"
        readonly property int grade: 1
        readonly property string propName: "恐怖洋葱"
        readonly property int basePrice: 15
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+4</font><font color='white'>速度</font><br>
        <font color='red'>-6</font><font color='white'>运气</font><br>
        `
        function apply(){
            PlayerData.speed+=4
            PlayerData.luck-=6
        }
    }
    Item{
        //有毒的烂泥 24
        id: toxic_sludge
        objectName: "toxic_sludge"
        readonly property string propName: "有毒的烂泥"
        readonly property int grade: 1
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>元素伤害</font><br>
        <font color='red'>-2</font><font color='white'>闪避</font><br>
        `
        function apply(){
            PlayerData.elementalDamage+=2
            PlayerData.dodge-=2
        }
    }
    Item{
        //煤炭 25
        id: coal
        objectName: "coal"
        readonly property int grade: 1
        readonly property string propName: "煤炭"
        readonly property int basePrice: 20
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+1</font><font color='white'>元素伤害</font><br>
        <font color='green'>+2</font><font color='white'>近战伤害</font><br>
        <font color='red'>-2</font><font color='white'>收获</font><br>
        `
        function apply(){
            PlayerData.elementalDamage+=1
            PlayerData.meleeDamage+=2
            PlayerData.harvesting-=2
        }
    }
    Item{
        //肥料 26
        id: fertilizer
        objectName: "fertilizer"
        readonly property int grade: 1
        readonly property string propName: "肥料"
        readonly property int basePrice: 15
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+8</font><font color='white'>收获</font><br>
        <font color='red'>-1</font><font color='white'>近战伤害</font><br>
        `
        function apply(){
            PlayerData.harvesting+=8
            PlayerData.meleeDamage-=2
        }
    }



    Item{
        //酸液 1
        id: acid_liquor
        objectName: "acid_liquor"
        readonly property int grade: 2
        readonly property string propName: "酸液"
        readonly property int basePrice: 65
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+8</font><font color='white'>最大生命值</font><br>
        <font color='red'>-4</font><font color='white'>闪避</font><br>
        `
        function apply(){
            PlayerData.maxHp+=8
            PlayerData.dodge-=4
        }
    }
    Item{
        //能量手镯 2
        id: energy_bracelet
        objectName: "energy_bracelet"
        readonly property int grade: 2
        readonly property string propName: "能量手镯"
        readonly property int basePrice: 55
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+4</font><font color='white'>暴击率</font><br>
        <font color='green'>+2</font><font color='white'>元素伤害</font><br>
        <font color='red'>-2</font><font color='white'>远程伤害</font><br>
        `
        function apply(){
            PlayerData.critChance+=4
            PlayerData.elementalDamage+=2
            PlayerData.rangedDamage-=2
        }
    }

    Item{
        //齿轮 3
        id: gear
        objectName: "gear"
        readonly property int grade: 2
        readonly property string propName: "齿轮"
        readonly property int basePrice: 35
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+4</font><font color='white'>工程</font><br>
        <font color='red'>-4</font><font color='white'>伤害</font><br>
        `
        function apply(){
            PlayerData.engineering+=8
            PlayerData.damage-=4
        }
    }
    Item{
        //独眼虫 4
        id: cyclops_beetle
        objectName: "cyclops_beetle"
        readonly property int grade: 2
        readonly property string propName: "独眼虫"
        readonly property int basePrice: 45
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+12</font><font color='white'>伤害</font><br>
        <font color='red'>-12</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.damage+=12
            PlayerData.range-=12
        }
    }
    Item{
        //燃料箱 5
        id: fuel_tank
        objectName: "fuel_tank"
        readonly property int grade: 2
        readonly property string propName: "燃料箱"
        readonly property int basePrice: 45
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+4</font><font color='white'>元素伤害</font><br>
        <font color='red'>-1</font><font color='white'>近战伤害</font><br>
        <font color='red'>-1</font><font color='white'>远程伤害</font><br>
        `
        function apply(){
            PlayerData.elementalDamage+=4
            PlayerData.meleeDamage-=1
            PlayerData.rangedDamage-=1
        }
    }
    Item{
        //筹码 6
        id: chip
        objectName: "chip"
        readonly property int grade: 2
        readonly property string propName: "筹码"
        readonly property int basePrice: 60
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+8</font><font color='white'>闪避</font><br>
        <font color='red'>-1</font><font color='white'>护甲</font><br>
        `
        function apply(){
            PlayerData.dodge+=8
            PlayerData.armor-=1
        }
    }

    Item{
        //营火 7
        id: campfire
        objectName: "campfire"
        readonly property int grade: 2
        readonly property string propName: "营火"
        readonly property int basePrice: 40
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>元素伤害</font><br>
        <font color='green'>+2</font><font color='white'>生命恢复</font><br>
        <font color='red'>-2</font><font color='white'>速度</font><br>
        `
        function apply(){
            PlayerData.elementalDamage+=2
            PlayerData.hpRegeneration+=2
            PlayerData.speed-=2
        }
    }

    Item{
        //黑带 8
        id: black_belt
        objectName: "black_belt"
        readonly property int grade: 2
        readonly property string propName: "黑带"
        readonly property int basePrice: 50
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+25</font><font color='white'>经验获取</font><br>
        <font color='green'>+3</font><font color='white'>近战伤害</font><br>
        <font color='red'>-8</font><font color='white'>运气</font><br>
        `
        function apply(){
            //差次要属性经验获取
            PlayerData.meleeDamage+=3
            PlayerData.luck-=8
        }
    }

    Item{
        //眼罩 9
        id: patch
        objectName: "patch"
        readonly property int grade: 2
        readonly property string propName: "眼罩"
        readonly property int basePrice: 45
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'>暴击率</font><br>
        <font color='green'>+5</font><font color='white'>闪避</font><br>
        <font color='red'>-15</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.critChance+=5
            PlayerData.dodge+=5
            PlayerData.range-=15
        }
    }

    Item{
        //旗帜 10
        id: flag
        objectName: "flag"
        readonly property int grade: 2
        readonly property int basePrice: 55
        readonly property string propName: "旗帜"
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+20</font><font color='white'>射程</font><br>
        <font color='green'>+10</font><font color='white'>攻击速度</font><br>
        <font color='red'>-2</font><font color='white'>生命窃取</font><br>
        `
        function apply(){
            PlayerData.range+=20
            PlayerData.attackSpeed+=10
            PlayerData.lifeSteal-=2
        }
    }

    Item{
        //皮制背心 11
        id: leather_vest
        objectName: "leather_vest"
        readonly property int grade: 2
        readonly property string propName: "皮制背心"
        readonly property int basePrice: 45
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>护甲</font><br>
        <font color='green'>+6</font><font color='white'>闪避</font><br>
        <font color='red'>-3</font><font color='white'>最大生命</font><br>
        `
        function apply(){
            PlayerData.armor+=2
            PlayerData.dodge+=6
            PlayerData.maxHp-=3
        }
    }
    Item{
        //小肌肉男 12
        id: small_muscle_man
        objectName: "small_muscle_man"
        readonly property int grade: 2
        readonly property string propName: "小肌肉男"
        readonly property int basePrice: 50
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>近战伤害</font><br>
        <font color='green'>+5</font><font color='white'>最大生命</font><br>
        <font color='red'>-15</font><font color='white'>射程</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=3
            PlayerData.maxHp+=5
            PlayerData.range-=15
        }
    }
    Item{
        //精通 13
        id: master
        objectName: "master"
        readonly property int grade: 2
        readonly property string propName: "精通"
        readonly property int basePrice: 55
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+6</font><font color='white'>近战伤害</font><br>
        <font color='red'>-3</font><font color='white'>远程伤害</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=6
            PlayerData.rangedDamage-=3
        }
    }
    Item{
        //奖牌 14
        id: medal
        objectName: "medal"
        readonly property int grade: 2
        readonly property string propName: "奖牌"
        readonly property int basePrice: 55
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>伤害</font><br>
        <font color='green'>+3</font><font color='white'>速度</font><br>
        <font color='green'>+1</font><font color='white'>护甲</font><br>
        <font color='green'>+3</font><font color='white'>最大生命</font><br>
        <font color='red'>-4</font><font color='white'>暴击率</font><br>
        `
        function apply(){
            PlayerData.damage+=3
            PlayerData.speed+=3
            PlayerData.armor+=1
            PlayerData.maxHp+=3
            PlayerData.critChance-=4
        }
    }


    Item{
        //外星人宝宝 1
        id: alien_baby
        objectName: "alien_baby"
        readonly property int grade: 3
        readonly property string propName: "外星人宝宝"
        readonly property int basePrice: 80
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+15</font><font color='white'>最大生命值</font><br>
        <font color='green'>+8</font><font color='white'>敌人移动速度</font><br>
        `
        function apply(){
            PlayerData.maxHp+=15
            //差敌人移动速度
        }
    }
    Item{
        //外星人魔法 2
        id: alien_magic
        objectName: "alien_magic"
        readonly property int grade: 3
        readonly property string propName: "外星人魔法"
        readonly property int basePrice: 85
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+8</font><font color='white'>最大生命值</font><br>
        <font color='green'>+3</font><font color='white'>生命恢复</font><br>
        <font color='red'>-8</font><font color='white'>运气</font><br>
        `
        function apply(){
            PlayerData.maxHp+=8
            PlayerData.hpRegeneration+=3
            PlayerData.luck-=8
        }
    }
    Item{
        //四叶草 3
        id: clover
        objectName: "clover"
        readonly property int grade: 3
        readonly property string propName: "四叶草"
        readonly property int basePrice: 65
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+20</font><font color='white'>运气</font><br>
        <font color='green'>+6</font><font color='white'>闪避</font><br>
        <font color='red'>-2</font><font color='white'>生命偷取</font><br>
        `
        function apply(){
            PlayerData.luck+=20
            PlayerData.dodge+=6
            PlayerData.lifeSteal-=2
        }
    }
    Item{
        //合金 4
        id: alloy
        objectName: "alloy"
        readonly property int grade: 3
        readonly property string propName: "合金"
        readonly property int basePrice: 80
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>近战伤害</font><br>
        <font color='green'>+3</font><font color='white'>远程伤害</font><br>
        <font color='green'>+3</font><font color='white'>元素伤害</font><br>
        <font color='green'>+3</font><font color='white'>工程</font><br>
        <font color='green'>+5</font><font color='white'>暴击率</font><br>
        <font color='red'>-6</font><font color='white'>闪避</font><br>
        `
        function apply(){
            PlayerData.meleeDamage+=3
            PlayerData.rangedDamage+=3
            PlayerData.elementalDamage+=3
            PlayerData.engineering+=3
            PlayerData.critChance+=5
            PlayerData.dodge-=6
        }
    }
    Item{
        //有毒补药 5
        id: toxic_tonics
        objectName: "toxic_tonics"
        readonly property int grade: 3
        readonly property string propName: "有毒补药"
        readonly property int basePrice: 80
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+10</font><font color='white'>攻速</font><br>
        <font color='green'>+5</font><font color='white'>暴击率</font><br>
        <font color='green'>+15</font><font color='white'>射程</font><br>
        <font color='red'>-2</font><font color='white'>生命恢复</font><br>
        `
        function apply(){
            PlayerData.attackSpeed+=10
            PlayerData.critChance+=5
            PlayerData.range+=15
            PlayerData.hpRegeneration-=2
        }
    }
    Item{
        //Shmoop  6
        id: shmoop
        objectName: "shmoop"
        readonly property int grade: 3
        readonly property string propName: "Shmoop"
        readonly property int basePrice: 60
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+6</font><font color='white'>最大生命</font><br>
        <font color='green'>+2</font><font color='white'>生命恢复</font><br>
        <font color='red'>-2</font><font color='white'>近战伤害</font><br>
        <font color='red'>-1</font><font color='white'>远程伤害</font><br>
        `
        function apply(){
            PlayerData.maxHp+=6
            PlayerData.hpRegeneration+=2
            PlayerData.meleeDamage-=2
            PlayerData.rangedDamage-=1
        }
    }

    Item{
        //工具箱  7
        id: toolbox
        objectName: "toolbox"
        readonly property int grade: 3
        readonly property string propName: "工具箱"
        readonly property int basePrice: 55
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+6</font><font color='white'>工程</font><br>
        <font color='red'>-8</font><font color='white'>攻击速度</font><br>
        `
        function apply(){
            PlayerData.engineering+=6
            PlayerData.attackSpeed-=8
        }
    }
    Item{
        //守卫头盔  8
        id: guard_helmet
        objectName: "guard_helmet"
        readonly property int grade: 3
        readonly property string propName: "守卫头盔"
        readonly property int basePrice: 80
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+3</font><font color='white'>护甲</font><br>
        <font color='green'>+5</font><font color='white'>最大生命</font><br>
        <font color='red'>-5</font><font color='white'>速度</font><br>
        `
        function apply(){
            PlayerData.armor+=3
            PlayerData.maxHp+=5
            PlayerData.speed-=5
        }
    }
    Item{
        //玻璃大炮  9
        id: glass_cannon
        objectName: "glass_cannon"
        readonly property int grade: 3
        readonly property string propName: "玻璃大炮"
        readonly property int basePrice: 75
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+25</font><font color='white'>伤害</font><br>
        <font color='red'>-3</font><font color='white'>护甲</font><br>
        `
        function apply(){
            PlayerData.damage+=3
            PlayerData.armor-=5
        }
    }


    Item{
        //斗篷 1
        id: cloak
        objectName: "cloak"
        readonly property int grade: 4
        readonly property string propName: "斗篷"
        readonly property int basePrice: 110
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'>生命偷取</font><br>
        <font color='green'>+20</font><font color='white'>闪避</font><br>
        <font color='red'>-2</font><font color='white'>近战伤害</font><br>
        <font color='red'>-2</font><font color='white'>远程伤害</font><br>
        <font color='red'>-2</font><font color='white'>元素伤害</font><br>
        `
        function apply(){
            PlayerData.lifeSteal+=5
            PlayerData.dodge+=20
            PlayerData.meleeDamage-=2
            PlayerData.rangedDamage-=2
            PlayerData.elementalDamage-=2
        }
    }
    Item{
        //外骨骼 2
        id: exoskeleton
        objectName: "exoskeleton"
        readonly property int grade: 4
        readonly property string propName: "外骨骼"
        readonly property int basePrice: 90
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'>护甲</font><br>
        <font color='green'>+5</font><font color='white'>暴击率</font><br>
        <font color='green'>+5</font><font color='white'>工程</font><br>
        <font color='green'>+5</font><font color='white'>闪避</font><br>
        <font color='red'>-2</font><font color='white'>生命恢复</font><br>
        <font color='red'>-2</font><font color='white'>生命偷取</font><br>
        `
        function apply(){
            PlayerData.armor+=5
            PlayerData.critChance+=5
            PlayerData.engineering+=5
            PlayerData.dodge+=5
            PlayerData.hpRegeneration-=2
            PlayerData.lifeSteal-=2
        }
    }
    Item{
        //重子弹 3
        id: heavy_bullets
        objectName: "heavy_bullets"
        readonly property int grade: 4
        readonly property string propName: "重子弹"
        readonly property int basePrice: 100
        property int curPrice: Math.ceil(basePrice*Math.pow(1.1,PlayerData.currentWaveNumber)*PlayerData.goodsDiscountRate)
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+5</font><font color='white'>远程伤害</font><br>
        <font color='green'>+10</font><font color='white'>伤害</font><br>
        <font color='green'>+10</font><font color='white'>射程</font><br>
        <font color='red'>-5</font><font color='white'>攻击速度</font><br>
        <font color='red'>-5</font><font color='white'>暴击率</font><br>
        `
        function apply(){
            PlayerData.rangedDamage+=5
            PlayerData.damage+=10
            PlayerData.range+=10
            PlayerData.attackSpeed-=5
            PlayerData.critChance-=5
        }
    }
}
