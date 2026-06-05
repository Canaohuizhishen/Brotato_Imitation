import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Brotato
import singleton.PlayerData
import singleton.SettingsData
import "./data/i18n.js" as I18n

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 720
    title: "土豆兄弟(Brotato)(仿)"
    color: "black"

    // 监听设置中的全屏选项
    Connections {
        target: SettingsData
        function onFullscreenChanged() {
            if (SettingsData.fullscreen) {
                window.showFullScreen()
            } else {
                window.showNormal()
            }
        }
    }

    // 窗口失焦行为
    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationInactive || Qt.application.state === Qt.ApplicationHidden) {
                // 窗口未置于前方
                if (SettingsData.muteWhenUnfocused) {
                    sound.setMasterVolume(0)
                }
                if (SettingsData.pauseWhenUnfocused) {
                    // 通知游戏暂停
                    if (typeof gameWindow !== "undefined" && gameWindow.gameArea) {
                        gameWindow.gameArea.paused = true
                    }
                }
            } else if (Qt.application.state === Qt.ApplicationActive) {
                // 窗口恢复前方
                if (SettingsData.muteWhenUnfocused) {
                    sound.setMasterVolume(SettingsData.masterVolume / 100.0)
                }
                if (SettingsData.pauseWhenUnfocused) {
                    if (typeof gameWindow !== "undefined" && gameWindow.gameArea) {
                        gameWindow.gameArea.paused = false
                    }
                }
            }
        }
    }

    // F11 快捷键切换全屏
    Shortcut {
        sequence: StandardKey.FullScreen  // F11 on most platforms
        onActivated: {
            var newVal = !SettingsData.fullscreen
            SettingsData.fullscreen = newVal
            SettingsData.flushSave()
            // 立即切换窗口状态（防止 Connections 延迟）
            if (newVal) {
                window.showFullScreen()
            } else {
                window.showNormal()
            }
        }
    }

    // 窗口关闭前先存盘，确保不因组件销毁顺序丢档
    onClosing: function(close) {
        PlayerData.saveGame()
        SettingsData.flushSave()
        close.accepted = true
    }

    // 全局 i18n 语言缓存同步
    // i18n.js 内部不再使用 Qt.createQmlObject() 读 SettingsData（纯 JS 上下文中静默失败），
    // 改为由这里在启动和切换时主动推送语言索引到缓存。
    Component.onCompleted: {
        I18n.setLanguage(SettingsData.language)
    }

    Connections {
        target: SettingsData
        function onLanguageChanged() {
            I18n.setLanguage(SettingsData.language)
        }
    }

    GameWindow{
        id: gameWindow
        width: window.width/window.height > 1.7777 ? window.height*1.7777 : window.width
        height: window.width/window.height > 1.7777 ? window.height : gameWindow.width/1.7777
    }
}
