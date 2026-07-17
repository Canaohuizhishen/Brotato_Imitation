.pragma library

/**
 * AABB（轴对齐包围盒）碰撞检测
 *
 * 判断两个矩形是否相交（含内含，不含边缘接触）。
 * 边缘接触（a.x + a.width === b.x 等）视为不相交。
 *
 * @param {{x:number, y:number, width:number, height:number}} a
 * @param {{x:number, y:number, width:number, height:number}} b
 * @returns {boolean} 相交返回 true
 */
function aabbCollide(a, b) {
    return a.x < b.x + b.width &&
           a.x + a.width > b.x &&
           a.y < b.y + b.height &&
           a.y + a.height > b.y
}
