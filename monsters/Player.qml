import QtQuick 2.15
import QtQuick.Shapes 1.15
import singleton.PlayerData
import Brotato
import "../components"
import "../data"
import "../tool.js" as Tool

Item {
    id: player
    width: 46*scaleFactor
    height: width*1.17
    focus: true
    z: 1
    objectName: "Player"
    property string roleName: PlayerData.roleName
    property string weaponName: PlayerData.originWeaponName
    property var ground: parent
    property ChestNotificationBar chestBar: chestBar
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool active: true
    property bool paused: false
    property bool isSlow: true
    property bool isFaceRight: true

    property int interval: 5
    property double v: 500*scaleFactor*(1+PlayerData.speed/100)*0.8
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
        if(roleName==="")return
        var roleData=core.getRole(roleName)
        roleData.setInitRoleAttributes()
        faceRight()
    }

    onPausedChanged: {
        if(paused==true){
            hpRegenerationTimer.pause()
            playerAnimation.pause()
        }else{
            hpRegenerationTimer.resume()
            playerAnimation.resume()
        }
    }

    TimerCanPause {
        id: hpRegenerationTimer
        interval: 1000; running: PlayerData.isInCombat; repeat: true
        onTriggered: {
            PlayerData.curHp+=PlayerData.hpRegenerationPerSecond()
        }
    }

    RoleCustomizationCore{
        id: core
    }

    transform: Scale {
        id: squashScale
        origin.x: playerIcon.width/2
        origin.y: playerIcon.height
        xScale: 1.0; yScale: 1.0
    }

    Image{
        id: playerIcon
        source: player.roleName == "" ? "" : "/images/"+ player.roleName +"_faceRight.png"
        anchors.fill: parent
        z: 1
    }

    Canvas {
        id: shadow
        width: player.width/1.1
        height: width/3
        anchors.bottom: player.bottom
        anchors.bottomMargin: -height/3
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
            player.isSlow=false
            squashSequence_slow.pause()
            squashSequence_fast.resume()
        }

        function slower(){
            player.isSlow=true
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
        function pause(){
            if(squashSequence_slow.running)squashSequence_slow.pause()
            if(squashSequence_fast.running)squashSequence_fast.pause()
        }
        function resume(){
            if(player.isSlow)squashSequence_slow.resume()
            else squashSequence_fast.resume()
        }
    }

    states: [
        State {
            name: "paused"; when: (player.paused)
            StateChangeScript {
                script: {
                    player.wPressed=false
                    player.sPressed=false
                    player.aPressed=false
                    player.dPressed=false
                    playerAnimation.slower()
                    playerAnimation.pause()
                }
            }
        },
        State {
            name: "stationary"; when: ((!player.wPressed && !player.sPressed && !player.aPressed && !player.dPressed)||(!player.active || player.paused)||(player.wPressed && player.sPressed && !player.aPressed && !player.dPressed)||(player.aPressed && player.dPressed && !player.wPressed && !player.sPressed))
            StateChangeScript {
                script: {
                    if(!player.active || player.paused){
                        player.wPressed=false
                        player.sPressed=false
                        player.aPressed=false
                        player.dPressed=false
                        playerAnimation.slower()
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
        if(player.active && !player.paused){
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

    function init(){
        active=true
        paused=false
        playerAnimation.slower()
        faceRight()
        wPressed=false
        sPressed=false
        aPressed=false
        dPressed=false
    }

    function faceLeft(){
        playerIcon.source="/images/"+ roleName +"_faceLeft.png"
        isFaceRight=false
        faceLefted()
    }

    function faceRight(){
        playerIcon.source="/images/"+ roleName +"_faceRight.png"
        isFaceRight=true
        faceRighted()
    }

    function getMaterial(material){
        PlayerData.materialsNumber+=material.value
        PlayerData.curWaveMaterialsNumber+=material.value
        PlayerData.curXp+=material.value
        var text=material.value===1 ? "+1" : "X"+material.value
        var size=material.value===1 ? 24*player.scaleFactor : 27*player.scaleFactor
        Tool.createText(ground,text,size,"lime",material.x,material.y)
    }

    function getFruit(fruit){
        PlayerData.curHp+=fruit.value
        Tool.createText(ground,"+"+fruit.value,24*player.scaleFactor,"lime",fruit.x,fruit.y)
    }

    function getChest(chest){
        chestBar.addChest(chest)
    }

    function onHit(bullet){
        //当闪避失败时造成伤害
        if(Math.random()>PlayerData.dodge/100){
            //护甲减伤
            var damage=Math.ceil(bullet.damage*(1-PlayerData.damageReduction()))
            PlayerData.curHp-=damage
            Tool.createText(ground,"-"+damage,29*player.scaleFactor,"red",bullet.x,bullet.y)
        }else{//闪避成功
            Tool.createText(ground,"闪避",20*player.scaleFactor,"white",bullet.x,bullet.y,600,"blue")
        }
    }
}
