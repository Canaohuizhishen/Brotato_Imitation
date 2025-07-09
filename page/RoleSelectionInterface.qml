pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"
import "../data"

Item {
    id: roleSelectionInterface
    property double scaleFactor: 1.0
    // width: height/0.5625
    // height: parent.height
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100
    property Button backButton: back
    property string selectedRoleName
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
        roleGrid.currentIndex=0
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
        text: "角色选择"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 42*roleSelectionInterface.scaleFactor
        color: "white"
        font.pixelSize: 35*roleSelectionInterface.scaleFactor
        style: Text.Outline
        styleColor: "black"
    }

    RoleCard {
        id: roleCard
        roleName: roleGrid.currentItemIsRole ? roleGrid.currentItem.name : ""
        scaleFactor: roleSelectionInterface.scaleFactor
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 3*roleCard.scaleFactor
    }

    RecardCard {
        id: recardCard
        roleName: roleCard.roleName
        scaleFactor: roleSelectionInterface.scaleFactor
    }

    LockCard {
        id: lockCard
        scaleFactor: roleSelectionInterface.scaleFactor
        visible: roleGrid.currentItem.name==="lock"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    RoleCustomizationCore{
        id: roleCore
    }

    GridView {
        id: roleGrid
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: spacing/2
        anchors.top: roleCard.bottom
        anchors.topMargin: 25*roleSelectionInterface.scaleFactor
        width: cellWidth*17
        height:  cellHeight*3
        property int spacing: 5*roleSelectionInterface.scaleFactor
        cellWidth: 68*roleSelectionInterface.scaleFactor
        cellHeight: cellWidth
        interactive: false
        property int canUsedRoleNumber: roleCore.children.length
        property bool currentItemIsRole: currentItem.name!=="question" && currentItem.name!=="lock"
        model: ListModel{
            Component.onCompleted: {
                for(var i=0;i<roleCore.children.length;i++){
                    var role=roleCore.children[i]
                    append({ name: role.objectName});
                }
                while(roleGrid.count<49){
                    append({ name: "lock"});
                }
            }
            ListElement{ name: "question" }
        }

        delegate: Button {
            required property string name
            required property int index
            width: roleGrid.cellWidth-roleGrid.spacing
            height: width
            background: Rectangle {
                color: pressed || hovered || roleGrid.currentIndex==index ? (name==="lock" ? "#7e7e7e" : "#cfcfcf") : (name==="lock" ? "#292929" : "#222222")
                radius: 4*roleSelectionInterface.scaleFactor
            }
            Image {
                width: parent.width*(name==="lock"||name==="question" ? 0.9 : 1)
                height: width
                source: name==="lock" && (pressed || hovered || roleGrid.currentIndex===index) ? "qrc:/images/icon_lock_white.png" : "qrc:/images/icon_"+name+".png"
                anchors.centerIn: parent
            }
            onClicked: {
                if(name==="question"){
                    roleGrid.currentIndex=Math.floor(Math.random()*roleGrid.canUsedRoleNumber)+1
                }else if(name==="lock"){
                    roleGrid.currentIndex=index
                }else{
                    if(roleGrid.currentIndex === index){
                        roleSelectionInterface.selectedRoleName = name
                        roleSelectionInterface.selected()
                    }else {
                        roleGrid.currentIndex=index
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
        text: "返回"
        visible: true
        width: 120*roleSelectionInterface.scaleFactor
        height: 30*roleSelectionInterface.scaleFactor
        anchors.top: roleSelectionInterface.top
        anchors.topMargin: 30*roleSelectionInterface.scaleFactor
        anchors.left: roleSelectionInterface.left
        anchors.leftMargin: 30*roleSelectionInterface.scaleFactor
        background: Rectangle {
            color: back.pressed || back.hovered ? "#cfcfcf" : "#202020"
            radius: 7
        }
        contentItem: Text {
            text: back.text
            font.pixelSize: 17*roleSelectionInterface.scaleFactor
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
