import QtQuick 2.15
import "../logic/utils/tool.js" as Tool

Bullet {
    id: bullet
    width: 50
    height: width*0.28
    property var originPoint: Qt.point(0,0)
    property int fireRange: 400
    property double fireRate: 2500
    property double shootAngle: 0
    rotation: -shootAngle

    Component.onCompleted: {
        shoot.start()
    }

    // 反弹：将子弹重新导向新目标
    function reboundToTarget(newTarget) {
        // 1. 停止当前飞行动画
        shoot.stop()

        // 2. 计算从当前位置到新目标中心的方向和距离
        var cx = x + width / 2
        var cy = y + height / 2
        var tx = newTarget.x + newTarget.width / 2
        var ty = newTarget.y + newTarget.height / 2
        var dx = tx - cx
        var dy = ty - cy
        var dist = Math.sqrt(dx * dx + dy * dy)
        if (dist < 1) return  // 目标太近，放弃反弹

        // 3. 更新射击角度和旋转
        shootAngle = Math.atan2(-dy, dx) * (180 / Math.PI)
        bullet.rotation = -shootAngle

        // 4. 以当前位置为新起点，飞向新目标（至少飞剩余射程的一半或到目标的距离）
        var remainingRange = Math.max(dist * 1.2, fireRange * 0.3) * scaleFactor
        var newOriginX = cx - width / 2
        var newOriginY = cy - height / 2
        originPoint = Qt.point(newOriginX, newOriginY)

        var toX = newOriginX + Math.cos(shootAngle * Math.PI/180) * remainingRange
        var toY = newOriginY - Math.sin(shootAngle * Math.PI/180) * remainingRange

        // 5. 更新动画参数
        xAnimation.to = toX
        yAnimation.to = toY
        xAnimation.duration = remainingRange / (fireRate / 1000)
        yAnimation.duration = remainingRange / (fireRate / 1000)

        // 6. 重新启动
        shoot.start()
    }

    onPausedChanged: {
        if(paused==true){
            shoot.pause()
        }else{
            shoot.resume()
        }
    }

    onScaleFactorChanged: {
        shoot.stop()
        width=width*scaleFactor/lastScaleFactor
        height=height*scaleFactor/lastScaleFactor
        originPoint=Qt.point(originPoint.x*scaleFactor/lastScaleFactor,originPoint.y*scaleFactor/lastScaleFactor)
        x=x*scaleFactor/lastScaleFactor
        y=y*scaleFactor/lastScaleFactor
        lastScaleFactor=scaleFactor
        shoot.start()
    }

    ParallelAnimation {
        id: shoot
        running: false
        NumberAnimation { id: xAnimation; target: bullet; property: "x"; to: bullet.originPoint.x+Math.cos(bullet.shootAngle* (Math.PI/180))*bullet.fireRange*bullet.scaleFactor; loops: 1; duration: bullet.fireRange/(bullet.fireRate/1000); easing.type: Easing.Linear }
        NumberAnimation { id: yAnimation; target: bullet; property: "y"; to: bullet.originPoint.y-Math.sin(bullet.shootAngle* (Math.PI/180))*bullet.fireRange*bullet.scaleFactor;  loops: 1; duration: bullet.fireRange/(bullet.fireRate/1000); easing.type: Easing.Linear }
        onStopped: {
            //console.log(bullet.x,xAnimation.to)
            if(Tool.approximatelyEqual(bullet.x,xAnimation.to,bullet.fireRange*bullet.scaleFactor/10))bullet.destroy()
        }
        function pause(){
            if(running)paused=true
        }
        function resume(){
            paused=false
        }
    }
}
