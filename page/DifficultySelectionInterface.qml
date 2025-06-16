import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

Item {
    id: difficultySelectionInterface
    property double scaleFactor: 1.0
    // width: height/0.5625
    // height: parent.height
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100
    property Button backButton: back
    property string selectedRoleName
    property string selectedWeaponName
    property string selectedDifficulty
    signal selected()

    function init(){
        selectedDifficulty=""
        difficultyCard.difficulty=""
        difficultyRow.selectedObjectName=risk0.objectName
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
        text: "难度选择"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 42*difficultySelectionInterface.scaleFactor
        color: "white"
        font.pixelSize: 35*difficultySelectionInterface.scaleFactor
        style: Text.Outline
        styleColor: "black"
    }

    RoleCard{
        id: roleCard
        scaleFactor: difficultySelectionInterface.scaleFactor
        roleName: difficultySelectionInterface.selectedRoleName
        anchors.right: weaponCard.left
        anchors.rightMargin: 6*difficultySelectionInterface.scaleFactor
    }

    WeaponCard{
        id: weaponCard
        scaleFactor: difficultySelectionInterface.scaleFactor
        weaponName: difficultySelectionInterface.selectedWeaponName
        anchors.horizontalCenter: parent.horizontalCenter
    }

    DifficultyCard{
        id: difficultyCard
        //visible: false
        scaleFactor: difficultySelectionInterface.scaleFactor
        //difficulty: difficultySelectionInterface.selectedDifficulty
        anchors.left: weaponCard.right
        anchors.leftMargin: 6*difficultySelectionInterface.scaleFactor
    }

    LockCard{
        id: lockCard
        visible: {
            for(var i=0;i<difficultyRow.children.length;i++){
                if(difficultyRow.children[i].objectName==difficultyRow.selectedObjectName){
                    return difficultyRow.children[i].isLocked
                }
            }
            return false
        }
        anchors.left: weaponCard.right
        anchors.leftMargin: 6*difficultySelectionInterface.scaleFactor
    }

    RowLayout {
        id: difficultyRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 165*difficultySelectionInterface.scaleFactor
        spacing: 5*difficultySelectionInterface.scaleFactor
        property string selectedObjectName
        property  double cellWidth: 60*difficultySelectionInterface.scaleFactor
        property  double cellHeight: cellWidth

        Component.onCompleted: {
            var maxDifficultyNum='0'
            var targetChild
            for(var i=0;i<difficultyRow.children.length;i++){
                if(!difficultyRow.children[i].isLocked && difficultyRow.children[i].objectName[0]>=maxDifficultyNum){
                    targetChild=difficultyRow.children[i]
                    maxDifficultyNum=targetChild.objectName[0]
                }
            }
            targetChild.click()
        }

        Button {
            id: risk0
            objectName: "0"
            property bool isLocked: false
            Layout.preferredWidth: difficultyRow.cellWidth
            Layout.preferredHeight: difficultyRow.cellHeight
            background: Rectangle {
                color: parent.pressed || parent.hovered || difficultyRow.selectedObjectName == parent.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.8
                height: width
                source: parent.pressed || parent.hovered || difficultyRow.selectedObjectName == parent.objectName ? "/images/0.png":"/images/02.png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(difficultyRow.selectedObjectName == objectName){
                    difficultySelectionInterface.selectedDifficulty = difficultyRow.selectedObjectName
                    //console.log(difficultyCard.)
                    difficultySelectionInterface.selected()
                }else {
                    difficultyRow.selectedObjectName = objectName
                    difficultyCard.difficulty = objectName
                }
            }
        }

        Button {
            id: risk1
            objectName: "1"
            property bool isLocked: true
            Layout.preferredWidth: difficultyRow.cellWidth
            Layout.preferredHeight: difficultyRow.cellHeight
            background: Rectangle {
                color: parent.pressed || parent.hovered || difficultyRow.selectedObjectName == parent.objectName ? (parent.isLocked ? "#7e7e7e" :"#cfcfcf") : (parent.isLocked ? "#292929" : "#222222")
                radius: 4
            }

            Image {
                width: parent.width*0.64
                height: width*1.305
                source: parent.pressed || parent.hovered || difficultyRow.selectedObjectName == parent.objectName ? (parent.isLocked ? "/images/lock.png" : "/images/1.png") : (parent.isLocked ? "/images/lock2.png" : "/images/12.png")
                anchors.centerIn: parent
            }

            onClicked: {
                if(isLocked){
                    difficultyRow.selectedObjectName = objectName
                    difficultyCard.difficulty = ""
                }else if(difficultyRow.selectedObjectName == objectName){
                    difficultySelectionInterface.selectedDifficulty = difficultyRow.selectedObjectName
                    difficultySelectionInterface.selected()
                }else {
                    difficultyRow.selectedObjectName = objectName
                    difficultyCard.difficulty = objectName
                }
            }
        }
    }

    Button{
        id: back
        text: "返回"
        visible: true
        width: 120*difficultySelectionInterface.scaleFactor
        height: 30*difficultySelectionInterface.scaleFactor
        anchors.top: difficultySelectionInterface.top
        anchors.topMargin: 30*difficultySelectionInterface.scaleFactor
        anchors.left: difficultySelectionInterface.left
        anchors.leftMargin: 30*difficultySelectionInterface.scaleFactor
        background: Rectangle {
            color: back.pressed || back.hovered ? "#cfcfcf" : "#202020"
            radius: 7
        }
        contentItem: Text {
            text: back.text
            font.pixelSize: 17*difficultySelectionInterface.scaleFactor
            color: back.pressed || back.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
