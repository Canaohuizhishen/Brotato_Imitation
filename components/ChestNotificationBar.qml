pragma ComponentBehavior: Bound
import QtQuick 2.15
import singleton.PlayerData

Item {
    id: chestBar
    property int number: repeater.model.count
    property var chests: repeater.model
    property double scaleFactor: 1.0
    width: parent.width
    height: 40*scaleFactor
    anchors.top: parent.top
    anchors.topMargin: 75*scaleFactor
    anchors.right: parent.right
    anchors.rightMargin: 20*scaleFactor

    Repeater{
        id: repeater
        model: ListModel{}
        delegate: Image{
            required property int index
            required property int grade
            source: grade==1 ? "/images/chest_white" : (grade==2 ? "/images/chest_green" : "/images/chest_red")
            width: chestBar.height
            height: width*0.9505
            anchors.verticalCenter: chestBar.verticalCenter
            anchors.right: chestBar.right
            anchors.rightMargin: (5*chestBar.scaleFactor+width)*index
            opacity: PlayerData.isInCombat ? 0.5 : 1
        }
    }

    function addChest(chest){
        repeater.model.append({"grade": chest.grade,"propName": chest.propName})
    }

    function reduceChest(){
        if(number==0)return
        var propName=repeater.model.get(0).propName
        repeater.model.remove(0)
        return propName
    }
}
