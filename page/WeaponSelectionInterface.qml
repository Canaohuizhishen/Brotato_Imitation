import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

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
        selectedWeaponName=""
        weaponCard.weaponName=""
        weaponRow.selectedObjectName=randomSelect.objectName
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
        scaleFactor: weaponSelectionInterface.scaleFactor
        roleName: weaponSelectionInterface.selectedRoleName
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 3*roleCard.scaleFactor
    }

    WeaponCard{
        id: weaponCard
        scaleFactor: weaponSelectionInterface.scaleFactor
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 3
    }

    RowLayout {
        id: weaponRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 165*weaponSelectionInterface.scaleFactor
        spacing: 5*weaponSelectionInterface.scaleFactor
        property string selectedObjectName: randomSelect.objectName
        property  double cellWidth: 60*weaponSelectionInterface.scaleFactor
        property  double cellHeight: cellWidth

        Button {
            id: randomSelect
            objectName: "随机角色"
            Layout.preferredWidth: weaponRow.cellWidth
            Layout.preferredHeight: weaponRow.cellHeight
            background: Rectangle {
                color: randomSelect.pressed || randomSelect.hovered || weaponRow.selectedObjectName == randomSelect.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.64
                height: width*1.3513
                source: randomSelect.pressed || randomSelect.hovered || weaponRow.selectedObjectName == randomSelect.objectName ? "/images/question_mark.png" :"/images/question_mark2.png"
                anchors.centerIn: parent
            }

            onClicked: {
                do{
                    var randomObject = weaponRow.children[Math.floor(Math.random()*weaponRow.children.length)]
                }while(randomObject.objectName=="随机角色"|| randomObject.objectName.substring(0, 4)=="lock")
                weaponRow.selectedObjectName = randomObject.objectName
                weaponCard.weaponName = randomObject.objectName
            }
        }

        Button {
            id: wellRounded
            objectName: "smg"
            Layout.preferredWidth: weaponRow.cellWidth
            Layout.preferredHeight: weaponRow.cellHeight
            background: Rectangle {
                color: wellRounded.pressed || wellRounded.hovered || weaponRow.selectedObjectName == wellRounded.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width
                height: width
                source: "/images/smg_icon.png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(weaponRow.selectedObjectName == objectName){
                    weaponSelectionInterface.selectedWeaponName = weaponRow.selectedObjectName
                    weaponSelectionInterface.selected()
                }else {
                    weaponRow.selectedObjectName = objectName
                    weaponCard.weaponName = objectName
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
