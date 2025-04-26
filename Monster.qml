import QtQuick 2.15
import Brotato

Image {
    id: monsterImage
    source: "/images/小怪1朝左.png"
    width: 50
    height: 50
    z: 2
    objectName: "Monster"
    property double maxHp: monsterData.maxHp
    property double hp: monsterData.hp
    property double damage: monsterData.damage

    MonsterData {
        id: monsterData
        maxHp: 5
        hp: 5
        damage: 1
    }

    transform: Scale {
        id: squashScale
        origin.x: monsterImage.width/2
        origin.y: monsterImage.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: squashSequence
        loops: Animation.Infinite
        running: true

        // 阶段一：同时扁平 X 并拉长 Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.9; duration: 1000; easing.type: Easing.InOutQuad }
        }
        // 阶段二：同时恢复 X、Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 0.95; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 1.05; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    function faceLeft(){
        monsterImage.source="/images/小怪1朝左.png"
    }

    function faceRight(){
        monsterImage.source="/images/小怪1朝右.png"
    }
}

