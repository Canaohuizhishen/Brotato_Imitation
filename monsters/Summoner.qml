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

    function checkSummonerBehavior() {
        if (!active || paused) return
        var distance = Tool.getDistance(Qt.point(x, y), Qt.point(target.x, target.y))
        if (distance < stopRange && !isEscaping) isMoveStoped = true
        else isMoveStoped = false
        if (distance < escapeRange) {
            isEscaping = true
            moveDirectionConverse = true
        } else if (distance > stopRange) {
            isEscaping = false
            moveDirectionConverse = false
        }
        if (isInEdge()) {
            isEscaping = false
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
