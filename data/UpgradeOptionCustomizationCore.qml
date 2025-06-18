import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property int optionNumber: core.children.length
    property double grade_one_option_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_option_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_option_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_option_spawn_probability: 0.065*(1+PlayerData.luck/125)

    //返回指定等级的指定升级选项名对应的升级选项信息结构体
    function getUpgradeOption(grade,optionName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==optionName)break
        }
        core.children[i].grade=grade
        return core.children[i]
    }

    //返回随机不重复的n个升级选项信息结构体
    function getOptionRandomly(n){
        init()
        var result=[]//存储所有选中的升级选项
        var array=[]//存储所有选中的升级选项的索引，便于查重
        var random//存储随机数
        var probability
        var grade
        var index
        for(var i=0;i<n;i++){
            //获得随机等级
            random=Math.random()*(grade_one_option_spawn_probability+grade_two_option_spawn_probability+grade_three_option_spawn_probability+grade_four_option_spawn_probability)
            probability=grade_four_option_spawn_probability
            grade
            if(random<probability){
                grade=4
                probability+=grade_three_option_spawn_probability
            }else if(random<probability){
                grade=3
                probability+=grade_two_option_spawn_probability
            }else if(random<probability){
                grade=2
            }else grade=1

            //获得随机索引
            index=Math.floor(Math.random()*optionNumber)

            //查重
            var isSame=false
            for(var i=0;i<array.length;i++){
                if(array[i]==index){
                    isSame=true
                    break
                }
            }

            //存储结果
            if(!isSame){
                array.push(index)
                core.children[index].grade=grade
                result.push(core.children[index])
            }else i--
        }

        return result
    }

    function init(){
        for(var i=0;i<core.children.length;i++){
            core.children[i].grade=1
        }
    }

    Item{
        id: leg
        objectName: "leg"
        property int grade: 1
        property int value: 3*Math.pow(2,grade-1)
        property string optionName: "腿"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>%速度</font><br>
        `
        function choose(){
            PlayerData.speed+=value
        }
    }

    Item{
        id: chest
        objectName: "chest"
        property int grade: 1
        property int value: 1*Math.pow(2,grade-1)
        property string optionName: "胸"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>护甲</font><br>
        `
        function choose(){
             PlayerData.armor+=value
        }
    }
    Item{
        id: skull
        objectName: "skull"
        property int grade: 1
        property int value: 2*Math.pow(2,grade-1)
        property string optionName: "头骨"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>工程学</font><br>
        `
        function choose(){
            PlayerData.engineering+=value
        }
    }
    Item{
        id: lung
        objectName: "lung"
        property int grade: 1
        property int value: 2*Math.pow(2,grade-1)
        property string optionName: "肺"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>生命恢复</font><br>
        `
        function choose(){
            PlayerData.hpRegeneration+=value
        }
    }
    Item{
        id: finger
        objectName: "finger"
        property int grade: 1
        property int value: 3*Math.pow(2,grade-1)
        property string optionName: "手指"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>暴击率</font><br>
        `
        function choose(){
        PlayerData.critChance+=value
        }
    }
    Item{
        id: back
        objectName: "back"
        property int grade: 1
        property int value: 3*Math.pow(2,grade-1)
        property string optionName: "背"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>闪避</font><br>
        `
        function choose(){
        PlayerData.dodge+=value
        }
    }
    Item{
        id: teeth
        objectName: "teeth"
        property int grade: 1
        property int value: 1*Math.pow(2,grade-1)
        property string optionName: "牙齿"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>生命窃取</font><br>
        `
        function choose(){
        PlayerData.lifeSteal+=value
        }
    }
    Item{
        id: heart
        objectName: "heart"
        property int grade: 1
        property int value: 3*Math.pow(2,grade-1)
        property string optionName: "心脏"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>最大生命值</font><br>
        `
        function choose(){
        PlayerData.maxHp+=value
        }
    }
    Item{
        id: brain
        objectName: "brain"
        property int grade: 1
        property int value: 1*Math.pow(2,grade-1)
        property string optionName: "脑"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>元素伤害</font><br>
        `
        function choose(){
        PlayerData.elementalDamage+=value
        }
    }
    Item{
        id: reflexes
        objectName: "reflexes"
        property int grade: 1
        property int value: 5*Math.pow(2,grade-1)
        property string optionName: "反应能力"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>攻击速度</font><br>
        `
        function choose(){
        PlayerData.attackSpeed+=value
        }
    }
    Item{
        id: nose
        objectName: "nose"
        property int grade: 1
        property int value: 5*Math.pow(2,grade-1)
        property string optionName: "鼻"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>幸运</font><br>
        `
        function choose(){
        PlayerData.luck+=value
        }
    }
    Item{
        id: hand
        objectName: "hand"
        property int grade: 1
        property int value: 5*Math.pow(2,grade-1)
        property string optionName: "手"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>收获</font><br>
        `
        function choose(){
        PlayerData.harvesting+=value
        }
    }
    Item{
        id: shoulder
        objectName: "shoulder"
        property int grade: 1
        property int value: 1*Math.pow(2,grade-1)
        property string optionName: "肩"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>远程伤害</font><br>
        `
        function choose(){
        PlayerData.rangedDamage+=value
        }
    }
    Item{
        id: foream
        objectName: "foream"
        property int grade: 1
        property int value: 2*Math.pow(2,grade-1)
        property string optionName: "前臂"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>近战伤害</font><br>
        `
        function choose(){
        PlayerData.meleeDamage+=value
        }
    }
    Item{
        id: triceps
        objectName: "triceps"
        property int grade: 1
        property int value: 5*Math.pow(2,grade-1)
        property string optionName: "三头肌"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>伤害</font><br>
        `
        function choose(){
        PlayerData.damage+=value
        }
    }
    Item{
        id: eyes
        objectName: "eyes"
        property int grade: 1
        property int value: 15*Math.pow(2,grade-1)
        property string optionName: "眼睛"
        readonly property string type: "升级"
        readonly property string talentText: `
        <font color='lime'>+`+value+`</font><font color='white'>范围</font><br>
        `
        function choose(){
        PlayerData.range+=value
        }
    }
}
