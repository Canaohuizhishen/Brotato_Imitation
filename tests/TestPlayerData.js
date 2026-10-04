.pragma library

// 测试用 PlayerData 替身（仅测试环境）：
// 为 ShopLogicHandler.refreshShop 的文件作用域解析提供数据源，
// 使测试无需（也无法）依赖 QML 单例 PlayerData 与任何界面元素。

var currentWaveNumber = 5

var lastStoreGoods = {
    arr: [],
    count: 0,
    get: function(i) { return this.arr[i] },
    clear: function() { this.arr = []; this.count = 0 },
    append: function(x) { this.arr.push(x); this.count = this.arr.length }
}
