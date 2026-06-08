import QtQuick 2.15

MovingBullet {
    id: bullet

    // 精灵默认朝向角度：0° = 朝右, 180° = 朝左
    property double spriteDefaultAngle: 0
    // 覆盖基类旋转：让精灵始终指向飞行方向
    rotation: spriteDefaultAngle - shootAngle

    property string spriteSource: ""

    Image {
        source: bullet.spriteSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }
}
