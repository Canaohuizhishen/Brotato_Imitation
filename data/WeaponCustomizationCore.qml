import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core
    property int weaponNumber: 2
    property double grade_one_weapon_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_weapon_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_weapon_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_weapon_spawn_probability: 0.065*(1+PlayerData.luck/125)

    function getWeaponRandomly(n){
        var weights = {
            1: core.grade_one_weapon_spawn_probability,
            2: core.grade_two_weapon_spawn_probability,
            3: core.grade_three_weapon_spawn_probability,
            4: core.grade_four_weapon_spawn_probability
        }
        return DataLoader.getWeaponRandomly(n, weights)
    }

    function getWeapon(weaponName, grade){
        var w = DataLoader.getWeapon(weaponName, grade || 1)
        if (!w) return null
        return _enrichWeapon(w)
    }

    // ---- 内部：给武器对象加上动态计算属性（模仿旧 QML Item 的 property binding） ----
    function _enrichWeapon(w){
        var g = w.grade || 1
        // 近战武器
        if (w.meleeDamageMultiplier !== undefined) {
            var baseDmg = w.baseDamage || 0
            w.damage = Math.floor(Math.max((baseDmg + PlayerData.meleeDamage * w.meleeDamageMultiplier) * (1 + PlayerData.damage/100), 1))
            w.critical = 3 + PlayerData.critChance
            w.criticalDamageRate = 2.0
            var cd = (w.baseCooldown || 1) / (1 + PlayerData.attackSpeed/100)
            w.cooldown = cd
            w.attackTime = Math.min(0.75, cd)
            w.range = (w.baseRange || 0) + PlayerData.range
        }
        // 远程武器
        else if (w.rangedDamageMultiplier !== undefined) {
            var baseDmg = w.baseDamage || 0
            w.damage = Math.floor(Math.max((baseDmg + PlayerData.rangedDamage * w.rangedDamageMultiplier) * (1 + PlayerData.damage/100), 1))
            w.critical = 1 + PlayerData.critChance
            w.criticalDamageRate = 1.5
            var cd = (w.baseCooldown || 1) / (1 + PlayerData.attackSpeed/100)
            w.cooldown = cd
            w.attackTime = Math.min(0.1, cd)
            w.range = (w.baseRange || 0) + PlayerData.range
        }
        return w
    }

    function renderWeaponTalentText(weapon){
        return DataLoader.renderWeaponTalentText(weapon, PlayerData)
    }

    function getAllWeapons(){
        return DataLoader.getAllWeapons()
    }
}
