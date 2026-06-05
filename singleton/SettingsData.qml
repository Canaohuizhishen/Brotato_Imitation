pragma Singleton
import QtQuick 2.15
import com.mygame.utils 1.0

Item {
    id: settingsData
    visible: false

    property FileManager fileManager: FileManager {}

    // ========== 视频设置 ==========
    property int language: 0                // 语言索引（预留 i18n）
    property int background: 4              // 背景主题索引（梦幻之地）
    property bool screenShake: true         // 屏幕振动
    property bool fullscreen: false         // 全屏模式
    property bool visualEffects: true       // 视觉效果
    property bool showDamageNumbers: true   // 伤害显示
    property bool endOfWaveOptimization: false // 敌袭结束优化

    // ========== 声音设置 ==========
    property int masterVolume: 70           // 主音效 (0-100)
    property int sfxVolume: 50              // 音效 (0-100)
    property int musicVolume: 30            // 音乐 (0-100)
    property bool muteWhenUnfocused: false  // 窗口未置于前方时静音
    property bool pauseWhenUnfocused: false // 窗口未置于前方时暂停

    // ========== 游戏操作 ==========
    property bool mouseOnly: false          // 仅限鼠标
    property bool manualAim: false          // 手动瞄准
    property bool manualAimOnPress: false   // 按下鼠标时手动瞄准
    property bool showCharacterHealthBar: false  // 角色头顶显示血条
    property bool showBossHealthBar: true   // 头目头顶显示血条
    property bool lockItems: true           // 锁定物品
    property int endlessScoreMode: 0        // 无尽模式得分 (0=最高敌袭次数, 1=最高难度)

    // ========== 辅助功能 ==========
    property int enemyHpModifier: 100       // 敌人生命值倍率 (50-125)
    property int enemyDamageModifier: 100   // 敌人伤害倍率 (50-125)
    property int enemySpeedModifier: 100    // 敌人速度倍率 (50-125)
    property int fontSize: 100              // 字体大小 (50-125)
    readonly property real fontScale: fontSize / 100.0  // 字体缩放系数
    property bool highlightCharacter: false // 突显角色
    property bool highlightWeapon: false    // 突显武器
    property bool explosionEffect: true     // 爆炸
    property bool materialSound: true       // 改变材料的声音
    property bool dimScreen: false          // 屏幕变暗
    property bool highlightProjectiles: false // 突显投射物

    // ========== 默认值（用于重置） ==========
    readonly property var defaults: ({
        language: 0,
        background: 4,
        screenShake: true,
        fullscreen: false,
        visualEffects: true,
        showDamageNumbers: true,
        endOfWaveOptimization: false,

        masterVolume: 70,
        sfxVolume: 50,
        musicVolume: 30,
        muteWhenUnfocused: false,
        pauseWhenUnfocused: false,

        mouseOnly: false,
        manualAim: false,
        manualAimOnPress: false,
        showCharacterHealthBar: false,
        showBossHealthBar: true,
        lockItems: true,
        endlessScoreMode: 0,

        enemyHpModifier: 100,
        enemyDamageModifier: 100,
        enemySpeedModifier: 100,
        fontSize: 100,
        highlightCharacter: false,
        highlightWeapon: false,
        explosionEffect: true,
        materialSound: true,
        dimScreen: false,
        highlightProjectiles: false
    })

    // ========== 防抖持久化（500ms 内多次修改只写一次） ==========

    property bool _loading: false          // 加载中标志，加载期间不触发防抖写盘
    property bool _dirty: false

    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: {
            settingsData._dirty = false
            settingsData._flush()
        }
    }

    Component.onCompleted: {
        loadSettings()
    }

    // 公开调用：防抖版 save（多次调用自动合并）
    function saveSettings() {
        if (_loading) return
        if (!_dirty) {
            _dirty = true
            saveTimer.restart()
        } else {
            saveTimer.restart()  // 重新计时
        }
    }

    // 立即写入（窗口关闭/重置时使用）
    function flushSave() {
        if (saveTimer.running) saveTimer.stop()
        _dirty = false
        _flush()
    }

    // 实际写盘逻辑
    function _flush() {
        try {
            const data = {}
            for (var key in defaults) {
                data[key] = settingsData[key]
            }

            const savePath = appDataPath + "/settings.json"
            const success = fileManager.saveGameData(savePath, data)
            if (success) {
                console.log("设置保存成功")
            } else {
                console.error("设置保存失败！")
            }
        } catch (e) {
            console.error("设置保存异常：" + e)
        }
    }

    function loadSettings() {
        _loading = true
        try {
            const savePath = appDataPath + "/settings.json"
            const data = fileManager.loadGameData(savePath)
            if (Object.keys(data).length === 0) {
                console.warn("设置文件不存在或已损坏，使用默认值")
                _loading = false
                return
            }

            language = data.language ?? defaults.language
            background = data.background ?? defaults.background
            screenShake = data.screenShake ?? defaults.screenShake
            fullscreen = data.fullscreen ?? defaults.fullscreen
            visualEffects = data.visualEffects ?? defaults.visualEffects
            showDamageNumbers = data.showDamageNumbers ?? defaults.showDamageNumbers
            endOfWaveOptimization = data.endOfWaveOptimization ?? defaults.endOfWaveOptimization

            masterVolume = data.masterVolume ?? defaults.masterVolume
            sfxVolume = data.sfxVolume ?? defaults.sfxVolume
            musicVolume = data.musicVolume ?? defaults.musicVolume
            muteWhenUnfocused = data.muteWhenUnfocused ?? defaults.muteWhenUnfocused
            pauseWhenUnfocused = data.pauseWhenUnfocused ?? defaults.pauseWhenUnfocused

            mouseOnly = data.mouseOnly ?? defaults.mouseOnly
            manualAim = data.manualAim ?? defaults.manualAim
            manualAimOnPress = data.manualAimOnPress ?? defaults.manualAimOnPress
            showCharacterHealthBar = data.showCharacterHealthBar ?? defaults.showCharacterHealthBar
            showBossHealthBar = data.showBossHealthBar ?? defaults.showBossHealthBar
            lockItems = data.lockItems ?? defaults.lockItems
            endlessScoreMode = data.endlessScoreMode ?? defaults.endlessScoreMode

            enemyHpModifier = data.enemyHpModifier ?? defaults.enemyHpModifier
            enemyDamageModifier = data.enemyDamageModifier ?? defaults.enemyDamageModifier
            enemySpeedModifier = data.enemySpeedModifier ?? defaults.enemySpeedModifier
            fontSize = data.fontSize ?? defaults.fontSize
            highlightCharacter = data.highlightCharacter ?? defaults.highlightCharacter
            highlightWeapon = data.highlightWeapon ?? defaults.highlightWeapon
            explosionEffect = data.explosionEffect ?? defaults.explosionEffect
            materialSound = data.materialSound ?? defaults.materialSound
            dimScreen = data.dimScreen ?? defaults.dimScreen
            highlightProjectiles = data.highlightProjectiles ?? defaults.highlightProjectiles

            console.log("设置加载成功")
        } catch (e) {
            console.error("设置加载异常：" + e)
        }
        _loading = false
    }

    // ========== 重置为默认值 ==========
    function resetToDefaults() {
        language = defaults.language
        background = defaults.background
        screenShake = defaults.screenShake
        fullscreen = defaults.fullscreen
        visualEffects = defaults.visualEffects
        showDamageNumbers = defaults.showDamageNumbers
        endOfWaveOptimization = defaults.endOfWaveOptimization

        masterVolume = defaults.masterVolume
        sfxVolume = defaults.sfxVolume
        musicVolume = defaults.musicVolume
        muteWhenUnfocused = defaults.muteWhenUnfocused
        pauseWhenUnfocused = defaults.pauseWhenUnfocused

        mouseOnly = defaults.mouseOnly
        manualAim = defaults.manualAim
        manualAimOnPress = defaults.manualAimOnPress
        showCharacterHealthBar = defaults.showCharacterHealthBar
        showBossHealthBar = defaults.showBossHealthBar
        lockItems = defaults.lockItems
        endlessScoreMode = defaults.endlessScoreMode

        enemyHpModifier = defaults.enemyHpModifier
        enemyDamageModifier = defaults.enemyDamageModifier
        enemySpeedModifier = defaults.enemySpeedModifier
        fontSize = defaults.fontSize
        highlightCharacter = defaults.highlightCharacter
        highlightWeapon = defaults.highlightWeapon
        explosionEffect = defaults.explosionEffect
        materialSound = defaults.materialSound
        dimScreen = defaults.dimScreen
        highlightProjectiles = defaults.highlightProjectiles

        flushSave()
        console.log("设置已重置为默认值")
    }
}
