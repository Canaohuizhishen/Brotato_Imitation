import QtQuick 2.15

RoundBullet {
    id: bullet
    width: 25
    height: width
    objectName: "子弹"
    z: 5
    property int existTime: 500
    canPaintBullet: false
    hitNotDestroy: true
    inHitCoolDown: true

    onPausedChanged: {
        if(paused==true){
            switchTimer.pause()
            destroyTimer.pause()
        }else{
            switchTimer.resume()
            destroyTimer.resume()
        }
    }

    Component.onCompleted: {
        switchTimer.start()
    }

    Canvas {
        id: shadow
        width: bullet.width*1.5
        height: width*0.55
        anchors.top: bullet.bottom
        anchors.topMargin: shadow.height/2
        anchors.horizontalCenter: bullet.horizontalCenter

        onPaint: {
            var ctx = getContext("2d");
            ctx.translate(0.5, 0.5);
            var strokeW=height/4

            //外层
            ctx.fillStyle = "rgba(255,0,0,1)";
            ctx.beginPath();
            ctx.ellipse(0, 0,
                        width,
                        height,
                        0, 0, 2*Math.PI);
            ctx.fill();

            //挖出内部
            ctx.globalCompositeOperation = "destination-out";//从现有内容中挖除重叠部分
            ctx.beginPath();
            ctx.ellipse(strokeW/2, strokeW/2,
                        (width - strokeW),
                        (height - strokeW),
                        0, 0, 2*Math.PI);
            ctx.fill();

            //填充内部
            ctx.globalCompositeOperation = "source-over";
            ctx.fillStyle = "rgba(255,0,0,0.35)";
            ctx.beginPath();
            ctx.ellipse(0,0,
                        width, height,
                        0, 0, 2*Math.PI);
            ctx.fill();

            ctx.translate(-0.5, -0.5);
        }
    }

    TimerCanPause {
        id: switchTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            shadow.visible=false
            bullet.canPaintBullet=true
            bullet.requestPaint()
            bullet.inHitCoolDown=false
            destroyTimer.start()
        }
    }

    TimerCanPause {
        id: destroyTimer
        interval: existTime
        running: false
        repeat: false
        onTriggered: {
            bullet.destroy()
        }
    }
}
