import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"
import "../data/cores"
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

Item {
    id: weaponSelectionInterface
    property double scaleFactor: 1.0
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100
    property Button backButton: back
    property string selectedRoleName
    property string selectedWeaponName
    signal selected()

    onVisibleChanged: {
        if(visible)forceActiveFocus()
    }

    Keys.onEscapePressed: {
        backButton.click()
    }

    function init(){
        visible=false
        selectedRoleName=""
        selectedWeaponName=""
        weaponRow.currentIndex=0
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#353535"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#555555" }
            GradientStop { position: 0.5; color: "#353535" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }
    }

    ScaledText {
        text: I18n.tr("武器选择", SettingsData.language)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 42*weaponSelectionInterface.scaleFactor
        color: "white"
        basePixelSize: 35
        uiScale: weaponSelectionInterface.scaleFactor
        style: Text.Outline
        styleColor: "black"
    }

    RoleCard{
        id: roleCard
        roleName: weaponSelectionInterface.selectedRoleName
        scaleFactor: weaponSelectionInterface.scaleFactor
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 3*weaponCard.scaleFactor
    }

    WeaponCard{
        id: weaponCard
        weaponName: weaponRow.currentItemIsWeapon ? weaponRow.currentItem.name : ""
        scaleFactor: weaponSelectionInterface.scaleFactor
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 3
    }

    WeaponCustomizationCore{
        id: weaponCore
    }

    GridView {
        id: weaponRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: spacing/2
        anchors.top: weaponCard.bottom
        anchors.topMargin: 25*weaponSelectionInterface.scaleFactor
        width: cellWidth*(totalWeaponCount+1)+1
        height:  cellHeight
        property int spacing: 5*weaponSelectionInterface.scaleFactor
        cellWidth: 68*weaponSelectionInterface.scaleFactor
        cellHeight: cellWidth
        interactive: false
        property int canUsedWeaponNumber: {
            var n = 0
            for (var i = 0; i < model.count; i++) {
                if (model.get(i).implemented) n++
            }
            return n
        }
        // 包含未实现武器的总数，用于网格宽度（确保未实现武器占位可见）
        property int totalWeaponCount: weaponCore.getAllWeapons().length
        property bool currentItemIsWeapon: currentItem.name!=="question"
        model: ListModel{
            Component.onCompleted: {
                var weapons = weaponCore.getAllWeapons()
                for(var i=0;i<weapons.length;i++){
                    append({ name: weapons[i].objectName, implemented: weaponCore.isWeaponImplemented(weapons[i].objectName) });
                }
            }
            ListElement{ name: "question"; implemented: true }
        }

        delegate: Button {
            required property string name
            required property bool implemented
            required property int index
            width: weaponRow.cellWidth-weaponRow.spacing
            height: width
            enabled: name === "question" || implemented

            background: Rectangle {
                color: {
                    if (!enabled) return "#111111"
                    if (pressed || hovered || weaponRow.currentIndex===index) return "#cfcfcf"
                    return "#222222"
                }
                radius: 4*weaponSelectionInterface.scaleFactor
                border.color: !enabled ? "#444444" : "transparent"
                border.width: !enabled ? 1 : 0
            }

            Image {
                width: parent.width*(name==="question" ? 0.9 : 1)
                height: width
                source: "qrc:/images/icon_"+name+".png"
                anchors.centerIn: parent
                opacity: parent.enabled ? 1.0 : 0.3
                property bool _fallbackTried: false
                onStatusChanged: {
                    if (status === Image.Error && !_fallbackTried) {
                        _fallbackTried = true
                        source = "qrc:/images/icon_0.png"
                    }
                }
            }

            // 未实现武器的占位提示文字
            ScaledText {
                visible: !parent.enabled && parent.hovered
                text: I18n.tr("未实现", SettingsData.language)
                basePixelSize: 10
                uiScale: weaponSelectionInterface.scaleFactor
                color: "#ffcc00"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                style: Text.Outline
                styleColor: "black"
                z: 10
            }

            onClicked: {
                if(name==="question"){
                    // 随机选一个已实现的武器
                    var implementedIndices = []
                    for (var i = 1; i < weaponRow.model.count; i++) {
                        if (weaponRow.model.get(i).implemented)
                            implementedIndices.push(i)
                    }
                    if (implementedIndices.length > 0)
                        weaponRow.currentIndex = implementedIndices[Math.floor(Math.random() * implementedIndices.length)]
                    else
                        weaponRow.currentIndex = 0
                }else {
                    if(weaponRow.currentIndex === index){
                        weaponSelectionInterface.selectedWeaponName = name
                        weaponSelectionInterface.selected()
                    }else {
                        weaponRow.currentIndex=index
                    }
                }
                sound.playClickSound()
            }

            onHoveredChanged: {
                if(hovered) {
                    sound.playHoverSound()
                }
            }
        }
    }

    Button{
        id: back
        text: I18n.tr("返回", SettingsData.language)
        visible: true
        width: 120*weaponSelectionInterface.scaleFactor
        height: 30*weaponSelectionInterface.scaleFactor
        anchors.top: weaponSelectionInterface.top
        anchors.topMargin: 30*weaponSelectionInterface.scaleFactor
        anchors.left: weaponSelectionInterface.left
        anchors.leftMargin: 30*weaponSelectionInterface.scaleFactor
        background: Rectangle {
            color: back.pressed || back.hovered ? "#cfcfcf" : "#202020"
            radius: 7
        }
        contentItem: ScaledText {
            text: back.text
            basePixelSize: 17
            uiScale: weaponSelectionInterface.scaleFactor
            color: back.pressed || back.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound()
            }
        }
        onClicked: {
            sound.playClickSound()
        }
    }
}
