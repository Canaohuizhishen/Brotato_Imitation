pragma Singleton
import QtQuick 2.15
import singleton.PlayerData

Item {
    id: core
    property double velocityRate: 0.8
    property int waveNumber: PlayerData.currentWaveNumber
    property alias tree: tree
    property alias babyAlien: babyAlien
    property alias chaser: chaser
    property alias charger: charger
    property alias sprayer: sprayer
    property alias pursuer: pursuer
    property alias brute: brute
    property alias helmetAlien: helmetAlien
    property alias finChaser: finChaser
    property alias summoner: summoner
    property alias scavenger: scavenger
    property alias helmetBrute: helmetBrute
    property alias helmetCharger: helmetCharger
    property alias prayer: prayer

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
            sprayer.initCount=2
        }break;
        case 5:{
            babyAlien.initCount=4
            chaser.initCount=3
            sprayer.initCount=1
        }break;
        case 6:{
            babyAlien.initCount=7
            chaser.initCount=3
            charger.initCount=4
        }break;
        case 7:{
            babyAlien.initCount=3
            charger.initCount=6
            sprayer.initCount=3
        }break;
        case 8:{
            babyAlien.initCount=4
            sprayer.initCount=2
            brute.initCount=3
        }break;
        case 9:{
            chaser.initCount=6
            charger.initCount=2
            brute.initCount=2
        }break;
        case 10:{
            babyAlien.initCount=4
            chaser.initCount=4
            charger.initCount=2
            brute.initCount=1
        }break;
        case 11:{
            babyAlien.initCount=4
            charger.initCount=4
            sprayer.initCount=2
            pursuer.initCount=1
        }break;
        case 12:{
            babyAlien.initCount=5
            charger.initCount=4
            pursuer.initCount=1
            brute.initCount=2
        }break;
        case 13:{
            babyAlien.initCount=3
            charger.initCount=3
            pursuer.initCount=1
            brute.initCount=1
            helmetBrute.initCount=2
            helmetAlien.initCount=3
        }break;
        case 14:{
            babyAlien.initCount=3
            brute.initCount=1
            helmetAlien.initCount=4
            summoner.initCount=1
        }break;
        case 15:{
            babyAlien.initCount=3
            sprayer.initCount=1
            helmetAlien.initCount=4
            summoner.initCount=1
            finChaser.initCount=3
        }break;
        case 16:{
            babyAlien.initCount=3
            brute.initCount=1
            helmetAlien.initCount=4
            finChaser.initCount=3
            helmetBrute.initCount=1
        }break;
        case 17:{
            babyAlien.initCount=3
            pursuer.initCount=2
            helmetAlien.initCount=4
            finChaser.initCount=3
            summoner.initCount=1
        }break;
        case 18:{
            sprayer.initCount=2
            helmetAlien.initCount=5
            summoner.initCount=1
            helmetCharger.initCount=3
        }break;
        case 19:{
            babyAlien.initCount=3
            sprayer.initCount=2
            pursuer.initCount=2
            helmetAlien.initCount=4
            summoner.initCount=1
            helmetBrute.initCount=2
            helmetCharger.initCount=3
        }break;
        case 20:{
            babyAlien.initCount=3
            sprayer.initCount=2
            pursuer.initCount=2
            helmetAlien.initCount=4
            finChaser.initCount=3
            summoner.initCount=1
            helmetBrute.initCount=2
            prayer.initCount=1
        }break;
        }
    }

    function getMonster(monsterName){
        for(var i=0;i<core.children.length;i++){
            if(core.children[i].objectName===monsterName || core.children[i].monsterName===monsterName){
                return core.children[i]
            }
        }
        console.error("MonstersData.getMonster: '" + monsterName + "' not found")
        return null
    }

    function init(){
        for(var i=0;i<core.children.length;i++){
            core.children[i].init()
        }
    }

    Item{
        id: tree
        objectName: "tree"
        property string monsterName: "树"
        readonly property string source: "Tree.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 20

        readonly property int initHp: 3
        readonly property double hpBonus: 2
        readonly property int initVelocity: 0
        readonly property int maxVelocity: 0
        readonly property int initDamage: 0
        readonly property double damageBonus: 0
        readonly property int materialDrops: 3
        readonly property double consumableDropRate: 1*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.05*(1+PlayerData.luck/100)

        property int initCount: 1
        property int curNumber: 0
        property double countRation: 0.9
        readonly property double countIcreaseRation: 0.05

        onCountRationChanged: {
            if(countRation>=1+countIcreaseRation){
                countRation=0.8
            }
        }

        function init(){
            initCount=1
            countRation=0.9
        }
    }

    Item{
        id: babyAlien
        objectName: "babyAlien"
        property string monsterName: "外星婴儿"
        readonly property string source: "BabyAlien.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 50

        readonly property int initHp: 3
        readonly property double hpBonus: 2
        readonly property int initVelocity: 250*core.velocityRate
        readonly property int maxVelocity: 300*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.6
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: chaser
        objectName: "chaser"
        property string monsterName: "追逐者"
        readonly property string source: "Chaser.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 25

        readonly property int initHp: 1
        readonly property double hpBonus: 1
        readonly property int initVelocity: 380*core.velocityRate
        readonly property int maxVelocity: 380*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.6
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.02*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.03*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: sprayer
        objectName: "sprayer"
        property string monsterName: "喷射者"
        readonly property string source: "Sprayer.qml"
        readonly property int attackRange: 400
        readonly property int maxCurNumber: 15

        readonly property int initHp: 8
        readonly property double hpBonus: 1
        readonly property int initVelocity: 200*core.velocityRate
        readonly property int maxVelocity: 200*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.6
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.03*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.1*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: charger
        objectName: "charger"
        property string monsterName: "冲锋者"
        readonly property string source: "Charger.qml"
        readonly property int attackRange: 200
        readonly property int maxCurNumber: 15

        readonly property int initHp: 4
        readonly property double hpBonus: 2.5
        readonly property int initVelocity: 400*core.velocityRate
        readonly property int maxVelocity: 400*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.85
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: brute
        objectName: "brute"
        property string monsterName: "大块头"
        readonly property string source: "Brute.qml"
        readonly property int attackRange: 300
        readonly property int maxCurNumber: 10

        readonly property int initHp: 20
        readonly property double hpBonus: 11
        readonly property int initVelocity: 300*core.velocityRate
        readonly property int maxVelocity: 300*core.velocityRate
        readonly property int initDamage: 2
        readonly property double damageBonus: 0.85
        readonly property int materialDrops: 3
        readonly property double consumableDropRate: 0.03*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.03*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: pursuer
        objectName: "pursuer"
        property string monsterName: "追击者"
        readonly property string source: "Pursuer.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 10

        readonly property int initHp: 10
        readonly property double hpBonus: 2.4
        readonly property int initVelocity: 150*core.velocityRate
        readonly property int maxVelocity: 600*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1.5
        readonly property int materialDrops: 3
        readonly property double consumableDropRate: 0.03*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.03*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: helmetAlien
        objectName: "helmetAlien"
        property string monsterName: "戴头盔的外星人"
        readonly property string source: "HelmetAlien.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 30

        readonly property int initHp: 8
        readonly property double hpBonus: 3
        readonly property int initVelocity: 225*core.velocityRate
        readonly property int maxVelocity: 275*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: finChaser
        objectName: "finChaser"
        property string monsterName: "鱼鳍追逐者"
        readonly property string source: "FinChaser.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 25

        readonly property int initHp: 12
        readonly property double hpBonus: 2
        readonly property int initVelocity: 400*core.velocityRate
        readonly property int maxVelocity: 400*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.02*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.03*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: summoner
        objectName: "summoner"
        property string monsterName: "召唤者"
        readonly property string source: "Summoner.qml"
        readonly property int attackRange: 0
        readonly property int maxCurNumber: 10

        readonly property int initHp: 10
        readonly property double hpBonus: 1
        readonly property int initVelocity: 120*core.velocityRate
        readonly property int maxVelocity: 120*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 0.85
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: scavenger
        objectName: "scavenger"
        property string monsterName: "拾荒者"
        readonly property string source: "Scavenger.qml"
        readonly property int attackRange: 10000
        readonly property int maxCurNumber: 30

        readonly property int initHp: 20
        readonly property double hpBonus: 5
        readonly property int initVelocity: 350*core.velocityRate
        readonly property int maxVelocity: 350*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: helmetBrute
        objectName: "helmetBrute"
        property string monsterName: "头盔大块头"
        readonly property string source: "HelmetBrute.qml"
        readonly property int attackRange: 300
        readonly property int maxCurNumber: 10

        readonly property int initHp: 30
        readonly property double hpBonus: 22
        readonly property int initVelocity: 300*core.velocityRate
        readonly property int maxVelocity: 300*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1.15
        readonly property int materialDrops: 3
        readonly property double consumableDropRate: 0.03*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.03*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: helmetCharger
        objectName: "helmetCharger"
        property string monsterName: "头盔冲锋者"
        readonly property string source: "HelmetCharger.qml"
        readonly property int attackRange: 200
        readonly property int maxCurNumber: 15

        readonly property int initHp: 12
        readonly property double hpBonus: 5
        readonly property int initVelocity: 425*core.velocityRate
        readonly property int maxVelocity: 425*core.velocityRate
        readonly property int initDamage: 1
        readonly property double damageBonus: 1
        readonly property int materialDrops: 1
        readonly property double consumableDropRate: 0.01*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0.01*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05

        function init(){
            initCount=0
            countRation=1
        }
    }

    Item{
        id: prayer
        objectName: "prayer"
        property string monsterName: "祈祷者"
        readonly property string source: "Prayer.qml"
        readonly property int attackRange: 10000
        readonly property int maxCurNumber: 1

        readonly property int initHp: 29900
        readonly property double hpBonus: 0
        readonly property int initVelocity: 175*core.velocityRate
        readonly property int maxVelocity: 175*core.velocityRate
        readonly property int initDamage: 30
        readonly property double damageBonus: 1.5
        readonly property int materialDrops: 10
        readonly property double consumableDropRate: 0*(1+PlayerData.luck/100)
        readonly property double chestDropRate: 0*(1+PlayerData.luck/100)

        property int initCount: 0
        property int curNumber: 0
        property double countRation: 1
        readonly property double countIcreaseRation: 0.05


        function init(){
            initCount=0
            countRation=1
        }
    }
}
