import QtQuick 2.15
import Brotato

Image {
    id: monsterImage
    source: "/images/小怪1朝右.png"
    objectName: "Monster"
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    width: 52*scaleFactor
    height: 52*scaleFactor
    z: 2
    property bool active: true
    property bool isDead: false
    property bool isFaceRight: true
    property var data: monsterData

    Item {
        id: monsterData
        property int maxHp: 10
        property int hp: maxHp
        property int damage: 1
        onHpChanged: {
            if(hp<=0)monsterImage.kill()
        }
    }

    onScaleFactorChanged: {
        monsterImage.x = monsterImage.x*scaleFactor/lastScaleFactor;
        monsterImage.y = monsterImage.y*scaleFactor/lastScaleFactor;
        lastScaleFactor=scaleFactor
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

    ParallelAnimation{
        id: deadAnimation
        loops: 1
        running: false
        property double multiplier: 1.5
        property double angle: 0

        PropertyAnimation {
            target: monsterImage
            property: "x"
            to:  monsterImage.x+Math.cos(deadAnimation.angle* (Math.PI/180))*monsterImage.width*2.5
            duration: 350*deadAnimation.multiplier
            easing.type: Easing.OutQuart
        }

        PropertyAnimation {
            target: monsterImage
            property: "y"
            to: monsterImage.y+Math.sin(deadAnimation.angle* (Math.PI/180))*monsterImage.width*2.5
            duration: 350  // 动画持续时间
            easing.type: Easing.Linear  // 缓动效果
        }

        PropertyAnimation {
            target: monsterImage
            property: "rotation"
            from: 0
            to: -360
            duration: 400*deadAnimation.multiplier
            easing.type: Easing.InQuad
        }

        PropertyAnimation {
            target: monsterImage
            property: "scale"
            from: 1
            to: 0
            duration: 400 *deadAnimation.multiplier
            easing.type: Easing.Linear
        }
        onStopped:{
            monsterImage.destroy()
        }
    }

    Timer {
        id: stunnedTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            monsterImage.active=true
        }
        function start(){
            running=true
        }
    }

    // Timer {
    //     id: killTimer
    //     interval: 500
    //     running: false
    //     repeat: false
    //     onTriggered: {
    //         monsterImage.destroy()
    //     }
    //     function start(){
    //         running=true
    //     }
    // }

    function faceLeft(){
        monsterImage.source="/images/小怪1朝左.png"
        isFaceRight=false
    }

    function faceRight(){
        monsterImage.source="/images/小怪1朝右.png"
        isFaceRight=true
    }

    function kill(){
        monsterImage.isDead=true
        deadAnimation.start()
        //killTimer.start()
    }

    function stunned(time){
        active=false
        stunnedTimer.interval=time
        stunnedTimer.start()
    }

    function onHit(bullet) {
        //设置攻击角度
        deadAnimation.angle=monsterImage.isFaceRight ? bullet.rotation+180 : bullet.rotation

        //僵直
        stunned(100)

        // 白色遮罩动画
        makeMask(monsterImage)

        // 飙血动画
        for (var i = 0; i < 5; i++) {
            var radius = (Math.random() * 10 + 4)*scaleFactor; // 随机半径
            var dx = Math.random() * monsterImage.width*2;
            var dy = Math.random() * monsterImage.width/2-monsterImage.width/4;
            makeBlood(monsterImage.x+monsterImage.width/2,monsterImage.y+monsterImage.height/2,dx,dy, radius,gameArea);
        }

        //掉血
        data.hp-=bullet.damage
    }

    function makeMask(parent){
        var mask = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Image {
                        id: whiteOverlay
                        anchors.fill: parent
                        source: parent.isFaceRight ? "/images/小怪1遮罩朝右.png" : "/images/小怪1遮罩朝左.png"
                        z: 100
                        Component.onCompleted: {
                        }

                        OpacityAnimator {
                            id: whiteOverlayAnimator
                            target: whiteOverlay
                            from: 1
                            to: 0
                            duration: 200
                            running: true
                            onStopped: {
                                whiteOverlay.destroy()
                            }
                        }
                    }`,
                    parent,
                    "dynamicImage"
                    );
    }

    function makeBlood(x,y,dx,dy, width, parent){
        var blood = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Rectangle {
                        id: bloodSplatter
                        width: ${width}
                        height: width * 1.1
                        x: ${x}
                        y: ${y}
                        color: 'black'
                        visible: true
                        radius: width / 2
                        rotation: -30
                        z: 3

                        Rectangle {
                            width: parent.width / 1.6
                            height: width * 1.2
                            anchors.centerIn: parent
                            color: '#AB0000'
                            visible: parent.visible
                            radius: width / 2
                        }


                        SequentialAnimation {
                            running: bloodSplatter.visible

                            // 向右移动并缩小
                            ParallelAnimation{
                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "x"
                                    to: bloodSplatter.x + ${dx}  // 向右移动的距离
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "y"
                                    to: bloodSplatter.y + ${dy}
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "scale"
                                    from: 1
                                    to: 0.7 //缩放倍数
                                    duration: 350
                                    easing.type: Easing.OutQuad
                                }
                            }

                            onStopped: {
                                bloodSplatter.destroy()
                            }
                        }
                    }`,
                    parent,
                    "dynamicImage"
                    );
    }
}

