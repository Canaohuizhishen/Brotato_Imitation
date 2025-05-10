import QtQuick 2.15
import Brotato

Image {
    id: player
    source: "/images/全能者朝左.png"
    property var ground: parent
    property bool active: true
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property int interval: 5/scaleFactor
    property double v: 0.4*scaleFactor*scaleFactor
    property double stepSize: v*interval
    property double diagonalStepSize: stepSize*0.7
    x: ground.width/2
    y: ground.height/2
    width: 50*scaleFactor
    height: 50*scaleFactor
    focus: true
    z: 1

    property double maxHp: playerData.maxHp
    property double hp: playerData.hp
    property double damage: playerData.damage

    property bool wPressed: false
    property bool sPressed: false
    property bool aPressed: false
    property bool dPressed: false

    PlayerData {
        id: playerData
        maxHp: 5
        hp: 5
        damage: 5
    }

    onScaleFactorChanged: {
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
    }

    transform: Scale {
        id: squashScale
        origin.x: player.width/2
        origin.y: player.height
        xScale: 1.0; yScale: 1.0
    }

    SequentialAnimation {
        id: squashSequence
        loops: Animation.Infinite
        running: true
        property double duration: 300

        // 阶段一：同时扁平 X 并拉长 Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 1.1; duration: squashSequence.duration; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 0.9; duration: squashSequence.duration; easing.type: Easing.InOutQuad }
        }
        // 阶段二：同时恢复 X、Y
        ParallelAnimation {
            NumberAnimation { target: squashScale; property: "xScale"; to: 0.95; duration: squashSequence.duration; easing.type: Easing.InOutQuad }
            NumberAnimation { target: squashScale; property: "yScale"; to: 1.05; duration: squashSequence.duration; easing.type: Easing.InOutQuad }
        }

        function setSpeed(newDuration) {
            if (duration === newDuration) return
            pause()
            duration = newDuration
            resume()
        }

        function faster(){
            setSpeed(180)
        }

        function slower(){
            setSpeed(500)
        }
    }

    function faceLeft(){
        player.source="/images/全能者朝左.png"
    }

    function faceRight(){
        player.source="/images/全能者朝右.png"
    }

    // Timer {
    //     interval: 100; running: true; repeat: true
    //     onTriggered: {
    //         console.log(player.wPressed)
    //         console.log(player.aPressed)
    //         console.log(player.sPressed)
    //         console.log(player.dPressed)
    //         console.log(player.state)
    //         console.log("Current speed:", squashSequence.duration)
    //     }
    // }

    states: [
        State {
            name: "stationary"; when: ((!player.wPressed && !player.sPressed && !player.aPressed && !player.dPressed)||!player.active)
            StateChangeScript {
                script: {//console.log("1")
                    if(!player.active){
                        player.wPressed==false
                        player.sPressed==false
                        player.aPressed==false
                        player.dPressed==false
                    }
                    squashSequence.slower()
                }
            }
        },
        State {
            name: "up"; when: (player.wPressed==true && player.sPressed!=true && ((player.aPressed!=true && player.dPressed!=true)||(player.aPressed==true && player.dPressed==true)))
            PropertyChanges { target: pressW; running: true }
            StateChangeScript {
                script: {
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "down"; when: (player.sPressed==true && player.wPressed!=true && ((player.aPressed!=true && player.dPressed!=true)||(player.aPressed==true && player.dPressed==true)))
            PropertyChanges { target: pressS; running: true }
            StateChangeScript {
                script: {
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "left"; when: (player.aPressed==true && player.dPressed!=true && ((player.wPressed!=true && player.sPressed!=true)||(player.wPressed==true && player.sPressed==true)))
            PropertyChanges { target: pressA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft()
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "right"; when: (player.dPressed==true && player.aPressed!=true && ((player.wPressed!=true && player.sPressed!=true)||(player.wPressed==true && player.sPressed==true)))
            PropertyChanges { target: pressD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight()
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "upLeft"; when: (player.wPressed==true && player.aPressed==true && player.sPressed!=true && player.dPressed!=true)
            PropertyChanges { target: pressW; running: false }
            PropertyChanges { target: pressA; running: false }
            PropertyChanges { target: pressWA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft();
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "downLeft"; when: (player.sPressed==true && player.aPressed==true && player.wPressed!=true && player.dPressed!=true)
            PropertyChanges { target: pressS; running: false }
            PropertyChanges { target: pressA; running: false }
            PropertyChanges { target: pressSA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft();
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "upRight"; when: (player.wPressed==true && player.dPressed==true && player.sPressed!=true && player.aPressed!=true)
            PropertyChanges { target: pressW; running: false }
            PropertyChanges { target: pressD; running: false }
            PropertyChanges { target: pressWD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight()
                    squashSequence.faster()
                }
            }
        },
        State {
            name: "downRight"; when: (player.sPressed==true && player.dPressed==true && player.wPressed!=true && player.aPressed!=true)
            PropertyChanges { target: pressS; running: false }
            PropertyChanges { target: pressD; running: false }
            PropertyChanges { target: pressSD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight();
                    squashSequence.faster()
                }
            }
        }
    ]

    Timer {
        id: pressW
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > 0)player.y -= player.stepSize;
        }
    }

    Timer {
        id: pressS
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y < player.parent.height - player.height)player.y += player.stepSize;
        }
    }

    Timer {
        id: pressA
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.x > 0)player.x -= player.stepSize;
        }
    }

    Timer {
        id: pressD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.x < player.parent.width - player.width)player.x += player.stepSize;
        }
    }

    Timer {
        id: pressWA
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > 0)player.y -= player.diagonalStepSize;
            if (player.x > 0)player.x -= player.diagonalStepSize;
        }
    }

    Timer {
        id: pressSA
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y < player.parent.height - player.height)player.y += player.diagonalStepSize;
            if (player.x > 0)player.x -= player.diagonalStepSize;
        }
    }

    Timer {
        id: pressWD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > 0)player.y -= player.diagonalStepSize;
            if (player.x < player.parent.width - player.width)player.x += player.diagonalStepSize;
        }
    }

    Timer {
        id: pressSD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y < player.parent.height - player.height)player.y += player.diagonalStepSize;
            if (player.x < player.parent.width - player.width)player.x += player.diagonalStepSize;
        }
    }

    Keys.onPressed: function(event) {
        //console.log("Key pressed: " + event.key)  // 调试输出
        if(player.active){
            if (event.key === Qt.Key_W) {
                player.wPressed=true;
            }else if (event.key === Qt.Key_S) {
                player.sPressed=true;
            }else if (event.key === Qt.Key_A) {
                player.aPressed=true;
                player.faceLeft()
            }else if (event.key === Qt.Key_D) {
                player.dPressed=true;
                player.faceRight()
            }
        }
    }

    Keys.onReleased: function(event) {
        //console.log("Key released: " + event.key)  // 调试输出
        if (event.key === Qt.Key_W) {
            player.wPressed=false;
            pressW.running=false;
        }else if (event.key === Qt.Key_S) {
            player.sPressed=false;
            pressS.running=false;
        }else
        if (event.key === Qt.Key_A) {
            player.aPressed=false;
            pressA.running=false;
        }else if (event.key === Qt.Key_D) {
            player.dPressed=false;
            pressD.running=false;
        }
    }
}
