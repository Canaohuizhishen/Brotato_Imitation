import QtQuick 2.15
import QtQuick.Shapes 1.15
import singleton.PlayerData
import Brotato
import "../data"

Item {
    id: player
    width: 46*scaleFactor
    height: width
    focus: true
    z: 1
    objectName: "Player"
    property string roleName
    property string weaponName
    property var ground: parent
    property bool active: true
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0

    property int interval: 5
    property double v: 500*scaleFactor
    property double stepSize: v*interval/1200
    property double diagonalStepSize: stepSize*0.7

    property bool wPressed: false
    property bool sPressed: false
    property bool aPressed: false
    property bool dPressed: false

    signal faceLefted()
    signal faceRighted()

    Component.onCompleted: {
        x=ground.width/2
        y=ground.height/2
    }

    onScaleFactorChanged: {
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
    }

    onRoleNameChanged: {
        PlayerData.init()
        var roleData=core.getRole(roleName)
        roleData.setInitRoleAttributes()
        height=Qt.binding(function (){return width*roleData.aspectRatio})
    }

    function faceLeft(){
        playerIcon.source="/images/"+ roleName +"_faceLeft.png"
        faceLefted()
    }

    function faceRight(){
        playerIcon.source="/images/"+ roleName +"_faceRight.png"
        faceRighted()
    }

    function getMaterial(material){
        PlayerData.materialsNumber+=material.value
        PlayerData.curXp+=material.value
    }

    function onHit(bullet){
        PlayerData.curHp-=bullet.damage
    }

    // Timer {
    //     interval: 100; running: true; repeat: true
    //     onTriggered: {
    //         console.log(player.wPressed)
    //         console.log(player.aPressed)
    //         console.log(player.sPressed)
    //         console.log(player.dPressed)
    //         console.log(player.state)
    //         console.log("Current speed:", playerAnimation.duration)
    //         console.log("v: ", player.v)
    //         console.log("x: ", player.x)
    //         console.log("y: ", player.y)
    //         console.log("focus: ", player.focus)
    //         console.log("active: ", player.active)
    //     }
    // }

    RoleCustomizationCore{
        id: core
    }

    Image{
        id: playerIcon
        source: player.roleName == "" ? "" : "/images/"+ player.roleName +"_faceRight.png"
        anchors.fill: parent
        z: 1

        transform: Scale {
            id: squashScale
            origin.x: playerIcon.width/2
            origin.y: playerIcon.height
            xScale: 1.0; yScale: 1.0
        }
    }

    Canvas {
        id: shadow
        width: player.width/1.1
        height: player.height/4
        anchors.bottom: player.bottom
        anchors.bottomMargin: -5
        anchors.horizontalCenter: player.horizontalCenter

        onPaint: {
            var ctx = getContext("2d");
            ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
            ctx.beginPath();
            ctx.ellipse(0, 0, width, height);
            ctx.fill();
        }
    }

    Item{
        id: playerAnimation

        Component.onCompleted: {
            squashSequence_fast.start()
            squashSequence_fast.pause()
        }

        function faster(){
            squashSequence_slow.pause()
            squashSequence_fast.resume()
        }

        function slower(){
            squashSequence_slow.resume()
            squashSequence_fast.pause()

        }

        SequentialAnimation {
            id: squashSequence_slow
            loops: Animation.Infinite
            running: true
            property double duration: 1050

            ParallelAnimation {
                NumberAnimation { target: squashScale; property: "xScale"; to: 1.15; duration: squashSequence_slow.duration*3/7; easing.type: Easing.Linear }
                NumberAnimation { target: squashScale; property: "yScale"; to: 0.85; duration: squashSequence_slow.duration*3/7; easing.type: Easing.Linear }
            }
            ParallelAnimation {
                NumberAnimation { target: squashScale; property: "xScale"; to: 1; duration: squashSequence_slow.duration*4/7; easing.type: Easing.OutQuad }
                NumberAnimation { target: squashScale; property: "yScale"; to: 1; duration: squashSequence_slow.duration*4/7; easing.type: Easing.OutQuad }
            }
        }

        SequentialAnimation {
            id: squashSequence_fast
            loops: Animation.Infinite
            running: true
            property double duration: 350

            ParallelAnimation {
                NumberAnimation { target: squashScale; property: "xScale"; to: 0.95; duration: squashSequence_fast.duration*3/7; easing.type: Easing.OutQuad }
                NumberAnimation { target: squashScale; property: "yScale"; to: 1.05; duration: squashSequence_fast.duration*3/7; easing.type: Easing.OutQuad }
            }
            ParallelAnimation {
                NumberAnimation { target: squashScale; property: "xScale"; to: 1.2; duration: squashSequence_fast.duration*4/7; easing.type: Easing.Linear }
                NumberAnimation { target: squashScale; property: "yScale"; to: 0.8; duration: squashSequence_fast.duration*4/7; easing.type: Easing.Linear }
            }
        }
    }

    states: [
        State {
            name: "stationary"; when: ((!player.wPressed && !player.sPressed && !player.aPressed && !player.dPressed)||(!player.active)||(player.wPressed && player.sPressed && !player.aPressed && !player.dPressed)||(player.aPressed && player.dPressed && !player.wPressed && !player.sPressed))
            StateChangeScript {
                script: {//console.log("1")
                    if(!player.active){
                        player.wPressed==false
                        player.sPressed==false
                        player.aPressed==false
                        player.dPressed==false
                    }
                    playerAnimation.slower()
                }
            }
        },
        State {
            name: "up"; when: (player.wPressed && !player.sPressed && ((!player.aPressed && !player.dPressed)||(player.aPressed && player.dPressed)))
            PropertyChanges { target: pressW; running: true }
            StateChangeScript {
                script: {
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "down"; when: (player.sPressed && !player.wPressed && ((!player.aPressed && !player.dPressed)||(player.aPressed && player.dPressed)))
            PropertyChanges { target: pressS; running: true }
            StateChangeScript {
                script: {
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "left"; when: (player.aPressed && !player.dPressed && ((!player.wPressed && !player.sPressed)||(player.wPressed && player.sPressed)))
            PropertyChanges { target: pressA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "right"; when: (player.dPressed && !player.aPressed && ((!player.wPressed && !player.sPressed)||(player.wPressed && player.sPressed)))
            PropertyChanges { target: pressD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "upLeft"; when: (player.wPressed && player.aPressed && !player.sPressed && !player.dPressed)
            PropertyChanges { target: pressW; running: false }
            PropertyChanges { target: pressA; running: false }
            PropertyChanges { target: pressWA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft();
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "downLeft"; when: (player.sPressed && player.aPressed && !player.wPressed && !player.dPressed)
            PropertyChanges { target: pressS; running: false }
            PropertyChanges { target: pressA; running: false }
            PropertyChanges { target: pressSA; running: true }
            StateChangeScript {
                script: {
                    player.faceLeft();
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "upRight"; when: (player.wPressed && player.dPressed && !player.sPressed && !player.aPressed)
            PropertyChanges { target: pressW; running: false }
            PropertyChanges { target: pressD; running: false }
            PropertyChanges { target: pressWD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "downRight"; when: (player.sPressed && player.dPressed && !player.wPressed && !player.aPressed)
            PropertyChanges { target: pressS; running: false }
            PropertyChanges { target: pressD; running: false }
            PropertyChanges { target: pressSD; running: true }
            StateChangeScript {
                script: {
                    player.faceRight();
                    playerAnimation.faster()
                }
            }
        }
    ]

    Timer {
        id: pressW
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > -player.height*2/5)player.y -= player.stepSize;
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
            if (player.x > -player.width/7)player.x -= player.stepSize;
        }
    }

    Timer {
        id: pressD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.x < player.parent.width - player.width+player.width/7)player.x += player.stepSize;
        }
    }

    Timer {
        id: pressWA
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > -player.height*2/5)player.y -= player.diagonalStepSize;
            if (player.x > -player.width/7)player.x -= player.diagonalStepSize;
        }
    }

    Timer {
        id: pressSA
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y < player.parent.height - player.height)player.y += player.diagonalStepSize;
            if (player.x > -player.width/7)player.x -= player.diagonalStepSize;
        }
    }

    Timer {
        id: pressWD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y > -player.height*2/5)player.y -= player.diagonalStepSize;
            if (player.x < player.parent.width - player.width+player.width/7)player.x += player.diagonalStepSize;
        }
    }

    Timer {
        id: pressSD
        interval: player.interval; running: false; repeat: true
        onTriggered: {
            if (player.y < player.parent.height - player.height)player.y += player.diagonalStepSize;
            if (player.x < player.parent.width - player.width+player.width/7)player.x += player.diagonalStepSize;
        }
    }

    Keys.onPressed: function(event) {
        //console.log("Key pressed: " + event.key)  // 调试输出
        if(player.active){
            if (event.key === Qt.Key_W || event.key === Qt.Key_Up) {
                player.wPressed=true;
            }else if (event.key === Qt.Key_S || event.key === Qt.Key_Down) {
                player.sPressed=true;
            }else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
                player.aPressed=true;
                player.faceLeft()
            }else if (event.key === Qt.Key_D || event.key === Qt.Key_Right) {
                player.dPressed=true;
                player.faceRight()
            }
        }
    }

    Keys.onReleased: function(event) {
        //console.log("Key released: " + event.key)  // 调试输出
        if (event.key === Qt.Key_W || event.key === Qt.Key_Up) {
            player.wPressed=false;
            pressW.running=false;
        }else if (event.key === Qt.Key_S || event.key === Qt.Key_Down) {
            player.sPressed=false;
            pressS.running=false;
        }else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
            player.aPressed=false;
            pressA.running=false;
        }else if (event.key === Qt.Key_D || event.key === Qt.Key_Right) {
            player.dPressed=false;
            pressD.running=false;
        }
    }
}
