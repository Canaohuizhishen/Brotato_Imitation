import QtQuick 2.15

Rectangle {
    id: difficultyCard
    property string difficulty
    property double scaleFactor: 1.0
    visible: difficulty != ""
    anchors.top: parent.top
    anchors.topMargin: 110*scaleFactor
    width: 250*scaleFactor
    height: width*1.4359
    color: "black"
    radius: 4

    Rectangle {
        id: difficultyIcon
        width: 68
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 12*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*difficultyCard.scaleFactor
        color: "#444444"
        radius: 4

        Image {
            width: parent.width*0.72
            height: width
            source: difficultyCard.difficulty == "" ? "" : "/images/"+difficultyCard.difficulty+"3.png"
            anchors.centerIn: parent
        }
    }

    Text{
        text: "危险"+difficultyCard.difficulty
        color: "white"
        font.pixelSize: 18*difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: difficultyIcon.width+20*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 12*difficultyCard.scaleFactor
    }

    Text{
        text: "难度"
        color: "#dad2a4"
        font.pixelSize: 15*difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: difficultyIcon.width+20*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 32*difficultyCard.scaleFactor
    }

    TextEdit {
        text: difficultyCard.difficulty=="" ? "" : core.getDifficultyDescription(difficultyCard.difficulty)
        font.pixelSize: 14*difficultyCard.scaleFactor
        readOnly: true
        textFormat: TextEdit.RichText
        width: 200*difficultyCard.scaleFactor
        height: 100*difficultyCard.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 12*difficultyCard.scaleFactor
        anchors.top: parent.top
        anchors.topMargin: difficultyIcon.height+24*difficultyCard.scaleFactor
    }

    Item{
        id: core
        function getDifficultyDescription(n){
            switch(n-'0'){
            case 0: return "<font color='white'>无修改</font>"
            default: return ""
            }
        }
    }
}
