import QtQuick 2.15

Monster{
    id: pursuer
    monsterName: "pursuer"
    imageWidth: 60
    imageHeight: imageWidth*1.071

    function updateAcceleration() {
        if (!active || paused) return
        var maxV = core.maxVelocity * 5 / 6
        // 从 175ms 迁移到 per200ms，增量按比例调整: 5 * 200/175 ≈ 5.7
        v += 5.7
        if (v > maxV) v = maxV
    }
}
