import QtQuick 2.15

Monster{
    id: pursuer
    monsterName: "pursuer"
    imageWidth: 60
    imageHeight: imageWidth*1.071

    Timer {
        id: accelerateTimer
        interval: 175
        running: true
        repeat: true
        onTriggered: {
            var v=pursuer.v
            pursuer.v+=5
            if(pursuer.v>pursuer.core.maxVelocity)running=false
        }
    }
}
