import QtQuick 2.15
import QtMultimedia
import singleton.PlayerData
import "../tool.js" as Tool

Item {
    id: material
    objectName: "材料"
    property int value: 1
    property var materialImageAspectRatioArray: [0.643, 0.905, 0.681, 0.886, 0.93, 0.415, 0.623, 0.906]
    property bool isGeted: false
    property bool isDestroy: false
    property double scaleFactor: 1
    width: 30*scaleFactor
    height: width
    z: y+height

    Component.onCompleted: {
        if(PlayerData.remainingMaterialsNumber>0){
            PlayerData.remainingMaterialsNumber--
            value++
        }
        var array=materialImageAspectRatioArray
        materialImage.rotation=Math.random()*360
        var index=Math.floor(Math.random()*array.length)
        materialImage.source="qrc:/images/material"+(index+1)+".png"
        var k=1/array[index]
        materialImage.width=Qt.binding(function(){return material.width*k/Math.sqrt(k*k+1)})
        materialImage.height=Qt.binding(function(){return material.width/k})
    }

    function toBag(point){
        toBagAnimation.targetPoint=point
        toBagAnimation.start()
    }

    function beGetedTo(target){
        material.isGeted=true
        beGetedAnimation.target=target
        beGetedAnimation.start()
    }

    SoundEffect {
        id: getSound
        source: "qrc:/audio/get_material.wav"
        volume: 0.6
    }

    Image{
        id: materialImage
        anchors.centerIn: material
        z: 1
    }

    Canvas {
        id: flame
        width: material.width*1.5
        height: width
        anchors.centerIn: material
        z: 0
        onPaint: {
            var ctx = getContext("2d")
            var gradient = ctx.createRadialGradient(
                        width / 2, height / 2, 0,
                        width / 2, height / 2, width / 2
                        )
            gradient.addColorStop(0,Qt.rgba(0,0.8,0,1))
            gradient.addColorStop(1, Qt.rgba(0,1,0,0))
            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2)
            ctx.fill()
        }
    }

    ParallelAnimation{
        id: toBagAnimation
        loops: 1
        running: false
        property var targetPoint: Qt.point(0,0)

        PropertyAnimation {
            id: xtoBagAnimation
            target: material
            property: "x"
            from: material.x
            to: toBagAnimation.targetPoint.x-material.width/2
            duration: Tool.getDistance(Qt.point(material.x+material.width/2,material.y+material.height/2),toBagAnimation.targetPoint)
            easing.type: Easing.OutQuart
        }

        PropertyAnimation {
            id: ytoBagAnimation
            target: xtoBagAnimation.target
            property: "y"
            from: material.y
            to: toBagAnimation.targetPoint.y-material.height/2
            duration: xtoBagAnimation.duration
            easing.type: xtoBagAnimation.easing.type
        }

        onStopped: {
            //getSound.play()
            PlayerData.remainingMaterialsNumber++
            material.visible=false
            material.destroy(700)
        }
    }

    ParallelAnimation{
        id: beGetedAnimation
        loops: 1
        running: false
        property var target: Qt.point(0,0)

        PropertyAnimation {
            id: xbeGetedAnimation
            target: material
            property: "x"
            from: material.x
            to: beGetedAnimation.target.x+beGetedAnimation.target.width/2-material.width/2
            duration: Tool.getDistance(Qt.point(material.x,material.y),Qt.point(beGetedAnimation.target.x,beGetedAnimation.target.y))*1
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            id: ybeGetedAnimation
            target: xbeGetedAnimation.target
            property: "y"
            from: material.y
            to: beGetedAnimation.target.y-material.height/2
            duration: xbeGetedAnimation.duration
            easing.type: xbeGetedAnimation.easing.type
        }

        onStopped: {
            getSound.play()
            // 残渣掉落动画
            for (var i = 0; i < 6; i++) {
                var radius = 13*material.scaleFactor;
                var angle=Math.random() * 2 * 3.14159
                var dx = Math.cos(angle)*(Math.random() * material.width*6-material.width*3)
                var dy = Math.sin(angle)*(Math.random() * material.width*6-material.width*3)+material.width*1.5
                material.makeResidue(target.x+target.width/2,target.y,dx,dy, radius,gameArea);
            }
            target.getMaterial(material)
            material.visible=false
            material.destroy(700)
        }
    }

    function makeResidue(x,y,dx,dy, width, parent){
        var blood = Qt.createQmlObject(
                    `import QtQuick 2.15;
                    Rectangle {
                        id: bloodSplatter
                        width: ${width}  //直径
                        height: width * 1.1
                        x: ${x}-width/2 //初始位置
                        y: ${y}-height/2 //初始位置
                        color: 'black'
                        visible: true
                        radius: width / 2
                        rotation: -30
                        z: 3

                        Rectangle {
                            width: parent.width / 1.6
                            height: width * 1.2
                            anchors.centerIn: parent
                            color: Qt.rgba(0,1,0,1)
                            visible: parent.visible
                            radius: width / 2
                        }


                        SequentialAnimation {
                            running: bloodSplatter.visible

                            // 移动并缩小
                            ParallelAnimation{
                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "x"
                                    to: bloodSplatter.x + ${dx}  // 移动的距离
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "y"
                                    to: bloodSplatter.y + ${dy}  // 移动的距离
                                    duration: 350
                                    easing.type: Easing.Linear
                                }

                                PropertyAnimation {
                                    target: bloodSplatter
                                    property: "scale"
                                    from: 1
                                    to: 0 //缩放倍数
                                    duration: 550
                                    easing.type: Easing.Linear
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
