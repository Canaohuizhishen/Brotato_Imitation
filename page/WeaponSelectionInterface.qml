import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"
import "../data"

Item {
    id: weaponSelectionInterface
    property double scaleFactor: 1.0
    // width: height/0.5625
    // height: parent.height
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100
    property Button backButton: back
    property string selectedRoleName
    property string selectedWeaponName
    signal selected()

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

    Text {
        text: "武器选择"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 42*weaponSelectionInterface.scaleFactor
        color: "white"
        font.pixelSize: 35*weaponSelectionInterface.scaleFactor
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
        width: cellWidth*(canUsedWeaponNumber+1)
        height:  cellHeight
        property int spacing: 5*weaponSelectionInterface.scaleFactor
        cellWidth: 68*weaponSelectionInterface.scaleFactor
        cellHeight: cellWidth
        interactive: false
        property int canUsedWeaponNumber: weaponCore.children.length
        property bool currentItemIsWeapon: currentItem.name!=="question"
        model: ListModel{
            Component.onCompleted: {
                for(var i=0;i<weaponCore.children.length;i++){
                    var weapon=weaponCore.children[i]
                    append({ name: weapon.objectName});
                }
            }
            ListElement{ name: "question" }
        }

        delegate: Button {
            required property string name
            required property int index
            width: weaponRow.cellWidth-weaponRow.spacing
            height: width
            background: Rectangle {
                color: pressed || hovered || weaponRow.currentIndex==index ? "#cfcfcf" : "#222222"
                radius: 4*weaponSelectionInterface.scaleFactor
            }

            Image {
                width: parent.width*(name==="question" ? 0.9 : 1)
                height: width
                source: "/images/icon_"+name+".png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(name==="question"){
                    weaponRow.currentIndex=Math.floor(Math.random()*weaponRow.canUsedWeaponNumber)+1
                }else {
                    if(weaponRow.currentIndex === index){
                        weaponSelectionInterface.selectedWeaponName = name
                        weaponSelectionInterface.selected()
                    }else {
                        weaponRow.currentIndex=index
                    }
                }
            }
        }
    }

    Button{
        id: back
        text: "返回"
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
        contentItem: Text {
            text: back.text
            font.pixelSize: 17*weaponSelectionInterface.scaleFactor
            color: back.pressed || back.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
