import QtQuick
import QtQuick.Controls
import"../components"

Item {
    id: settingsInterface
    z: 150
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

    function backOriginInterface(){
        settingsPopup.visible=true
        general.visible = false
        gameControls.visible = false
    }

    TextMetrics {
        id: textMetrics
        font: backgroundComboBox.font
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.7)
    }

    Column {
        id: settingsPopup
        width: 300
        height: 200
        visible: true
        anchors.centerIn: parent
        spacing: 15

        SetButton {
            text: "一般设定"
            width: parent.width
            onClicked: {
                general.visible = true
                settingsPopup.visible = false
                console.log("一般设定被点击")
            }
        }

        SetButton {
            text: "游戏操作"
            width: parent.width
            onClicked: {
                gameControls.visible = true
                settingsPopup.visible = false
                console.log("游戏操作被点击")
            }
        }

        SetButton {
            id: backButton
            text: "返回"
            width: parent.width
            onClicked:{
                settingsInterface.visible = false
            }
        }
    }
    //一般设定界面**************************************************************************************
    Item {
        id: general
        visible: false
        width: 900
        height: 500
        anchors.centerIn: parent

        Row {
            spacing: 40
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5

            Column {
                width: 420
                height: 500
                spacing: 5
                Text {
                    text: "视频"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 180
                    font.pixelSize: 40
                }

                ComboBox {
                    id: languageComboBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 420
                    height: 45
                    model: ["中文", "繁体中文", "English", "Français", "日本語", "한국어", "Русский язык", "Polski", "Español", "Português", "Deutsch", "Türk", "Italiano"]
                    currentIndex: 0
                    property bool isHovered: false
                    property bool isActive: popup.visible

                    background: Rectangle {
                        color: {
                            if (languageComboBox.isActive) "white"
                            else if (languageComboBox.isHovered) "white"  // 悬停时深灰色
                            else "#000000"  // 默认黑色
                        }
                        radius: 5
                    }
                    HoverHandler {
                        onHoveredChanged: languageComboBox.isHovered = hovered
                    }


                    contentItem: Text {
                        text: parent.displayText
                        font.pixelSize: 30
                        color: {
                            if (languageComboBox.isActive) "#000000"
                            else if (languageComboBox.isHovered) "#000000"
                            else "white"
                        }
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }

                    indicator: Text {
                        text: "▼"
                        color: {
                            if (languageComboBox.isActive) "#000000"
                            else if (languageComboBox.isHovered) "white"  // 悬停时箭头变白
                            else "lightgray"
                        }
                        font.pixelSize: 25
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                    }

                    popup: Popup {
                        y: languageComboBox.height - 1
                        width: languageComboBox.width
                        padding: 1
                        implicitHeight: Math.min(400, contentItem.implicitHeight)
                        background: Rectangle {
                            color: "#000000"
                            radius: 5
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
                                height: 40
                                property bool isHovered: ListView.view.hoveredItem === this

                                Text {
                                    text: ListView.isCurrentItem ? "◦ " + modelData : "• " + modelData
                                    font.pixelSize: 24
                                    color: parent.isHovered ? "black" : "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
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
                                TapHandler {
                                    onTapped: {
                                        // 设置当前选中项
                                        languageComboBox.currentIndex = index
                                        // 关闭下拉菜单
                                        languageComboBox.popup.close()
                                    }
                                }
                            }

                            property Item hoveredItem: null
                        }
                    }
                }

                // 背景选择 ComboBox
                Row{
                    spacing: languageComboBox.width-60-backgroundComboBox.width
                    Text {
                        text:"背景"
                        font.pixelSize: 30
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                    }
                    Item {
                        id: comboContainer
                        height: 45
                        width: backgroundComboBox.width
                        ComboBox {
                            id: backgroundComboBox
                            anchors.right: parent.right
                            height: parent.height
                            model: ListModel {
                                id: bgModel
                                ListElement { text: "随机"; icon: "" }
                                ListElement { text: "泥地"; icon: "" }
                                ListElement { text: "森林"; icon: "" }
                                ListElement { text: "火山"; icon: "" }
                                ListElement { text: "梦幻之地"; icon: "qrc:/images/stone3.png" }
                                ListElement { text: "墓地"; icon: "" }
                                ListElement { text: "黑暗之地"; icon: "" }
                            }
                            textRole: "text"
                            currentIndex: 0
                            property bool isHovered: false
                            property bool isActive: popup.visible


                            // 动态更新宽度
                            function updateWidth() {
                                var currentItem = bgModel.get(currentIndex)
                                textMetrics.text = currentItem.text + "▼"
                                width = Math.max(150, textMetrics.advanceWidth + 110) // 图标宽度+间距
                            }

                            Component.onCompleted: updateWidth()
                            onDisplayTextChanged: updateWidth()

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
                                spacing: 10
                                //anchors.fill: parent
                                width: parent.width
                                height: parent.height
                                anchors.right: indicatorText.left
                                leftPadding: 15
                                //rightPadding: indicatorText.width + 15

                                // 当前选中项的图标
                                Rectangle{
                                    color: "transparent"
                                    border.color: "#000000"
                                    border.width: 5
                                    radius: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 45
                                    height: 30
                                    Image {
                                        source: bgModel.get(backgroundComboBox.currentIndex).icon
                                        anchors.fill: parent
                                        anchors.margins: 5
                                    }
                                }

                                // 当前选中项的文本
                                Text {
                                    text: backgroundComboBox.displayText
                                    font.pixelSize: 30
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


                            indicator: Text {
                                id: indicatorText
                                text: "▼"
                                color: {
                                    if (backgroundComboBox.isActive) "#000000"
                                    else if (backgroundComboBox.isHovered) "white"  // 悬停时箭头变白
                                    else "lightgray"
                                }
                                font.pixelSize: 25
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                            }

                            popup: Popup {
                                y: backgroundComboBox.height - 1
                                width: backgroundComboBox.width
                                implicitHeight: Math.min(400, contentItem.implicitHeight)
                                padding: 1

                                background: Rectangle {
                                    color: "#000000"
                                    radius: 5
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
                                        height: 40
                                        property bool isHovered: ListView.view.hoveredItem === this

                                        Text {
                                            text: ListView.isCurrentItem ? "◦ " + model.text : "• " + model.text
                                            font.pixelSize: 24
                                            color: parent.isHovered ? "black" : "white"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                verticalCenter: parent.verticalCenter
                                                leftMargin: 10
                                                rightMargin: 10
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

                                        TapHandler {
                                            onTapped: {
                                                backgroundComboBox.currentIndex = index
                                                backgroundComboBox.popup.close()
                                            }
                                        }
                                    }
                                    property Item hoveredItem: null
                                }
                            }
                        }
                    }
                }
                //屏幕振动***********************************************************************
                SwitchSettingButton {
                    label: "屏幕振动"
                    onToggled: (checked) => console.log("屏幕振动:", checked)
                }
                SwitchSettingButton {
                    label: "全屏模式"
                    onToggled: (checked) => console.log("全屏模式:", checked)
                }
                SwitchSettingButton {
                    label: "视觉效果"
                    onToggled: (checked) => console.log("视觉效果:", checked)
                }
                SwitchSettingButton {
                    label: "伤害显示"
                    onToggled: (checked) => console.log("伤害显示:", checked)
                }
                SwitchSettingButton {
                    label: "敌袭结束优化"
                    onToggled: (checked) => console.log("敌袭结束优化:", checked)
                }

            }
            Column {
                width: 420
                height: 500
                spacing: 3
                Text {
                    text: "声音"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 180
                    font.pixelSize: 40
                }
                function deselectAllSliders() {
                    for (var i = 0; i < children.length; i++) {
                        if (children[i].deselect) {
                            children[i].deselect()
                        }
                    }
                }

                ProgressBarControlButton {
                    labelText: "主音效"
                    initialValue: 70
                }

                ProgressBarControlButton {
                    labelText: "音效"
                    initialValue: 50
                }

                ProgressBarControlButton {
                    labelText: "音乐"
                    initialValue: 30
                }
                SwitchSettingButton {
                    label: "窗口未置于前方时静音"
                    onToggled: (checked) => console.log("窗口未置于前方时静音:", checked)
                }
                SwitchSettingButton {
                    label: "窗口未置于前方时暂停"
                    onToggled: (checked) => console.log("窗口未置于前方时暂停:", checked)
                }
            }
        }
        Button {
            id: root
            height: 50
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 5
                color: root.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: Text {
                text: "返回"
                color: root.hovered ? "#000000" : "white"
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                settingsPopup.visible = true
                general.visible = false
            }
        }


    }
    //游戏操作设置*********************************************************************
    Item {
        id: gameControls
        visible: false
        width: 900
        height: 570
        anchors.centerIn: parent

        Row {
            spacing: 40
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5

            Column {
                width: 420
                height: 570
                spacing: 5
                Text {
                    text: "游戏操作"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 125
                    font.pixelSize: 40
                }
                SwitchSettingButton {
                    label: "仅限鼠标"
                    onToggled: (checked) => console.log("屏幕振动:", checked)
                }
                SwitchSettingButton {
                    label: "手动瞄准"
                    onToggled: (checked) => console.log("全屏模式:", checked)
                }
                SwitchSettingButton {
                    label: "按下鼠标时手动瞄准"
                    onToggled: (checked) => console.log("视觉效果:", checked)
                }
                SwitchSettingButton {
                    label: "角色头顶显示血条 "
                    onToggled: (checked) => console.log("伤害显示:", checked)
                }
                SwitchSettingButton {
                    label: "头目头顶显示血条"
                    onToggled: (checked) => console.log("敌袭结束优化:", checked)
                }
                SwitchSettingButton {
                    label: "锁定物品"
                    onToggled: (checked) => console.log("敌袭结束优化:", checked)
                }

                Row{
                    spacing: languageComboBox.width-180-endlessModeScore.width
                    Text {
                        text:"无尽模式得分"
                        font.pixelSize: 30
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        height: 45
                        width: endlessModeScore.width
                        ComboBox {
                            id: endlessModeScore
                            anchors.right: parent.right
                            height: parent.height
                            model: ["最高敌袭次数", "最高难度"]
                            currentIndex: 0
                            property bool isHovered: false
                            property bool isActive: popup.visible


                            // 动态更新宽度
                            function updateWidth() {
                                textMetrics.text = displayText+endlessModeScoreText.text
                                width = textMetrics.advanceWidth+80
                            }

                            Component.onCompleted: updateWidth()
                            onDisplayTextChanged: updateWidth()

                            background: Rectangle {
                                color: {
                                    if (endlessModeScore.isActive) "white"
                                    else if (endlessModeScore.isHovered) "white"  // 悬停时深灰色
                                    else "#000000"  // 默认黑色
                                }
                                radius: 5
                            }
                            HoverHandler {
                                onHoveredChanged: endlessModeScore.isHovered = hovered
                            }


                            contentItem: Text {
                                text: parent.displayText
                                font.pixelSize: 30
                                color: {
                                    if (endlessModeScore.isActive) "#000000"
                                    else if (endlessModeScore.isHovered) "#000000"
                                    else "white"
                                }
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                anchors {
                                    left: parent.left
                                    right: endlessModeScoreText.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                    rightMargin: 0
                                }
                            }

                            indicator: Text {
                                id: endlessModeScoreText
                                text: "▼"
                                color: {
                                    if (endlessModeScore.isActive) "#000000"
                                    else if (endlessModeScore.isHovered) "white"  // 悬停时箭头变白
                                    else "lightgray"
                                }
                                font.pixelSize: 25
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                            }

                            popup: Popup {
                                y: endlessModeScore.height - 1
                                width: endlessModeScore.width
                                implicitHeight: Math.min(400, contentItem.implicitHeight)
                                padding: 1

                                background: Rectangle {
                                    color: "#000000"
                                    radius: 5
                                    border.width: 1
                                }

                                contentItem: ListView {
                                    id: endlessModeScoreView
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: endlessModeScore.model
                                    currentIndex: endlessModeScore.currentIndex
                                    highlight: Rectangle {
                                        color: "#3a3a3a"
                                    }
                                    highlightMoveDuration: 0

                                    delegate: Item {
                                        id: endlessModeScoreItem
                                        width: endlessModeScore.width
                                        height: 40
                                        property bool isHovered: ListView.view.hoveredItem === this

                                        Text {
                                            text: ListView.isCurrentItem ? "◦ " + modelData : "• " + modelData
                                            font.pixelSize: 24
                                            color: parent.isHovered ? "black" : "white"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                verticalCenter: parent.verticalCenter
                                                leftMargin: 10
                                                rightMargin: 10
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
                                                endlessModeScore.currentIndex = index
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

            }
            Column {
                width: 420
                height: 570
                spacing: 3
                Text {
                    text: "辅助功能"
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 125
                    font.pixelSize: 40
                }
                ProgressBarControlButton {
                    labelText: "敌人生命值"
                    initialValue: 70
                }
                ProgressBarControlButton {
                    labelText: "敌人伤害"
                    initialValue: 70
                }
                ProgressBarControlButton {
                    labelText: "敌人速度"
                    initialValue: 70
                }
                ProgressBarControlButton {
                    labelText: "字体大小"
                    initialValue: 100
                    linkFontSize: true
                }
                SwitchSettingButton {
                    label: "突显角色"
                    onToggled: (checked) => console.log("突显角色:", checked)
                }
                SwitchSettingButton {
                    label: "突显武器"
                    onToggled: (checked) => console.log("突显武器:", checked)
                }
                SwitchSettingButton {
                    label: "爆炸"
                    onToggled: (checked) => console.log("爆炸:", checked)
                }
                SwitchSettingButton {
                    label: "改变材料的声音 "
                    onToggled: (checked) => console.log("改变材料的声音:", checked)
                }
                SwitchSettingButton {
                    label: "屏幕变暗 "
                    onToggled: (checked) => console.log("屏幕变暗:", checked)
                }
                SwitchSettingButton {
                    label: "突显投射物 "
                    onToggled: (checked) => console.log("突显投射物:", checked)
                }

            }

        }
        Button {
            id: resetToDefault
            height: 50
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 10
                color: resetToDefault.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: Text {
                text: "重置至默认"
                color: resetToDefault.hovered ? "#000000" : "white"
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                console.log("1")
            }
        }
        Button {
            id: back
            height: 50
            anchors.top:resetToDefault.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                radius: 10
                color: back.hovered ? "white" : "#000000"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            contentItem: Text {
                text: "返回"
                color: back.hovered ? "#000000" : "white"
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                settingsPopup.visible = true
                gameControls.visible = false
            }
        }
    }

}
