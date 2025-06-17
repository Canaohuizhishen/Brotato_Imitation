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
    function getPropRandomly(n){
        var result=[]//存储所有选中的道具
        var array=[]//存储所有选中的道具的等级和索引，便于查重
        var random//存储随机数
        var probability
        var grade
        var index
        for(var i=0;i<n;i++){
            //获得随机等级
            random=Math.random()*(grade_one_prop_spawn_probability+grade_two_prop_spawn_probability+grade_three_prop_spawn_probability+grade_four_prop_spawn_probability)
            probability=grade_four_prop_spawn_probability
            grade
            if(random<probability){
                grade=4
                probability+=grade_three_prop_spawn_probability
            }else if(random<probability){
                grade=3
                probability+=grade_two_prop_spawn_probability
            }else if(random<probability){
                grade=2
            }else grade=1

            //获得随机索引
            index
            switch(grade){
            case 1: index=Math.floor(Math.random()*grade_one_prop_number);break;
            case 2: index=Math.floor(Math.random()*grade_two_prop_number);break;
            case 3: index=Math.floor(Math.random()*grade_three_prop_number);break;
            case 4: index=Math.floor(Math.random()*grade_four_prop_number);break;
            default: console.log("getPropRandomly():无效的等级:",grade)
            }

            //查重
            var isSame=false
            for(var i=0,n=0;i<array.length;i++){
                if(array[i][0]==grade && array[i][1]==index){
                    isSame=true
                    break
                }
            }

            //存储结果
            if(!isSame){
                for(var i=0,n=0;i<core.children.length;i++){
                    var prop=core.children[i]
                    if(prop.grade==grade){
                        if(n==index){
                            array.push([grade,index])
                            result.push(prop)
                        }else n++
                    }
                }
            }
        }

        return result
    }

    //返回指定道具名对应的道具信息结构体
    function getProp(propName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==propName)break
        }
        return core.children[i]
    }

    Item{
        id: flag
        objectName: "flag"
        property string propName: "旗帜"
        readonly property int grade: 2
        readonly property int basePrice: 55
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
        id: bat
        objectName: "bat"
        property string propName: "蝙蝠"
        readonly property int grade: 1
        readonly property int basePrice: 20
        readonly property string type: "道具"
        readonly property string talentText: `
        <font color='green'>+2</font><font color='white'>生命窃取</font><br>
        <font color='red'>-2</font><font color='white'>收获</font><br>
        `
        function apply(){
            PlayerData.lifeSteal+=2
            PlayerData.attackSpeed-=2
        }
    }
}
