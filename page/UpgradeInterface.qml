pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import "../components"
import "../data"
import singleton.SettingsData
import "../data/i18n.js" as I18n

Rectangle {
    id: root
    property double scaleFactor: 1.0
    property UpgradeNotificationBar upgradeNotificationBar
    color: Qt.rgba(0,0,0,0.5)
    anchors.fill: parent
    signal choosedOne()

    Component.onCompleted: {
        upgradeOptionsRow.addOptions()
    }

    function init(){
        visible=false
        upData()
    }

    function upData(){
        upgradeOptionsRow.model.clear()
        upgradeOptionsRow.addOptions()
        refreshButton.count=0
        attributePanel.upData()
    }

    // 升级文本
    ScaledText {
        id: upgradeTitle
        text: I18n.tr("升级!", SettingsData.language)
        basePixelSize: 42
        uiScale: root.scaleFactor
        style: Text.Outline
        color: "black"
        anchors.top: parent.top
        anchors.topMargin: 70*root.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter

        ScaledText {
            text: upgradeTitle.text
            color: "white"
            font.pixelSize: upgradeTitle.font.pixelSize
            anchors.centerIn: upgradeTitle
        }
    }

    // 升级选项区域
    ListView {
        id: upgradeOptionsRow
        width: 983*root.scaleFactor
        height: 175*root.scaleFactor
        interactive: false
        orientation: ListView.Horizontal
        spacing: 5*root.scaleFactor
        anchors.left: root.left
        anchors.leftMargin:20*root.scaleFactor
        anchors.verticalCenter: root.verticalCenter
        anchors.verticalCenterOffset: -15*root.scaleFactor
        model: ListModel {}

        delegate:UpgradeOption {
            required property string name
            required property string level
            required property string upgradeOptionName
            required property string description

            scaleFactor: root.scaleFactor
            optionName: name
            iconSource: "/images/"+name+".png"
            title: upgradeOptionName
            talentText: description
            grade:level

            chooseButton.onClicked: {
                root.upgradeNotificationBar.number--
                root.upData()
                root.choosedOne()
            }
        }

        function addOptions(){
            var array=core.getOptionRandomly(4)
            for(var i=0;i<array.length;i++){
                model.append({ "level":array[i].grade,"name": array[i].objectName, "upgradeOptionName":array[i].optionName , "description": core.renderTalentText(array[i].talentTextTemplate, array[i].grade) })
            }
        }
    }

    UpgradeOptionCustomizationCore{
        id:core
    }

    //刷新按钮
    Button {
        id: refreshButton
        width: 160*root.scaleFactor
        height: 42*root.scaleFactor
        hoverEnabled: true
        background: Rectangle {
            radius: 5*root.scaleFactor
            color: refreshButton.hovered ? "white" : "black"
        }
        anchors.top: upgradeOptionsRow.bottom
        anchors.topMargin: 30*root.scaleFactor
        anchors.horizontalCenter: upgradeOptionsRow.horizontalCenter
        property int value: 3+count
        property int count: 0
        onClicked: {
            if(PlayerData.materialsNumber>=value){
                PlayerData.materialsNumber-=value
                count++
                upgradeOptionsRow.model.clear()
                upgradeOptionsRow.addOptions()
            }
            sound.playClickSound()
        }
        Row{
            spacing: 2*root.scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            ScaledText {
                text:I18n.tr("刷新-", SettingsData.language)+refreshButton.value
                basePixelSize: 28
                uiScale: root.scaleFactor
                color: PlayerData.materialsNumber>=refreshButton.value ? (refreshButton.hovered ? "black" : "white") : "red"
            }

            Image {
                width: 30*root.scaleFactor
                height:30*root.scaleFactor
                source: "qrc:/images/material_icon.png"
            }

        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
    }

    AttributePanel{
        id: attributePanel
        scaleFactor: root.scaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 13*root.scaleFactor
        anchors.top: root.top
        anchors.topMargin: 125*root.scaleFactor
    }
}



