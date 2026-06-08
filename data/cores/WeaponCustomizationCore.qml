import QtQuick 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../../logic/utils/i18n.js" as I18n
import "../../logic/DataLoader.js" as DataLoader

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
        // 元素武器
        else if (w.elementalDamageMultiplier !== undefined) {
            var baseDmg = w.baseDamage || 0
            w.damage = Math.floor(Math.max((baseDmg + PlayerData.elementalDamage * w.elementalDamageMultiplier) * (1 + PlayerData.damage/100), 1))
            w.critical = 1 + PlayerData.critChance
            w.criticalDamageRate = 1.5
            var cd = (w.baseCooldown || 1) / (1 + PlayerData.attackSpeed/100)
            w.cooldown = cd
            w.attackTime = Math.min(0.1, cd)
            w.range = (w.baseRange || 0) + PlayerData.range
        }
        // 通用战斗属性（对所有武器安全）
        w.knockback = w.baseKnockback || 0
        // 武器固有特殊属性（仅部分武器有值）
        w.inherentPenetrate = w.inherentPenetrate || 0
        w.inherentPenetrateMultiplier = w.inherentPenetrateMultiplier || 1.0
        return w
    }

    function renderWeaponTalentText(weapon){
        var data = DataLoader.renderWeaponTalentText(weapon, PlayerData)
        if (!data) return ""
        var lang = SettingsData.language

        // 通用附加属性文本
        var extraLines = ""
        if (data.knockback > 0) {
            extraLines += "<font color='#ffffc0'>" + I18n.tr("击退", lang) + " : </font><font color='white'>" + data.knockback + "</font><br>\n"
        }
        if (data.accuracy < 1.0) {
            extraLines += "<font color='#ffffc0'>" + I18n.tr("命中率", lang) + " : </font><font color='white'>" + Math.floor(data.accuracy * 100) + "%</font><br>\n"
        }
        if (data.inherentPenetrate > 0) {
            var penValue = "" + data.inherentPenetrate
            if (data.inherentPenetrateMultiplier < 1.0) {
                penValue += "(-" + Math.floor((1 - data.inherentPenetrateMultiplier) * 100) + "%" + I18n.tr("伤害", lang) + ")"
            }
            extraLines += "<font color='#ffffc0'>" + I18n.tr("贯通", lang) + " : </font><font color='white'>" + penValue + "</font><br>\n"
        }

        if (data.isMelee) {
            return "<font color='#ffffc0'>" + I18n.tr("伤害", lang) + " : </font><font color='white'>" + data.dmg + "(+100%" + I18n.tr("近战伤害", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("暴击", lang) + " : </font><font color='white'>x" + data.critMultiplier.toFixed(1) + "(" + data.critChance + "%" + I18n.tr("概率", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("冷却", lang) + " : </font><font color='white'>" + data.cd.toFixed(2) + "</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("范围", lang) + " : </font><font color='white'>" + data.range + "(" + I18n.tr("近战", lang) + ")</font><br>\n"
                + extraLines
        } else if (data.isElemental) {
            return "<font color='#ffffc0'>" + I18n.tr("伤害", lang) + " : </font><font color='white'>" + data.dmg + "(+100%" + I18n.tr("元素伤害", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("暴击", lang) + " : </font><font color='white'>x" + data.critMultiplier.toFixed(1) + "(" + data.critChance + "%" + I18n.tr("概率", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("冷却", lang) + " : </font><font color='white'>" + data.cd.toFixed(2) + "</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("范围", lang) + " : </font><font color='white'>" + data.range + "(" + I18n.tr("远程", lang) + ")</font><br>\n"
                + extraLines
        } else {
            return "<font color='#ffffc0'>" + I18n.tr("伤害", lang) + " : </font><font color='white'>" + data.dmg + "(+50%" + I18n.tr("远程伤害", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("暴击", lang) + " : </font><font color='white'>x" + data.critMultiplier.toFixed(1) + "(" + data.critChance + "%" + I18n.tr("概率", lang) + ")</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("冷却", lang) + " : </font><font color='white'>" + data.cd.toFixed(2) + "</font><br>\n"
                + "<font color='#ffffc0'>" + I18n.tr("范围", lang) + " : </font><font color='white'>" + data.range + "(" + I18n.tr("远程", lang) + ")</font><br>\n"
                + extraLines
        }
    }

    function getAllWeapons(){
        return DataLoader.getAllWeapons()
    }

    function isWeaponImplemented(objectName){
        return DataLoader.isWeaponImplemented(objectName)
    }
}
