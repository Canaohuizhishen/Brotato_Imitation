import QtQuick 2.15
import singleton.PlayerData
import "../components"
import "../data/cores"

RangedWeapon {
    id: constructWeapon
    property string constructType: "turret"  // "turret" or "mine"
    property var constructsContainer: null

    // 重写 fire 行为：放置构筑物取代射子弹
    function fire(){
        if (!constructsContainer || !targetPoint) return

        // 以目标点为中心放置构筑物
        constructsContainer.placeConstruct(constructType, targetPoint.x, targetPoint.y)

        // 播放音效（复用攻击音效，没有就用默认）
        attackSound.play()
    }

    // 由于使用 RangedWeapon 的瞄准系统但替换了 fire，
    // 需要阻止原有的子弹创建逻辑。
    // 通过创建一个空的 fire() 覆盖来实现。
    // 实际的触发由 RangedWeapon 的 fireTimer 调用 inFire 状态 + 这里的 fire()
}
