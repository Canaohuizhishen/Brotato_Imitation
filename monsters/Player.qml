import QtQuick 2.15
import QtQuick.Shapes 1.15
import singleton.PlayerData
import singleton.SettingsData
import Brotato
import "../components"
import "../data"
import "../data/i18n.js" as I18n
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

    property double v: 500*scaleFactor*(1+PlayerData.speed/100)*0.8

    property bool wPressed: false
    property bool sPressed: false
    property bool aPressed: false
    property bool dPressed: false
    property var keysPressed: ({ "W": false, "A": false, "S": false, "D": false })

    signal faceLefted()
    signal faceRighted()
    signal screenShakeRequested()  // 屏幕振动请求——由 GameArea 连接
    // 仅限鼠标模式：鼠标移动目标点（全局坐标，由 GameArea 设置）
    property var mouseTarget: null

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
        core.applyRoleEffects(roleData)
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

    // 角色突显轮廓
    Rectangle {
        id: charHighlight
        anchors.centerIn: playerIcon
        width: playerIcon.width + 16 * player.scaleFactor
        height: playerIcon.height + 16 * player.scaleFactor
        radius: width / 4
        color: "transparent"
        border.color: "cyan"
        border.width: 3 * player.scaleFactor
        visible: SettingsData.highlightCharacter
        z: 0

        NumberAnimation on opacity {
            from: 0.3
            to: 0.9
            duration: 600
            running: SettingsData.highlightCharacter
            loops: Animation.Infinite
        }
    }

    Image{
        id: playerIcon
        source: player.roleName == "" ? "" : "/images/"+ player.roleName +"_faceRight.png"
        anchors.fill: parent
        z: 1
    }

    // 角色头顶血条
    Item {
        id: characterHpBar
        visible: SettingsData.showCharacterHealthBar
        opacity: 0.7
        anchors.bottom: playerIcon.top
        anchors.bottomMargin: 2 * player.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        width: 40 * player.scaleFactor
        height: 8 * player.scaleFactor
        z: 101

        Rectangle {
            anchors.fill: parent
            color: "#454545"
            border.color: "black"
            border.width: 1
            radius: 2
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 1.5
            width: (parent.width - 3) * Math.max(0, PlayerData.curHp / PlayerData.maxHp)
            color: Qt.rgba(0.7, 0, 0, 1)
            radius: 1
        }
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
            StateChangeScript {
                script: {
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "down"; when: (player.sPressed && !player.wPressed && ((!player.aPressed && !player.dPressed)||(player.aPressed && player.dPressed)))
            StateChangeScript {
                script: {
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "left"; when: (player.aPressed && !player.dPressed && ((!player.wPressed && !player.sPressed)||(player.wPressed && player.sPressed)))
            StateChangeScript {
                script: {
                    player.faceLeft()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "right"; when: (player.dPressed && !player.aPressed && ((!player.wPressed && !player.sPressed)||(player.wPressed && player.sPressed)))
            StateChangeScript {
                script: {
                    player.faceRight()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "upLeft"; when: (player.wPressed && player.aPressed && !player.sPressed && !player.dPressed)
            StateChangeScript {
                script: {
                    player.faceLeft();
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "downLeft"; when: (player.sPressed && player.aPressed && !player.wPressed && !player.dPressed)
            StateChangeScript {
                script: {
                    player.faceLeft();
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "upRight"; when: (player.wPressed && player.dPressed && !player.sPressed && !player.aPressed)
            StateChangeScript {
                script: {
                    player.faceRight()
                    playerAnimation.faster()
                }
            }
        },
        State {
            name: "downRight"; when: (player.sPressed && player.dPressed && !player.wPressed && !player.aPressed)
            StateChangeScript {
                script: {
                    player.faceRight();
                    playerAnimation.faster()
                }
            }
        }
    ]

    function updateMovement(deltaTime) {
        if (!active || paused || !gameArea.isInCombat) return

        var step = v * deltaTime
        var dx = 0, dy = 0

        // 仅限鼠标模式
        if (SettingsData.mouseOnly && mouseTarget !== null) {
            var targetDx = mouseTarget.x - x
            var targetDy = mouseTarget.y - y
            var dist = Math.sqrt(targetDx * targetDx + targetDy * targetDy)
            if (dist < 10) {
                // 到达目标附近，停止移动
                mouseTarget = null
            } else {
                dx = targetDx / dist
                dy = targetDy / dist
            }
        } else {
            // 键盘移动
            if (keysPressed.W) dy -= 1
            if (keysPressed.S) dy += 1
            if (keysPressed.A) dx -= 1
            if (keysPressed.D) dx += 1
            // 对角线归一化
            if (dx !== 0 && dy !== 0) {
                dx *= 0.707
                dy *= 0.707
            }
        }

        // 边界约束 — 越界则拉回
        var newX = x + dx * step
        var newY = y + dy * step
        if (newY < -height * 2 / 5) newY = -height * 2 / 5
        if (newY > parent.height - height) newY = parent.height - height
        if (newX < -width / 7) newX = -width / 7
        if (newX > parent.width - width + width / 7) newX = parent.width - width + width / 7

        x = newX
        y = newY

        // 更新朝向
        if (dx > 0) faceRight()
        else if (dx < 0) faceLeft()
    }

    Keys.onPressed: function(event) {
        //console.log("Key pressed: " + event.key)  // 调试输出
        if(player.active && !player.paused){
            if (event.key === Qt.Key_W || event.key === Qt.Key_Up) {
                player.wPressed=true;
                keysPressed.W = true;
            }else if (event.key === Qt.Key_S || event.key === Qt.Key_Down) {
                player.sPressed=true;
                keysPressed.S = true;
            }else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
                player.aPressed=true;
                keysPressed.A = true;
                player.faceLeft()
            }else if (event.key === Qt.Key_D || event.key === Qt.Key_Right) {
                player.dPressed=true;
                keysPressed.D = true;
                player.faceRight()
            }
        }
    }

    Keys.onReleased: function(event) {
        //console.log("Key released: " + event.key)  // 调试输出
        if (event.key === Qt.Key_W || event.key === Qt.Key_Up) {
            player.wPressed=false;
            keysPressed.W = false;
        }else if (event.key === Qt.Key_S || event.key === Qt.Key_Down) {
            player.sPressed=false;
            keysPressed.S = false;
        }else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
            player.aPressed=false;
            keysPressed.A = false;
        }else if (event.key === Qt.Key_D || event.key === Qt.Key_Right) {
            player.dPressed=false;
            keysPressed.D = false;
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
            if(SettingsData.showDamageNumbers) Tool.createText(ground,"-"+damage,29*player.scaleFactor,"red",bullet.x,bullet.y)
            // 屏幕振动
            if(SettingsData.screenShake) screenShakeRequested()
        }else{//闪避成功
            if(SettingsData.showDamageNumbers) Tool.createText(ground,I18n.tr("闪避",SettingsData.language),20*player.scaleFactor,"white",bullet.x,bullet.y,600,"blue")
        }
    }
}
