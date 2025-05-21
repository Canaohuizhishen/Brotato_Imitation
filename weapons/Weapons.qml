import QtQuick 2.15
import "../monsters"
import "../data"

Item{
    id: weapons
    property Player owner
    property Monsters target
    property double scaleFactor: 1.0
    anchors.centerIn: owner
    anchors.horizontalCenterOffset: 10
    width: 110*scaleFactor
    height: 110*scaleFactor
    z: 3
    property bool isFaceRight: true

    Rectangle{
        //visible: false
        anchors.fill: weapons
        color: "black"
        opacity: 0.5
    }

    Rectangle{
        visible: false
        x: weapons.getPosition(3,3).x
        y: weapons.getPosition(3,3).y
        width: 5
        height: 5
        color: "red"
        z: 100
    }

    property int weaponsNum: 0

    Component.onCompleted: {
        for(var i=0;i<6;i++)addWeapon("冲锋枪")
        //addWeapon("冲锋枪")
    }

    function faceLeft(){
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName!=""&&isFaceRight){
                if(child.targetPoint==null){
                    child.faceLeft()
                    child.rotationReset()
                }
            }
        }
        isFaceRight=false
        anchors.horizontalCenterOffset=-10
    }

    function faceRight(){
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName!=""&&!isFaceRight){
                if(child.targetPoint==null){
                    child.faceRight()
                    child.rotationReset()
                }
            }
        }
        isFaceRight=true
        anchors.horizontalCenterOffset=10
    }

    function addWeapon(weaponName){
        var weapon = weaponCore.getWeapon(weaponName)
        var component = Qt.createComponent(weapon.source);
        if (component.status === Component.Ready) {
            weaponsNum++
            var object = component.createObject(weapons,{"scaleFactor": Qt.binding(function() { return weapons.scaleFactor; })});
            relocation()
        } else {
            console.log("Error loading component:", component.errorString());
        }
    }

    function getPosition(n1,n2){
        switch(n1){
        case 1: {
            return Qt.point(43, 76)
        }case 2: {
             switch(n2){
             case 1:return Qt.point(72, 67)
             case 2:return Qt.point(12, 67)
             default: return Qt.point(0,0)
             }
         }case 3: {
              switch(n2){
              case 1:return getPosition(2,1)
              case 2:return getPosition(2,2)
              case 3:return Qt.point(42, 25)
              default: return Qt.point(0,0)
              }
          }case 4: {
               switch(n2){
               case 1:return Qt.point(63, 77)
               case 2:return Qt.point(20, 77)
               case 3:return Qt.point(63, 30)
               case 4:return Qt.point(20, 30)
               default: return Qt.point(0,0)
               }
           }case 5: {
                switch(n2){
                case 1:return Qt.point(63, 77)
                case 2:return Qt.point(20, 77)
                case 3:return Qt.point(78, 37)
                case 4:return Qt.point(5, 37)
                case 5:return Qt.point(42, 10)
                default: return Qt.point(0,0)
                }
            }case 6: {
                 switch(n2){
                 case 1:return Qt.point(63, 80)
                 case 2:return Qt.point(20, 80)
                 case 3:return Qt.point(78, 50)
                 case 4:return Qt.point(5, 50)
                 case 5:return Qt.point(63, 20)
                 case 6:return Qt.point(20, 20)
                 default: return Qt.point(0,0)
                 }
             }default: return Qt.point(0,0)
        }
    }

    function relocation(){
        var n=1
        for(var i=0;i<weapons.children.length;i++){
            var child=weapons.children[i]
            if(child.objectName!=""){
                var weapon = weaponCore.getWeapon(child.objectName)
                child.x=(weapons.getPosition(weaponsNum,n).x-weapon.iconWidthOffset)*scaleFactor
                child.y=(weapons.getPosition(weaponsNum,n).y-weapon.iconHeightOffset)*scaleFactor
                n++
            }
        }
    }

    onScaleFactorChanged: {
        relocation()
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    Timer {
        id: setGoalTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            for(var i=0;i<weapons.children.length;i++){
                var child=weapons.children[i]
                if(child.objectName!=""){
                    var weapon=weaponCore.getWeapon(child.objectName)
                    var monster=weapons.target.getClosestMonster(child.x+weapons.x,child.y+weapons.y,weapon.range*weapons.scaleFactor)
                    if(monster==null){
                        child.targetPoint=null
                        isFaceRight ? child.faceRight() : child.faceLeft()
                    }else child.targetPoint=Qt.point(monster.x+monster.width/2-weapons.x,monster.y+monster.height/2-weapons.y)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            for(var i=0;i<weapons.children.length;i++){
                var child=weapons.children[i]
                if(child.objectName!=""){
                    child.targetPoint=Qt.point(mouseX,mouseY)
                }
            }
        }
    }
}

