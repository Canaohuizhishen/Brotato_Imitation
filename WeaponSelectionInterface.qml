import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

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
        selectedWeaponName=""
        weaponCard.weaponName=""
        weaponRow.selectedObjectName=randomSelect.objectName
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#353535"
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
                source: randomSelect.pressed || randomSelect.hovered || weaponRow.selectedObjectName == randomSelect.objectName ? "/images/问号.png" :"/images/问号2.png"
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
            objectName: "冲锋枪"
            Layout.preferredWidth: weaponRow.cellWidth
            Layout.preferredHeight: weaponRow.cellHeight
            background: Rectangle {
                color: wellRounded.pressed || wellRounded.hovered || weaponRow.selectedObjectName == wellRounded.objectName ? "#cfcfcf" : "#222222"
                radius: 4
            }

            Image {
                width: parent.width*0.8
                height: width
                source: wellRounded.pressed || wellRounded.hovered || weaponRow.selectedObjectName == wellRounded.objectName ? "/images/冲锋枪图标.png":"/images/冲锋枪图标2.png"
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
