.pragma library

// 空间网格分区——将游戏区域划分为等大小网格单元
// 提供 O(1) 插入/更新/查询（在实体均匀分布的前提下）
//
// 注意：insert() 将实体注册到其包围盒覆盖的 *所有* 格子中，
// 而非仅左上角一个格子。这样大怪物的身体延伸到相邻格时，
// 子弹查询相邻格也能找到它。

var _cellSize = 200  // 每个单元格 200×200
var _grid = {}       // "col_row" → [entity1, entity2, ...]
var _entityCells = {} // entity._spatialId → [key1, key2, ...]

function init(cellSize) {
    _cellSize = cellSize || 200
    _grid = {}
    _entityCells = {}
}

// 返回包围盒 (x, y, w, h) 覆盖的所有格子键
function _getKeys(x, y, w, h) {
    var keys = []
    var minCol = Math.floor(x / _cellSize)
    var maxCol = Math.floor((x + w) / _cellSize)
    var minRow = Math.floor(y / _cellSize)
    var maxRow = Math.floor((y + h) / _cellSize)
    for (var col = minCol; col <= maxCol; col++) {
        for (var row = minRow; row <= maxRow; row++) {
            keys.push(col + "_" + row)
        }
    }
    return keys
}

// 将 entity 插入其包围盒覆盖的所有格子
function insert(entity, x, y) {
    var w = entity.width || 0
    var h = entity.height || 0
    var keys = _getKeys(x, y, w, h)
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i]
        if (!_grid[key]) _grid[key] = []
        if (_grid[key].indexOf(entity) === -1) {
            _grid[key].push(entity)
        }
    }
    _entityCells[entity._spatialId] = keys
}

// 从所有格子中移除 entity
function remove(entity) {
    var keys = _entityCells[entity._spatialId]
    if (!keys) return
    for (var i = 0; i < keys.length; i++) {
        var cell = _grid[keys[i]]
        if (!cell) continue
        var idx = cell.indexOf(entity)
        if (idx >= 0) cell.splice(idx, 1)
    }
    delete _entityCells[entity._spatialId]
}

// 更新 entity 的位置：先移除旧格，再插入新格
function update(entity, x, y) {
    remove(entity)
    insert(entity, x, y)
}

// 查询指定矩形范围内的所有实体
function query(x, y, w, h) {
    var result = []
    var minCol = Math.floor(x / _cellSize)
    var maxCol = Math.floor((x + w) / _cellSize)
    var minRow = Math.floor(y / _cellSize)
    var maxRow = Math.floor((y + h) / _cellSize)

    for (var col = minCol; col <= maxCol; col++) {
        for (var row = minRow; row <= maxRow; row++) {
            var key = col + "_" + row
            var cell = _grid[key]
            if (cell) {
                for (var i = 0; i < cell.length; i++) {
                    result.push(cell[i])
                }
            }
        }
    }
    return result
}

function clear() {
    _grid = {}
    _entityCells = {}
}
