import QtQuick 2.15
import singleton.PlayerData
import "../logic/utils/tool.js" as Tool

Item {
    id: drops
    anchors.fill: parent
    property Player target
    property double scaleFactor: 1.0
    property double lastScaleFactor: 1.0
    property bool active: true
    property var componentCache: null
    z: 2

    // ---- 材料密度合并系统 ----
    Timer {
        id: mergeTimer
        interval: 15000
        running: drops.active
        repeat: true
        onTriggered: drops.mergeMaterials()
    }

    // 合并一组小材料为一个 BigMaterial
    function _mergeIntoBig(group, tier) {
        // 计算质心
        var cx = 0, cy = 0
        var totalValue = 0
        for (var k = 0; k < group.length; k++) {
            cx += group[k].x + group[k].width / 2
            cy += group[k].y + group[k].height / 2
            totalValue += group[k].value
            group[k].isDestroy = true
            // 安全说明：QML 的 destroy() 是延迟删除（交回到事件循环后才从
            // children 移除），此处遍历的 group 数组是 mergeMaterials() 预先
            // 从网格快照中取出的切片，不依赖 children 的实时状态，因此不会
            // 出现迭代越界问题。若将来重构为在 children 循环中直接调用
            // _mergeIntoBig，则需改用倒序遍历或先收集待删列表。
            group[k].destroy()
        }
        cx /= group.length
        cy /= group.length

        var big = componentCache ? componentCache.createBigMaterial(drops, {
            tier: tier,
            totalValue: totalValue,
            scaleFactor: scaleFactor
        }) : null

        if (!big) {
            console.warn("Drops: BigMaterial creation failed")
            return null
        }
        // 居中于质心
        big.x = cx - big.width / 2
        big.y = cy - big.height / 2
        return big
    }

    // 扫描密度并合并材料
    function mergeMaterials() {
        if (!active) return

        var cellSize = 120
        var grid = {}

        // Step 1: 空间哈希 — 按 120×120 网格归类
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.objectName !== "材料" || child.isGeted || child.isDestroy) continue
            var col = Math.floor(child.x / cellSize)
            var row = Math.floor(child.y / cellSize)
            var key = col + "_" + row
            if (!grid[key]) grid[key] = []
            grid[key].push(child)
        }

        // Step 2: 对每个密集格子做贪心分组合并
        var tierThresholds = [20, 10, 5]   // 从高到低
        var tierValues = [3, 2, 1]

        for (var key in grid) {
            var materials = grid[key]
            if (materials.length < 5) continue

            // 按 value 降序（高价值优先合并）
            materials.sort(function(a, b) { return b.value - a.value })
            var remaining = materials.slice()

            for (var t = 0; t < tierThresholds.length; t++) {
                var threshold = tierThresholds[t]
                var tier = tierValues[t]
                while (remaining.length >= threshold) {
                    var group = remaining.splice(0, threshold)
                    _mergeIntoBig(group, tier)
                }
            }
        }
    }

    onScaleFactorChanged: {
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="材料" || child.objectName==="大材料" || child.objectName==="果实" || child.objectName==="宝箱"){
                child.x=child.x*scaleFactor/lastScaleFactor
                child.y=child.y*scaleFactor/lastScaleFactor
            }
        }
        lastScaleFactor=scaleFactor
    }

    function init(){
        active=true
        clear()
    }

    function clear(){
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="材料" || child.objectName==="大材料" || child.objectName==="果实" || child.objectName==="宝箱"){
                child.destroy()
                child.isDestroy=true
            }
        }
    }

    function allMaterialsToBag(point){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if((child.objectName==="材料" || child.objectName==="大材料") && child.isGeted===false){
                child.toBag(point)
            }
        }
    }

    function allFruitsToPlayer(player){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="果实" && child.isGeted===false){
                child.beGetedTo(player)
            }
        }
    }

    function allChestToPlayer(player){
        if(PlayerData.currentWaveNumber===0)return
        for(var i=0;i<drops.children.length;i++){
            var child=drops.children[i]
            if(child.objectName==="宝箱" && child.isGeted===false){
                child.beGetedTo(player)
            }
        }
    }

    function checkDropCollisions() {
        if (!active) return
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (child.isGeted || child.isDestroy) continue
            if (Tool.getDistance(Qt.point(child.x, child.y), Qt.point(target.x, target.y)) < PlayerData.pickupRange * scaleFactor) {
                if (child.objectName === "材料" || child.objectName === "大材料" || child.objectName === "果实" || child.objectName === "宝箱") {
                    child.beGetedTo(target)
                }
            }
        }
    }
}
