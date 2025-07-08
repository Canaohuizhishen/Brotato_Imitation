import QtQuick 2.15
import "../tool.js" as Tool
import "../components"

Canvas {
    id: bullet
    width: 25
    height: width
    objectName: "子弹"
    z: 5
    property bool paused: false
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property color color: Qt.rgba(1, 0, 0, 1)
    property double damage: 0
    property double critical: 0
    property double criticalDamageRate: 1
    property bool isDestroy: false     //子弹已被销毁的布尔值
    property bool canPaintBullet: true //可以画出子弹的布尔值
    property bool hitNotDestroy: false //击中目标后不会销毁的布尔值
    property bool inHitCoolDown: false //子弹正处于击中冷却的布尔值
    property bool canAutomaticActive: true //到期子弹可以自动退出冷却

    onPausedChanged: {
        if(paused==true){
            hitCoolDownTimer.pause()
        }else{
            hitCoolDownTimer.resume()
        }
    }

    TimerCanPause {
        id: hitCoolDownTimer
        interval: 250
        running: bullet.inHitCoolDown && bullet.canAutomaticActive
        repeat: false
        onTriggered: {
            inHitCoolDown=false
        }
    }
}

