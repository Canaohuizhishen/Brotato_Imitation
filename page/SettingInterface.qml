import QtQuick
import QtQuick.Controls
import"../components"
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Item {
    id: settingsInterface
    property double scaleFactor: 1.0
    z: 200
    anchors.fill: parent
    focus: true
    property alias backButton: backButton

    onVisibleChanged: {
        if (visible) {
            backOriginInterface()
            forceActiveFocus()
        }
    }

    Keys.onEscapePressed: {
        backButton.click()
    }

    function init(){
        visible=false
    }

    function backOriginInterface(){
        settingsPopup.visible=true
        general.visible = false
        gameControls.visible = false
    }

    //拦截点击事件，防止点击穿透
    TapHandler{
        onTapped: {}
    }




    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.85)
    }

    Column {
        id: settingsPopup
        width: 300*settingsInterface.scaleFactor
        height: 200*settingsInterface.scaleFactor
        visible: true
        anchors.centerIn: parent
        spacing: 15*settingsInterface.scaleFactor

        SetButton {
            scaleFactor: settingsInterface.scaleFactor
            text: I18n.tr("一般设定", SettingsData.language)
            width: parent.width
            onActivated: {
                general.visible = true
                settingsPopup.visible = false
            }
        }

        SetButton {
            scaleFactor: settingsInterface.scaleFactor
            text: I18n.tr("游戏操作", SettingsData.language)
            width: parent.width
            onActivated: {
                gameControls.visible = true
                settingsPopup.visible = false
            }
        }

        SetButton {
            scaleFactor: settingsInterface.scaleFactor
            id: backButton
            text: I18n.tr("返回", SettingsData.language)
            width: parent.width
            onActivated:{
                settingsInterface.visible = false
            }
        }
    }
    //一般设定界面**************************************************************************************
    Item {
        id: general
        visible: false
        width: 900*settingsInterface.scaleFactor
        height: 500*settingsInterface.scaleFactor
        anchors.centerIn: parent

        Row {
            spacing: 40*settingsInterface.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 10*settingsInterface.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 5*settingsInterface.scaleFactor

            Column {
                width: 420*settingsInterface.scaleFactor
                height: 500*settingsInterface.scaleFactor
                spacing: 5*settingsInterface.scaleFactor
                ScaledText {
                    translationKey: "视频"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 180*settingsInterface.scaleFactor
                    basePixelSize: 40
                    uiScale: settingsInterface.scaleFactor
                }

                ComboBox {
                    id: languageComboBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 420*settingsInterface.scaleFactor
                    height: 45*settingsInterface.scaleFactor
                    model: ["中文", "繁体中文", "English", "Français", "日本語", "한국어", "Русский язык", "Polski", "Español", "Português", "Deutsch", "Türk", "Italiano"]
                    currentIndex: SettingsData.language
                    onActivated: { SettingsData.language = index; SettingsData.saveSettings() }
                    property bool isHovered: false
                    property bool isActive: popup.visible

                    background: Rectangle {
                        color: {
                            if (languageComboBox.isActive) "white"
                            else if (languageComboBox.isHovered) "white"  // 悬停时深灰色
                            else "#000000"  // 默认黑色
                        }
                        radius: 5*settingsInterface.scaleFactor
                    }
                    HoverHandler {
                        onHoveredChanged: languageComboBox.isHovered = hovered
                    }


                    contentItem: ScaledText {
                        text: I18n.tr(languageComboBox.model[languageComboBox.currentIndex], SettingsData.language)
                        basePixelSize: 30
                        uiScale: settingsInterface.scaleFactor
                        color: {
                            if (languageComboBox.isActive) "#000000"
                            else if (languageComboBox.isHovered) "#000000"
                            else "white"
                        }
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10*settingsInterface.scaleFactor
                    }

                    indicator: ScaledText {
                        text: "▼"
                        color: {
                            if (languageComboBox.isActive) "#000000"
                            else if (languageComboBox.isHovered) "white"  // 悬停时箭头变白
                            else "lightgray"
                        }
                        basePixelSize: 25
                        uiScale: settingsInterface.scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10*settingsInterface.scaleFactor
                    }

                    popup: Popup {
                        y: languageComboBox.height - 1
                        width: languageComboBox.width
                        padding: 1*settingsInterface.scaleFactor
                        implicitHeight: Math.min(400, contentItem.implicitHeight)
                        background: Rectangle {
                            color: "#000000"
                            radius: 5*settingsInterface.scaleFactor
                            border.width: 1
                        }

                        contentItem: ListView {
                            id: languageListView
                            clip: true
                            implicitHeight: contentHeight
                            model: languageComboBox.model
                            currentIndex: languageComboBox.currentIndex
                            highlight: Rectangle {
                                color: "#3a3a3a"
                            }
                            highlightMoveDuration: 0

                            delegate: Item {
                                id: delegateItem
                                width: languageComboBox.width
                                height: 40*settingsInterface.scaleFactor
                                property bool isHovered: ListView.view.hoveredItem === this

                                ScaledText {
                                    text: ListView.isCurrentItem ? "◦ " + I18n.tr(modelData, SettingsData.language) : "• " + I18n.tr(modelData, SettingsData.language)
                                    basePixelSize: 24
                                    uiScale: settingsInterface.scaleFactor
                                    color: parent.isHovered ? "black" : "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10*settingsInterface.scaleFactor
                                    anchors.verticalCenter: parent.verticalCenter
                                    z:1
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: parent.isHovered ? "lightgray" : "transparent"
                                    z:0
                                }

                                HoverHandler {
                                    onHoveredChanged: {
                                        if (hovered) {
                                            languageListView.hoveredItem = delegateItem
                                        }
                                    }
                                }

                                // 点击处理
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: (mouse) => {
                                        mouse.accepted = true
                                        SettingsData.language = index
                                        SettingsData.saveSettings()
                                        languageComboBox.popup.close()
                                    }
                                }
                            }

                            property Item hoveredItem: null
                        }
                    }
                }

                // 背景选择 ComboBox
                Item{
                    width: parent.width
                    height: 45*settingsInterface.scaleFactor

                    ScaledText {
                        translationKey: "背景"
                        basePixelSize: 30
                        uiScale: settingsInterface.scaleFactor
                        color: "white"
                        anchors.left: parent.left
                        anchors.leftMargin: 10*settingsInterface.scaleFactor
                        width: 60*settingsInterface.scaleFactor
                    }
                    ComboBox {
                        id: backgroundComboBox
                        width: backgroundIcon.width+backgroundName.width+backgroundItem.spacing+indicatorText.width+20*settingsInterface.scaleFactor
                        height: parent.height
                        anchors.right: parent.right
                        textRole: "text"
                        currentIndex: SettingsData.background
                        onActivated: { SettingsData.background = index; SettingsData.saveSettings() }

                        // 动态模型：ListElement 不支持表达式，改为在 JS 中填充翻译文本
                        model: ListModel {
                            id: bgModel
                            ListElement { text: ""; icon: "" }
                            ListElement { text: ""; icon: "" }
                            ListElement { text: ""; icon: "" }
                            ListElement { text: ""; icon: "" }
                            ListElement { text: ""; icon: "qrc:/images/stone3.png" }
                            ListElement { text: ""; icon: "" }
                            ListElement { text: ""; icon: "" }
                        }

                        // 背景原始 key（用于 I18n.tr 查找），图标已内置在模型静态行中
                        property var _bgKeys: ["随机", "泥地", "森林", "火山", "梦幻之地", "墓地", "黑暗之地"]

                        // 用翻译文本填充模型（仅首次 + 语言切换时调用）
                        // 不改变模型结构/数量，避免破坏 currentIndex 绑定
                        function translateModel() {
                            for (var i = 0; i < backgroundComboBox._bgKeys.length; i++) {
                                bgModel.setProperty(i, "text",
                                    I18n.tr(backgroundComboBox._bgKeys[i], SettingsData.language))
                            }
                        }

                        Component.onCompleted: {
                            translateModel()
                        }

                        // 语言切换时刷新模型中的翻译文本
                        Connections {
                            target: SettingsData
                            function onLanguageChanged() {
                                backgroundComboBox.translateModel()
                            }
                        }

                        property bool isHovered: false
                        property bool isActive: popup.visible

                        background: Rectangle {
                            color: {
                                if (backgroundComboBox.isActive) "white"
                                else if (backgroundComboBox.isHovered) "white"  // 悬停时深灰色
                                else "#000000"  // 默认黑色
                            }
                            radius: 5
                        }
                        HoverHandler {
                            onHoveredChanged: backgroundComboBox.isHovered = hovered
                        }


                        contentItem: Row {
                            id: backgroundItem
                            spacing: 10*settingsInterface.scaleFactor
                            height: parent.height
                            anchors.right: indicatorText.left
                            leftPadding: 15*settingsInterface.scaleFactor

                            // 当前选中项的图标
                            Rectangle{
                                id: backgroundIcon
                                color: "transparent"
                                border.color: "#000000"
                                border.width: 5*settingsInterface.scaleFactor
                                radius: 3*settingsInterface.scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                width: 45*settingsInterface.scaleFactor
                                height: 30*settingsInterface.scaleFactor
                                Image {
                                    source: bgModel.get(backgroundComboBox.currentIndex).icon
                                    anchors.fill: parent
                                    anchors.margins: 5*settingsInterface.scaleFactor
                                }
                            }

                            // 当前选中项的文本
                            ScaledText {
                                id: backgroundName
                                text: backgroundComboBox.displayText
                                basePixelSize: 30
                                uiScale: settingsInterface.scaleFactor
                                color: {
                                    if (backgroundComboBox.isActive) "#000000"
                                    else if (backgroundComboBox.isHovered) "#000000"
                                    else "white"
                                }
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        indicator: ScaledText {
                            id: indicatorText
                            text: "▼"
                            color: {
                                if (backgroundComboBox.isActive) "#000000"
                                else if (backgroundComboBox.isHovered) "white"  // 悬停时箭头变白
                                else "lightgray"
                            }
                            basePixelSize: 25
                            uiScale: settingsInterface.scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10*settingsInterface.scaleFactor
                        }

                        popup: Popup {
                            y: backgroundComboBox.height - 1*settingsInterface.scaleFactor
                            width: backgroundComboBox.width
                            implicitHeight: Math.min(400, contentItem.implicitHeight)
                            padding: 1*settingsInterface.scaleFactor

                            background: Rectangle {
                                color: "#000000"
                                radius: 5*settingsInterface.scaleFactor
                                border.width: 1
                            }

                            contentItem: ListView {
                                id: backgroundListView
                                clip: true
                                implicitHeight: contentHeight
                                model: bgModel
                                currentIndex: backgroundComboBox.currentIndex
                                highlight: Rectangle {
                                    color: "#3a3a3a"
                                }
                                highlightMoveDuration: 0

                                delegate: Item {
                                    id: bgDelegateItem
                                    width: backgroundComboBox.width
                                    height: 40*settingsInterface.scaleFactor
                                    property bool isHovered: ListView.view.hoveredItem === this

                                    ScaledText {
                                        text: ListView.isCurrentItem ? "◦ " + model.text : "• " + model.text
                                        basePixelSize: 24
                                        uiScale: settingsInterface.scaleFactor
                                        color: parent.isHovered ? "black" : "white"
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignLeft
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: 10*settingsInterface.scaleFactor
                                            rightMargin: 10*settingsInterface.scaleFactor
                                        }
                                        z:1
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: parent.isHovered ? "lightgray" : "transparent"
                                        z:0
                                    }

                                    HoverHandler {
                                        onHoveredChanged: {
                                            if (hovered) {
                                                backgroundListView.hoveredItem = bgDelegateItem
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: (mouse) => {
                                            mouse.accepted = true
                                            SettingsData.background = index
                                            SettingsData.saveSettings()
                                            backgroundComboBox.popup.close()
                                        }
                                    }
                                }
                                property Item hoveredItem: null
                            }
                        }
                    }
                }
                //屏幕振动***********************************************************************
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("屏幕振动", SettingsData.language)
                    checked: SettingsData.screenShake
                    onToggled: (checked) => { SettingsData.screenShake = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("全屏模式", SettingsData.language)
                    checked: SettingsData.fullscreen
                    onToggled: (checked) => { SettingsData.fullscreen = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("视觉效果", SettingsData.language)
                    checked: SettingsData.visualEffects
                    onToggled: (checked) => { SettingsData.visualEffects = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("伤害显示", SettingsData.language)
                    checked: SettingsData.showDamageNumbers
                    onToggled: (checked) => { SettingsData.showDamageNumbers = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("敌袭结束优化", SettingsData.language)
                    checked: SettingsData.endOfWaveOptimization
                    onToggled: (checked) => { SettingsData.endOfWaveOptimization = checked; SettingsData.saveSettings() }
                }
            }
            Column {
                width: 420*settingsInterface.scaleFactor
                height: 500*settingsInterface.scaleFactor
                spacing: 3*settingsInterface.scaleFactor
                ScaledText {
                    translationKey: "声音"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 180*settingsInterface.scaleFactor
                    basePixelSize: 40
                    uiScale: settingsInterface.scaleFactor
                }
                function deselectAllSliders() {
                    for (var i = 0; i < children.length; i++) {
                        if (children[i].deselect) {
                            children[i].deselect()
                        }
                    }
                }

                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("主音效", SettingsData.language)
                    audioChannel: "master"
                    currentValue: SettingsData.masterVolume
                    onValueChanged: (newValue) => { SettingsData.masterVolume = newValue; SettingsData.saveSettings() }
                }

                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("音效", SettingsData.language)
                    audioChannel: "sfx"
                    currentValue: SettingsData.sfxVolume
                    onValueChanged: (newValue) => { SettingsData.sfxVolume = newValue; SettingsData.saveSettings() }
                }

                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("音乐", SettingsData.language)
                    audioChannel: "music"
                    currentValue: SettingsData.musicVolume
                    onValueChanged: (newValue) => { SettingsData.musicVolume = newValue; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("窗口未置于前方时静音", SettingsData.language)
                    checked: SettingsData.muteWhenUnfocused
                    onToggled: (checked) => { SettingsData.muteWhenUnfocused = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("窗口未置于前方时暂停", SettingsData.language)
                    checked: SettingsData.pauseWhenUnfocused
                    onToggled: (checked) => { SettingsData.pauseWhenUnfocused = checked; SettingsData.saveSettings() }
                }
            }
        }
        Button {
            id: root
            height: 50*settingsInterface.scaleFactor
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 5*settingsInterface.scaleFactor
                color: root.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: ScaledText {
                translationKey: "返回"
                color: root.hovered ? "#000000" : "white"
                basePixelSize: 30
                uiScale: settingsInterface.scaleFactor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                settingsPopup.visible = true
                general.visible = false
                sound.playClickSound()
            }
        }
    }
    //游戏操作设置*********************************************************************
    Item {
        id: gameControls
        visible: false
        width: 900*settingsInterface.scaleFactor
        height: 570*settingsInterface.scaleFactor
        anchors.centerIn: parent

        Row {
            spacing: 40*settingsInterface.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 10*settingsInterface.scaleFactor
            anchors.top: parent.top
            anchors.topMargin: 5*settingsInterface.scaleFactor

            Column {
                width: 420*settingsInterface.scaleFactor
                height: 570*settingsInterface.scaleFactor
                spacing: 5*settingsInterface.scaleFactor
                ScaledText {
                    translationKey: "游戏操作"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 125*settingsInterface.scaleFactor
                    basePixelSize: 40
                    uiScale: settingsInterface.scaleFactor
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("仅限鼠标", SettingsData.language)
                    checked: SettingsData.mouseOnly
                    onToggled: (checked) => { SettingsData.mouseOnly = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("手动瞄准", SettingsData.language)
                    checked: SettingsData.manualAim
                    onToggled: (checked) => { SettingsData.manualAim = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("—按下鼠标时手动瞄准", SettingsData.language)
                    checked: SettingsData.manualAimOnPress
                    indent: 40 * settingsInterface.scaleFactor
                    enabled: SettingsData.manualAim
                    onToggled: (checked) => { SettingsData.manualAimOnPress = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("角色头顶显示血条", SettingsData.language)
                    checked: SettingsData.showCharacterHealthBar
                    onToggled: (checked) => { SettingsData.showCharacterHealthBar = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("头目头顶显示血条", SettingsData.language)
                    checked: SettingsData.showBossHealthBar
                    onToggled: (checked) => { SettingsData.showBossHealthBar = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("锁定物品", SettingsData.language)
                    checked: SettingsData.lockItems
                    onToggled: (checked) => { SettingsData.lockItems = checked; SettingsData.saveSettings() }
                }

                Item{
                    width: parent.width
                    height: 45*settingsInterface.scaleFactor

                    ScaledText {
                        translationKey: "无尽模式得分"
                        basePixelSize: 30
                        uiScale: settingsInterface.scaleFactor
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox {
                        id: endlessModeScore
                        width: endlessModeScore.currentIndex === 0 ? 220*settingsInterface.scaleFactor : 160*settingsInterface.scaleFactor
                        height: 45*settingsInterface.scaleFactor
                        anchors.right: parent.right
                        model: ["最高敌袭次数", "最高难度"]
                        currentIndex: SettingsData.endlessScoreMode
                        onActivated: { SettingsData.endlessScoreMode = index; SettingsData.saveSettings() }
                        property bool isHovered: false
                        property bool isActive: popup.visible


                        background: Rectangle {
                            color: {
                                if (endlessModeScore.isActive) "white"
                                else if (endlessModeScore.isHovered) "white"  // 悬停时深灰色
                                else "#000000"  // 默认黑色
                            }
                            radius: 5*settingsInterface.scaleFactor
                        }
                        HoverHandler {
                            onHoveredChanged: endlessModeScore.isHovered = hovered
                        }

                        contentItem: ScaledText {
                            id: modeText
                            text: I18n.tr(endlessModeScore.model[endlessModeScore.currentIndex], SettingsData.language)
                            basePixelSize: 30
                            uiScale: settingsInterface.scaleFactor
                            color: {
                                if (endlessModeScore.isActive) "#000000"
                                else if (endlessModeScore.isHovered) "#000000"
                                else "white"
                            }
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            anchors {
                                right: endlessModeScoreText.left
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        indicator: ScaledText {
                            id: endlessModeScoreText
                            text: "▼"
                            color: {
                                if (endlessModeScore.isActive) "#000000"
                                else if (endlessModeScore.isHovered) "white"  // 悬停时箭头变白
                                else "lightgray"
                            }
                            basePixelSize: 25
                            uiScale: settingsInterface.scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10*settingsInterface.scaleFactor
                        }

                        popup: Popup {
                            y: endlessModeScore.height - 1*settingsInterface.scaleFactor
                            width: endlessModeScore.currentIndex === 0 ? 220*settingsInterface.scaleFactor : 165*settingsInterface.scaleFactor
                            implicitHeight: Math.min(400, contentItem.implicitHeight)
                            padding: 1*settingsInterface.scaleFactor

                            background: Rectangle {
                                color: "#000000"
                                radius: 5*settingsInterface.scaleFactor
                                border.width: 1*settingsInterface.scaleFactor
                            }

                            contentItem: ListView {
                                id: endlessModeScoreView
                                //clip: true
                                implicitHeight: contentHeight
                                model: endlessModeScore.model
                                currentIndex: endlessModeScore.currentIndex
                                highlight: Rectangle {
                                    color: "#3a3a3a"
                                }
                                highlightMoveDuration: 0

                                delegate: Item {
                                    id: endlessModeScoreItem
                                    width: parent.width
                                    height: 40*settingsInterface.scaleFactor
                                    property bool isHovered: ListView.view.hoveredItem === this

                                    ScaledText {
                                        text: ListView.isCurrentItem ? "◦" + I18n.tr(modelData, SettingsData.language) : "•" + I18n.tr(modelData, SettingsData.language)
                                        basePixelSize: 24
                                        uiScale: settingsInterface.scaleFactor
                                        color: parent.isHovered ? "black" : "white"
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignLeft
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            verticalCenter: parent.verticalCenter
                                        }
                                        z:1
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: parent.isHovered ? "lightgray" : "transparent"
                                        z:0
                                    }

                                    HoverHandler {
                                        onHoveredChanged: {
                                            if (hovered) {
                                                endlessModeScoreView.hoveredItem = endlessModeScoreItem
                                            }
                                        }
                                    }

                                    TapHandler {
                                        onTapped: {
                                            SettingsData.endlessScoreMode = index
                                            SettingsData.saveSettings()
                                            endlessModeScore.popup.close()
                                        }
                                    }
                                }
                                property Item hoveredItem: null
                            }
                        }
                    }
                }

            }
            Column {
                width: 420*settingsInterface.scaleFactor
                height: 570*settingsInterface.scaleFactor
                spacing: 3*settingsInterface.scaleFactor
                function deselectAllSliders() {
                    for (var i = 0; i < children.length; i++) {
                        if (children[i].deselect) {
                            children[i].deselect()
                        }
                    }
                }
                ScaledText {
                    translationKey: "辅助功能"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 125*settingsInterface.scaleFactor
                    basePixelSize: 40
                    uiScale: settingsInterface.scaleFactor
                }
                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("敌人生命值", SettingsData.language)
                    currentValue: SettingsData.enemyHpModifier
                    sliderFrom: 50
                    sliderTo: 125
                    onValueChanged: (newValue) => { SettingsData.enemyHpModifier = newValue; SettingsData.saveSettings() }
                }
                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("敌人伤害", SettingsData.language)
                    currentValue: SettingsData.enemyDamageModifier
                    sliderFrom: 50
                    sliderTo: 125
                    onValueChanged: (newValue) => { SettingsData.enemyDamageModifier = newValue; SettingsData.saveSettings() }
                }
                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("敌人速度", SettingsData.language)
                    currentValue: SettingsData.enemySpeedModifier
                    sliderFrom: 50
                    sliderTo: 125
                    onValueChanged: (newValue) => { SettingsData.enemySpeedModifier = newValue; SettingsData.saveSettings() }
                }
                ProgressBarControlButton {
                    scaleFactor: settingsInterface.scaleFactor
                    labelText: I18n.tr("字体大小", SettingsData.language)
                    currentValue: SettingsData.fontSize
                    linkFontSize: true
                    sliderFrom: 50
                    sliderTo: 125
                    onValueChanged: (newValue) => { SettingsData.fontSize = newValue; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("突显角色", SettingsData.language)
                    checked: SettingsData.highlightCharacter
                    onToggled: (checked) => { SettingsData.highlightCharacter = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("突显武器", SettingsData.language)
                    checked: SettingsData.highlightWeapon
                    onToggled: (checked) => { SettingsData.highlightWeapon = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("爆炸", SettingsData.language)
                    checked: SettingsData.explosionEffect
                    onToggled: (checked) => { SettingsData.explosionEffect = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("改变材料的声音", SettingsData.language)
                    checked: SettingsData.materialSound
                    onToggled: (checked) => { SettingsData.materialSound = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("屏幕变暗", SettingsData.language)
                    checked: SettingsData.dimScreen
                    onToggled: (checked) => { SettingsData.dimScreen = checked; SettingsData.saveSettings() }
                }
                SwitchSettingButton {
                    scaleFactor: settingsInterface.scaleFactor
                    label: I18n.tr("突显投射物", SettingsData.language)
                    checked: SettingsData.highlightProjectiles
                    onToggled: (checked) => { SettingsData.highlightProjectiles = checked; SettingsData.saveSettings() }
                }
            }
        }
        Button {
            id: resetToDefault
            height: 50*settingsInterface.scaleFactor
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 10*settingsInterface.scaleFactor
                color: resetToDefault.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: ScaledText {
                translationKey: "重置至默认"
                color: resetToDefault.hovered ? "#000000" : "white"
                basePixelSize: 30
                uiScale: settingsInterface.scaleFactor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                SettingsData.resetToDefaults()
                sound.playClickSound()
            }
            onHoveredChanged: {
                if(hovered) {
                    sound.playHoverSound1()
                }
            }
        }
        Button {
            id: back
            height: 50*settingsInterface.scaleFactor
            anchors.top:resetToDefault.bottom
            anchors.topMargin: 5*settingsInterface.scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 10*settingsInterface.scaleFactor
                color: back.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: ScaledText {
                translationKey: "返回"
                color: back.hovered ? "#000000" : "white"
                basePixelSize: 30
                uiScale: settingsInterface.scaleFactor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                settingsPopup.visible = true
                gameControls.visible = false
                sound.playClickSound()
            }
            onHoveredChanged: {
                if(hovered) {
                    sound.playHoverSound1()
                }
            }
        }
    }
}
