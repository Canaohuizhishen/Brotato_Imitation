import QtQuick
import QtQuick.Controls
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData
//道具栏
Rectangle {
    property double scaleFactor: 1.0
    property var purchasedPropsModel
    property var duplicatePropsCountModel
    // 添加暂停界面专用属性
    property int columns: 8// 默认值
    function updateLayout() {
        propBar.columns = columns
    }

    Text {
        id: propText
        text: "道具"
        color: "white"
        font.pixelSize: 32*scaleFactor
    }



    GridView {
        id: propBar

        // 参数配置
        property int columns: parent.columns
        property int spacing : 4*scaleFactor
        property int cellSize : 63*scaleFactor

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
            width: 12*scaleFactor
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
    onColumnsChanged: updateLayout()

    Component.onCompleted: {
        // // 更新单例中的模型引用
        // PlayerData.shopContext._purchasedPropsModel = purchasedPropsModel
        // PlayerData.shopContext._duplicatePropsCountModel = duplicatePropsCountModel
        Controller.initPropEffects()
        updateLayout()
    }

}
