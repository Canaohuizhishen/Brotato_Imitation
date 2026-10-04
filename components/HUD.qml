import QtQuick 2.15
import singleton.PlayerData

// HUD — 战斗场景的固定状态显示层（血条/经验条/材料/背包/波数）。
// 约束：
//  - 只读单例数据，不写游戏逻辑、不访问 GameWindow 的 id；
//  - 显隐由外部注入（GameWindow 中绑定 gameArea.visible），与抽取前各组件各自绑定的效果一致；
//  - bagBar 以属性别名对外暴露：GameWindow.onIsInCombatChanged 依赖
//    hud.bagBar.imageCenterPoint 计算"掉落物磁吸入包"的坐标（回归重点）。
Item {
    id: hud
    anchors.fill: parent
    z: 10
    property double scaleFactor: 1.0
    property alias bagBar: bagBar

    HealthBar {
        id: healthBar
        z: 10
        scaleFactor: hud.scaleFactor
        maxHp: PlayerData.maxHp
        hp: PlayerData.curHp
    }

    ExperienceBar {
        id: experienceBar
        z: 10
        scaleFactor: hud.scaleFactor
        level: PlayerData.curLevel
        maxXp: PlayerData.maxXp
        xp: PlayerData.curXp
    }

    MaterialsBar {
        id: materialsBar
        z: 10
        scaleFactor: hud.scaleFactor
        number: PlayerData.materialsNumber
    }

    BagBar {
        id: bagBar
        z: 10
        scaleFactor: hud.scaleFactor
        number: PlayerData.remainingMaterialsNumber
    }

    WaveNumberText {
        id: waveNumberText
        z: 10
        scaleFactor: hud.scaleFactor
        text: PlayerData.currentWaveNumber
    }
}
