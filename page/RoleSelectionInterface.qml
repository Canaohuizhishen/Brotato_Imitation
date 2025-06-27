pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"

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

    function init(){
        visible=false
        selectedRoleName=""
        roleCard.roleName=""
        roleGrid.selectedObjectName=randomSelect.objectName
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
        visible: roleGrid.selectedObjectName.substring(0, 4)=="lock"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Grid {
        id: roleGrid
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36*roleSelectionInterface.scaleFactor
        columns: 15
        spacing: 5*roleSelectionInterface.scaleFactor
        property string selectedObjectName: randomSelect.objectName
        property  double cellWidth: 60*roleSelectionInterface.scaleFactor
        property  double cellHeight: cellWidth

        Button {
            id: randomSelect
            objectName: "随机角色"
            width: roleGrid.cellWidth
            height: roleGrid.cellHeight
            background: Rectangle {
                color: randomSelect.pressed || randomSelect.hovered || roleGrid.selectedObjectName == randomSelect.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.64
                height: width*1.3513
                source: randomSelect.pressed || randomSelect.hovered || roleGrid.selectedObjectName == randomSelect.objectName ? "qrc:/images/question_mark.png" :"qrc:/images/question_mark2.png"
                anchors.centerIn: parent
            }

            onClicked: {
                do{
                    var randomObject = roleGrid.children[Math.floor(Math.random()*roleGrid.children.length)]
                }while(randomObject.objectName=="随机角色"|| randomObject.objectName.substring(0, 4)=="lock")
                roleGrid.selectedObjectName = randomObject.objectName
                roleCard.roleName = randomObject.objectName
            }
        }

        Button {
            id: wellRounded
            objectName: "wellRounded"
            width: roleGrid.cellWidth
            height: roleGrid.cellHeight
            background: Rectangle {
                color: wellRounded.pressed || wellRounded.hovered || roleGrid.selectedObjectName == wellRounded.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.78
                height: width*1.158
                source: wellRounded.pressed || wellRounded.hovered || roleGrid.selectedObjectName == wellRounded.objectName ? "qrc:/images/wellRounded_avatar.png":"qrc:/images/wellRounded_avatar2.png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(roleGrid.selectedObjectName == objectName){
                    roleSelectionInterface.selectedRoleName = roleGrid.selectedObjectName
                    roleSelectionInterface.selected()
                }else {
                    roleGrid.selectedObjectName = objectName
                    roleCard.roleName = objectName
                }
            }
        }

        Button {
            id: mutant
            objectName: "mutant"
            width: roleGrid.cellWidth
            height: roleGrid.cellHeight
            background: Rectangle {
                color: mutant.pressed || mutant.hovered || roleGrid.selectedObjectName == mutant.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.8
                height: width*1.13
                source: mutant.pressed || mutant.hovered || roleGrid.selectedObjectName == mutant.objectName ? "qrc:/images/mutant_avatar.png":"qrc:/images/mutant_avatar2.png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(roleGrid.selectedObjectName == objectName){
                    roleSelectionInterface.selectedRoleName = roleGrid.selectedObjectName
                    roleSelectionInterface.selected()
                }else {
                    roleGrid.selectedObjectName = objectName
                    roleCard.roleName = objectName
                }
            }
        }

        Repeater {
            id: locks
            model: 42
            objectName: "locks"
            delegate: Button {
                required property int index
                width: roleGrid.cellWidth
                height: roleGrid.cellHeight
                objectName: "lock" + index
                background: Rectangle {
                    color: parent.pressed || parent.hovered || roleGrid.selectedObjectName == parent.objectName ? "#7e7e7e" : "#292929"
                    radius: 4
                }

                Image {
                    width: parent.width*0.64
                    height: width*1.305
                    //import "./components"
                    source: parent.pressed || parent.hovered || roleGrid.selectedObjectName == parent.objectName ? "qrc:/images/lock.png" : "qrc:/images/lock2.png"
                    anchors.centerIn: parent
                }

                onClicked: {
                    roleGrid.selectedObjectName = objectName
                    roleCard.roleName = ""
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
    }
}
