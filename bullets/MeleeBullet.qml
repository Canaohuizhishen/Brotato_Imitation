import QtQuick 2.15

Bullet {
    id: bullet
    property var target
    width: 0
    height: 0
    hitNotDestroy: true
    inHitCoolDown: true
    canAutomaticActive: false

    onTargetChanged: {
        if (!target) return
        width=Qt.binding(function(){
            return target ? target.width : 0
        })
        height=Qt.binding(function(){
            return target ? target.height : 0
        })
        x=Qt.binding(function(){
            return target && target.parent ? target.parent.x + target.x : 0
        })
        y=Qt.binding(function(){
            return target && target.parent ? target.parent.y + target.y : 0
        })
        rotation=Qt.binding(function(){
            if (!target) return 0
            if(target.isFaceRight)return target.rotation
            else return 180+target.rotation
        })
    }

    Rectangle{
        id: testRectangle
        visible: false
        color:"red"
        anchors.fill: bullet
    }
}
