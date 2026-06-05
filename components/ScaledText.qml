import QtQuick 2.15
import singleton.SettingsData
import "../data/i18n.js" as I18n

/**
 * ScaledText — 支持全局字体缩放 + 响应式翻译的 Text 组件
 *
 * 替代硬编码 font.pixelSize，自动应用 SettingsData.fontScale 和 uiScale。
 *
 * 用法（普通文本）：
 *   ScaledText { text: "Hello"; color: "white"; basePixelSize: 30 }
 *
 * 用法（多语言文本）：
 *   ScaledText { translationKey: "开始游戏"; color: "white"; basePixelSize: 30 }
 *   — 切换语言时文本自动更新
 *
 * 实际字号 = basePixelSize × fontScale × uiScale
 * 当用户调整"字体大小"滑块（50%-125%）时，所有 ScaledText 自动跟随缩放。
 */
Text {
    id: root

    /// 设计基准字号（100%缩放时的像素值）
    property int basePixelSize: 24

    /// 组件自身的 UI 缩放系数（对应各组件的 scaleFactor）
    property real uiScale: 1.0

    /// 实际渲染字号（自动乘以 fontScale × uiScale）
    readonly property real scaledPixelSize: basePixelSize * SettingsData.fontScale * uiScale

    font.pixelSize: scaledPixelSize

    /// 多语言翻译键（非空时接管 text 属性，语言切换时自动更新）
    property string translationKey: ""

    // 当 translationKey 变化时立即设置文本
    // 显式传入 SettingsData.language 绕过 i18n.js 内部脆弱的 Qt.createQmlObject()
    onTranslationKeyChanged: {
        if (translationKey) {
            root.text = I18n.tr(translationKey, SettingsData.language)
        }
    }

    // 语言切换时刷新文本
    Connections {
        target: SettingsData
        function onLanguageChanged() {
            if (root.translationKey) {
                root.text = I18n.tr(root.translationKey, SettingsData.language)
            }
        }
    }

    /// 使用方式与 Text 完全兼容
    /// 需要描边效果可在使用时设置：
    ///   style: Text.Outline
    ///   styleColor: "black"
}
