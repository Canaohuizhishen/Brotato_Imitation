import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    property double grade_one_prop_spawn_probability: 0.5065*(1-PlayerData.luck/1000)
    property double grade_two_prop_spawn_probability: 0.25*(1-PlayerData.luck/500)
    property double grade_three_prop_spawn_probability: 0.125*(1+PlayerData.luck/250)
    property double grade_four_prop_spawn_probability: 0.065*(1+PlayerData.luck/125)

    function getPropRandomly(number=1){
        var weights = {
            1: core.grade_one_prop_spawn_probability,
            2: core.grade_two_prop_spawn_probability,
            3: core.grade_three_prop_spawn_probability,
            4: core.grade_four_prop_spawn_probability
        }
        var result = DataLoader.getPropRandomly(number, weights)
        if(number === 1) return result.length > 0 ? result[0] : []
        return result
    }

    function getProp(propName){
        return DataLoader.getProp(propName)
    }

    function getPropGradeCounts(){
        return DataLoader.getPropGradeCounts()
    }

    function applyEffects(effects){
        DataLoader.applyEffects(effects, PlayerData)
    }
}
