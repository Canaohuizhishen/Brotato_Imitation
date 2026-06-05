import QtQuick 2.15
import singleton.SettingsData
import "../data/i18n.js" as I18n

/**
 * TranslatableText — 支持多语言自动翻译的 Text 组件
 *
 * 用法：
 *   TranslatableText {
 *       translationKey: "开始游戏"
 *       basePixelSize: 30
 *       color: "white"
 *   }
 *
 * 切换语言时文本自动更新。组件监听 SettingsData.language 变化。
 */
Text {
    id: root

    /// 中文原文（也是翻译键）
    property string translationKey: ""

    /// 设计基准字号（100%缩放时的像素值）
    property int basePixelSize: 24

    /// 是否应用全局字体缩放
    property bool enableFontScale: true

    /// 实际渲染字号
    readonly property real scaledPixelSize: enableFontScale
        ? basePixelSize * (typeof SettingsData !== "undefined" ? SettingsData.fontScale : 1.0)
        : basePixelSize

    font.pixelSize: scaledPixelSize
    style: Text.Outline
    styleColor: "black"

    // 文本随语言切换自动更新
    text: translationKey ? I18n.tr(translationKey, SettingsData.language) : ""

    // 监听语言变化
    Connections {
        target: typeof SettingsData !== "undefined" ? SettingsData : null
        function onLanguageChanged() {
            root.text = root.translationKey ? I18n.tr(root.translationKey, SettingsData.language) : ""
        }
    }
}
