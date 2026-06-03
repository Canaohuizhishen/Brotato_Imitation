import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    property double grade_one_option_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_option_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_option_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_option_spawn_probability: 0.065*(1+PlayerData.luck/125)

    function getOptionRandomly(n){
        var weights = {
            1: core.grade_one_option_spawn_probability,
            2: core.grade_two_option_spawn_probability,
            3: core.grade_three_option_spawn_probability,
            4: core.grade_four_option_spawn_probability
        }
        return DataLoader.getUpgradeOptionRandomly(n, weights)
    }

    function getUpgradeOption(grade, optionName){
        return DataLoader.getUpgradeOption(grade, optionName)
    }

    function applyOptionEffects(optionData){
        DataLoader.applyEffects(optionData.effects, PlayerData)
    }

    function renderTalentText(template, grade){
        return DataLoader.renderTalentText(template, grade)
    }
}
