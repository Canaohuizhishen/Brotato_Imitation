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
        width=Qt.binding(function(){return target.width})
        height=Qt.binding(function(){return target.height})
        x=Qt.binding(function(){return target.parent.x+target.x})
        y=Qt.binding(function(){return target.parent.y+target.y})
        rotation=Qt.binding(function(){
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
