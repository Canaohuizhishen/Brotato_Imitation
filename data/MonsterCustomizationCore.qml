import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property int waveNumber: 1
    property alias babyAlien: babyAlien
    property alias chaser: chaser

    onWaveNumberChanged: {
        init()
        switch(waveNumber){
        case 1:{
            babyAlien.initCount=4
        }break;
        case 2:{
            babyAlien.initCount=4
            chaser.initCount=3
        }break;
        case 3:{
            babyAlien.initCount=5
            chaser.initCount=3
        }break;
        case 4:{
            babyAlien.initCount=6
        }
        }
    }

    function getMonster(monsterName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName==monsterName)break
        }
        return core.children[i]
    }

    function init(){
        for(var i=0;i<core.children.length;i++){
            core.children[i].init()
        }
    }

    Item{
        id: babyAlien
        objectName: "外星人宝宝"
        readonly property string source: "BabyAlien.qml"
        readonly property int initHp: 3
        readonly property int hpBonus: 2
        readonly property int initVelocity: 200
        readonly property int maxVelocity: 300
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.6
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01
        readonly property double chestDropRate: 0.01

        property double initCount: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: chaser
        objectName: "追逐者"
        readonly property string source: "Chaser.qml"
        readonly property int initHp: 1
        readonly property int hpBonus: 1
        readonly property int initVelocity: 380
        readonly property int maxVelocity: 380
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.6
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.02
        readonly property double chestDropRate: 0.03

        property double initCount: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }
}
