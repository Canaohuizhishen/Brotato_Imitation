import QtQuick 2.15
import singleton.PlayerData
import "../logic/DataLoader.js" as DataLoader

Item {
    id: core

    function getRole(roleName){
        return DataLoader.getRole(roleName)
    }

    function applyRoleEffects(roleData){
        DataLoader.applyEffects(roleData.effects, PlayerData)
    }

    function getAllRoles(){
        return DataLoader.getAllRoles()
    }
}
