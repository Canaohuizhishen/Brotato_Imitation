import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import singleton.PlayerData
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
        visible=false
        selectedRoleName=""
        selectedWeaponName=""
        selectedDifficulty=""
        difficultyRow.currentIndex=0
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
        scaleFactor: difficultySelectionInterface.scaleFactor
        difficulty: difficultyRow.currentItemIsDifficulty ? difficultyRow.currentItem.name : ""
        anchors.left: weaponCard.right
        anchors.leftMargin: 6*difficultySelectionInterface.scaleFactor
    }

    LockCard{
        id: lockCard
        visible: !difficultyRow.currentItemIsDifficulty
        anchors.left: weaponCard.right
        anchors.leftMargin: 6*difficultySelectionInterface.scaleFactor
    }

    GridView {
        id: difficultyRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: spacing/2
        anchors.top: weaponCard.bottom
        anchors.topMargin: 25*difficultySelectionInterface.scaleFactor
        width: cellWidth*5+1
        height:  cellHeight
        property int spacing: 5*difficultySelectionInterface.scaleFactor
        cellWidth: 68*difficultySelectionInterface.scaleFactor
        cellHeight: cellWidth
        interactive: false
        property int canUsedDifficultyNumber: PlayerData.maxDifficultyCompleted+2
        property bool currentItemIsDifficulty: currentItem===null ? false : currentItem.name!=="lock"
        model: ListModel{
            Component.onCompleted: {
                for(var i=0;i<difficultyRow.canUsedDifficultyNumber;i++){
                    append({ name: i.toString()});
                }
                while(difficultyRow.count<5){
                    append({ name: "lock"});
                }
            }
        }

        delegate: Button {
            required property string name
            required property int index
            width: difficultyRow.cellWidth-difficultyRow.spacing
            height: width
            background: Rectangle {
                color: pressed || hovered || difficultyRow.currentIndex===index ? (name==="lock" ? "#7e7e7e" : "#cfcfcf") : (name==="lock" ? "#292929" : "#222222")
                radius: 4*difficultySelectionInterface.scaleFactor
            }
            Image {
                width: parent.width*(name==="lock" ? 0.9 : 1)
                height: width
                source: name==="lock" && (pressed || hovered || difficultyRow.currentIndex===index) ? "/images/icon_lock_white.png" : "/images/icon_"+name+".png"
                anchors.centerIn: parent
            }
            onClicked: {
                if(name==="lock"){
                    difficultyRow.currentIndex=index
                }else {
                    if(difficultyRow.currentIndex === index){
                        difficultySelectionInterface.selectedDifficulty = name
                        difficultySelectionInterface.selected()
                    }else {
                        difficultyRow.currentIndex=index
                    }
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
