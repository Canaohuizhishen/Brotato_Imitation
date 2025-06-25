import QtQuick 2.15
import "../components"
import "../tool.js" as Tool

Monster{
    id: summoner
    monsterName: "summoner"
    imageWidth: 100
    imageHeight: imageWidth
    property int stopRange: 200*scaleFactor
    property int escapeRange: stopRange*2/3
    property bool isEscaping: false

    onIsDeadChanged: {
        summon(3)
    }

    Timer {
        id: checkTimer
        interval: 150
        running: summoner.active && !summoner.paused
        repeat: true
        onTriggered: {
            var distance=Tool.getDistance(Qt.point(summoner.x,summoner.y),Qt.point(summoner.target.x,summoner.target.y))
            if(distance<summoner.stopRange && !summoner.isEscaping)summoner.isMoveStoped=true
            else summoner.isMoveStoped=false
            if(distance<summoner.escapeRange){
                summoner.isEscaping=true
                summoner.moveDirectionConverse=true
            }else if(distance>summoner.stopRange){
                summoner.isEscaping=false
                summoner.moveDirectionConverse=false
            }
            if(summoner.isInEdge()){
                summoner.isEscaping=false
            }
        }
    }

    function summon(n){
        for(var i=0;i<n;i++){
            var x=(summoner.x+summoner.width/2)+(Math.random()-0.5)*summoner.width/2
            var y=(summoner.y+summoner.height/2)+(Math.random()-0.5)*summoner.width/2
            var monster=summoner.owner.spawnMonster(summoner.owner,"scavenger")
            monster.x = x-monster.width/2
            monster.y = y-monster.height/2
            monster.owner=owner
            monster.target=target
            monster.bulletsParent=bulletsParent
            if((monster.x-monster.target.x)>0)monster.faceLeft()
            else monster.faceRight()
        }
    }
}
