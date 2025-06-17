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
            for(var i=0,n=0;i<array.length;i++){
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
            }
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
}
