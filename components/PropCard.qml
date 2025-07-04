import QtQuick 2.15
import "../data"
import "../color.js" as Color

Item {
    id: propCard
    property string propName
    property var core: propName=="" ? propCore.getProp("斗篷") : propCore.getProp(propName)
    property double scaleFactor: 1.0
    width: 280*propCard.scaleFactor
    height: width*1.35

    PropCustomizationCore{
        id: propCore
    }

    Rectangle{
        id: backGround
        color: Color.getBackgroundColor(core.grade)
        radius: 8*propCard.scaleFactor
        border.color: Color.getBorderColor(core.grade)
        anchors.fill: propCard
    }

    Item {
        id: root
        anchors.fill: parent
        // anchors.top: parent
        anchors.margins: 8*propCard.scaleFactor

        Rectangle {
            id: goodsImageBackground
            width: 80*propCard.scaleFactor
            height: width
            color: Color.getImageBackgroundColor(core.grade)
            anchors.top: parent.top
            anchors.topMargin: 3*propCard.scaleFactor
            anchors.left: parent.left
            anchors.leftMargin: 3*propCard.scaleFactor
            radius: 6*propCard.scaleFactor

            Image {
                id: goodsImage
                source: "qrc:/images/prop-" + core.objectName + ".png"
                width: goodsImageBackground.width
                height: goodsImageBackground.height
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
            }
        }

        Text {
            id: goodsName
            text: core.propName
            color: core.grade === 1 ? "white" : Color.getBorderColor(core.grade)
            font.pixelSize: 25*propCard.scaleFactor
            anchors.left: goodsImageBackground.right
            anchors.leftMargin: 5*propCard.scaleFactor
            anchors.verticalCenter: goodsImageBackground.verticalCenter
        }

        //物品属性
        Text {
            anchors.top: goodsImageBackground.bottom
            anchors.topMargin: 10*propCard.scaleFactor
            anchors.left: goodsImageBackground.left
            text: core.talentText
            font.pixelSize: goodsName.font.pixelSize*0.7
            lineHeight: 1.15
            //font.weight: Font.DemiBold
        }
    }
}
