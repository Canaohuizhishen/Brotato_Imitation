import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property int grade_one_prop_number: 0
    property int grade_two_prop_number: 0
    property int grade_three_prop_number: 0
    property int grade_four_prop_number: 0
    property double grade_one_prop_spawn_probability: 0.5065
    property double grade_two_prop_spawn_probability: 0.25
    property double grade_three_prop_spawn_probability: 0.125
    property double grade_four_prop_spawn_probability: 0.065

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

    function getPropRandomly(){
        var grade=Math.floor(Math.random()*4)+1
        var index
        switch(grade){
        case 1: index=Math.floor(Math.random()*grade_one_prop_number);break;
        case 2: index=Math.floor(Math.random()*grade_two_prop_number);break;
        case 3: index=Math.floor(Math.random()*grade_three_prop_number);break;
        case 4: index=Math.floor(Math.random()*grade_four_prop_number);break;
        default: console.log("getPropRandomly():无效的等级:",grade)
        }
        for(var i=0,n=0;i<core.children.length;i++){
            var prop=core.children[i]
            if(prop.grade==grade){
                if(n==index){
                    return prop
                }else n++
            }
        }
    }

    function getProp(propName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==propName)break
        }
        return core.children[i]
    }

    Item{
        id: flag
        objectName: "flag"
        readonly property int grade: 2
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
        readonly property int grade: 1
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
