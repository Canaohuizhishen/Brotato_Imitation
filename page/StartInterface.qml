import QtQuick 2.15
import QtQuick.Controls 2.15

Item{
    id: startInterface
    property double scaleFactor: 1.0
    // width: height/0.5625
    // height: parent.height
    anchors.fill: parent
    anchors.centerIn: parent
    z: 100

    property Button resumeButton: resume
    property Button startButton: start
    property Button settingButton: setting
    property Button exitButton: exit

    Image {
        id: startImage
        source: "/images/startInterface3.png"
        width: parent.width
        height: parent.height
    }

    Button{
        id: resume
        text: "继续"
        width: startInterface.width/15
        height: startInterface.height/15
        visible: false
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*13/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: resume.pressed || resume.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: Text {
            text: resume.text
            font.pixelSize: 23*startInterface.scaleFactor
            color: resume.pressed || resume.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button{
        id: start
        text: "开始"
        width: startInterface.width/15
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*10/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: start.pressed || start.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: Text {
            text: start.text
            font.pixelSize: 23*startInterface.scaleFactor
            color: start.pressed || start.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button{
        id: setting
        text: "设置"
        width: startInterface.width/15
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*7/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: setting.pressed || setting.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: Text {
            text: setting.text
            font.pixelSize: 23*startInterface.scaleFactor
            color: setting.pressed || setting.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button{
        id: exit
        text: "退出"
        width: startInterface.width/15
        height: startInterface.height/15
        anchors.bottom: startInterface.bottom
        anchors.bottomMargin: startInterface.height*4/32
        anchors.right: startInterface.right
        anchors.rightMargin: startInterface.width/20
        background: Rectangle {
            color: exit.pressed || exit.hovered ? "white" : "black"
            radius: 4
        }
        contentItem: Text {
            text: exit.text
            font.pixelSize: 23*startInterface.scaleFactor
            color: exit.pressed || exit.hovered ? "black" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    function init(){
        visible=false
    }
}
