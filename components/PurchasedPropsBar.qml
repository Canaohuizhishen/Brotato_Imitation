import QtQuick
import QtQuick.Controls
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData
//道具栏
Item {
    id: propsBar
    width: propBar.width
    height: propBar.height
    property double scaleFactor: 1.0
    property var purchasedPropsModel
    property var duplicatePropsCountModel
    // 添加暂停界面专用属性
    property int columns: 8 // 默认值

    onColumnsChanged: updateLayout()

    Component.onCompleted: {
        // // 更新单例中的模型引用
        // PlayerData.shopContext._purchasedPropsModel = purchasedPropsModel
        // PlayerData.shopContext._duplicatePropsCountModel = duplicatePropsCountModel
        // Controller.initPropEffects()
        updateLayout()
    }

    function updateLayout() {
        propView.columns = columns
    }

    Column{
        id: propBar
        width: propView.width
        height: propText.height+spacing+propView.height
        spacing: 20

        Text {
            id: propText
            text: "道具"
            color: "white"
            height: 30* scaleFactor
            font.pixelSize: height
        }

        GridView {
            id: propView
            property int columns: parent.columns
            property int spacing : 4*propsBar.scaleFactor
            property int cellSize : 65*propsBar.scaleFactor
            anchors.left: propText.left
            width:  columns* (cellSize + 5*propsBar.scaleFactor) + 10*propsBar.scaleFactor
            height: 2 * (cellSize + 5*propsBar.scaleFactor)
            cellWidth: cellSize + 5*propsBar.scaleFactor
            cellHeight: cellSize + 5*propsBar.scaleFactor
            model: duplicatePropsCountModel
            interactive: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            delegate: PurchasedPropsImage {
                id: propCard
                width: propView.cellSize
                height: propView.cellSize
                itemData: propItem
                propNum: count
            }
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 11*propsBar.scaleFactor
                height: propView.height
                anchors.top: propView.top
                anchors.right: propView.right
            }
        }
    }
}
