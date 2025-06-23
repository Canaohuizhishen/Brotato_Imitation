import QtQuick
import QtQuick.Controls

//道具栏
Rectangle {

    Text {
        id: propText
        text: "道具"
        color: "white"
        font.pixelSize: 32
    }

    //已经购买了的道具不重复
    ListModel {
        id: purchasedPropsModel
    }

    //将重复道具合并
    ListModel {
        id: duplicatePropsCountModel
    }

    Component.onCompleted: {
        shopscreen.shopContext._purchasedPropsModel = purchasedPropsModel
        shopscreen.shopContext._duplicatePropsCountModel = duplicatePropsCountModel
    }

    GridView {
        id: propBar

        // 参数配置
        property int columns : 8
        property int spacing : 4
        property int cellSize : 63

        anchors.top: propText.bottom
        anchors.topMargin: 5
        anchors.left: propText.left

        width: 8 * (cellSize + 5) + 10
        height: 2 * (cellSize + 5)
        cellWidth: cellSize + 5
        cellHeight: cellSize + 5

        model: duplicatePropsCountModel

        interactive: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 12
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        delegate: PurchasedPropsImage {
            id: propCard
            width: propBar.cellSize
            height: propBar.cellSize

            itemData: propItem
            propNum: count
        }
    }

}
