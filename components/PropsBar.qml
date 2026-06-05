import QtQuick
import QtQuick.Controls
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData
import "../data"
import singleton.SettingsData
import "../data/i18n.js" as I18n

//道具栏
Item {
    id: propsBar
    width: propBar.width
    height: propBar.height
    property double scaleFactor: 1.0
    property int columns: 8 // 默认值
    property bool inUp: true
    property bool inLeft: true

    PropCustomizationCore{
        id: propCore
    }

    Column{
        id: propBar
        width: propView.width
        height: propText.height+spacing+propView.height
        spacing: 20

        Text {
            id: propText
            text: I18n.tr("道具", SettingsData.language)
            color: "white"
            height: 30* scaleFactor
            font.pixelSize: height
        }

        GridView {
            id: propView
            property int columns: propsBar.columns
            property int spacing : 4*propsBar.scaleFactor
            property int cellSize : 65*propsBar.scaleFactor
            anchors.left: propText.left
            width:  columns* (cellSize + 5*propsBar.scaleFactor) + 10*propsBar.scaleFactor
            height: 2 * (cellSize + 5*propsBar.scaleFactor)
            cellWidth: cellSize + 5*propsBar.scaleFactor
            cellHeight: cellSize + 5*propsBar.scaleFactor
            model: PlayerData.props
            interactive: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            delegate: PropItem {
                id: propCard
                scaleFactor: propsBar.scaleFactor
                width: propView.cellSize
                height: propView.cellSize
                itemData: propCore.getProp(itemName)
                itemName: propName
                propNum: number
                inUp: propsBar.inUp
                inLeft: propsBar.inLeft
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
