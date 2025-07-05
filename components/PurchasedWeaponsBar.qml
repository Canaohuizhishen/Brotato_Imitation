import QtQuick 2.15
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData

Item{
    id: root
    width: weaponBar.width
    height: weaponBar.height
    property double scaleFactor: 1.0
    property var purchasedWeaponsModel
    property bool showNumber: true

    Component.onCompleted: {
         // PlayerData.shopContext._purchasedWeaponsModel = purchasedWeaponsModel
    }

    Column{
        id: weaponBar
        width: weaponView.width
        height: weaponText.height+spacing+weaponView.height
        spacing: 20

        Text {
            id: weaponText
            text: "武器" + (root.showNumber ? "(" + Controller.getPurchasedWNum() + "/6)" : "")
            color: "white"
            height: 32* scaleFactor
            font.pixelSize: height
        }

        GridView {
            id: weaponView
            property int columns : 3
            property int spacing : 4*scaleFactor
            property int cellSize : 65*scaleFactor
            anchors.left: weaponText.left
            width: columns * (cellSize + 5*scaleFactor)
            height: 2 * (cellSize + 5*scaleFactor)
            cellWidth: cellSize + 5*scaleFactor
            cellHeight: cellSize + 5*scaleFactor
            model: purchasedWeaponsModel
            interactive: false
            delegate: PurchasedWeaponsImage {
                width: weaponView.cellSize
                height: weaponView.cellSize

                itemData: weaponItem
                wIndex: index
                wGrade: weaponGrade
            }
        }
    }
}
