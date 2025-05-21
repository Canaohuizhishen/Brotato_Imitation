pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    property int curLevel: 0
    property int maxXp: 100+Math.pow(curLevel+1,2)*100
    property int curXp: 0
    property int maxHp: 10
    property int curHp: 10
    property int hpRegeneration: 0
    property int lifeSteal: 0
    property int damage: 0
    property int meleeDamage: 0
    property int rangedDamage: 0
    property int elementalDamage: 0
    property int attackSpeed: 0
    property int critChance: 0
    property int engineering: 0
    property int range: 0
    property int armor: 0
    property int dodge: 0
    property int speed: 0
    property int luck: 0
    property int harvesting: 0

    function init(){
        curLevel = 0
        curXp = 0
        maxHp = 10
        curHp = maxHp
        hpRegeneration = 0
        lifeSteal = 0
        damage = 0
        meleeDamage = 0
        rangedDamage = 0
        elementalDamage = 0
        attackSpeed = 0
        critChance = 0
        engineering = 0
        range = 0
        armor = 0
        dodge = 0
        speed = 0
        luck = 0
        harvesting = 0
    }
}
