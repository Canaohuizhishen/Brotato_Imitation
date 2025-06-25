import QtQuick 2.15
import "../logic/ShopLogicHandler.js" as Controller

Rectangle {

    Component.onCompleted: {
        shopscreen.shopContext._purchasedWeaponsModel = purchasedWeaponsModel
    }

    Text {
        id: weaponText
        text: "武器(" + Controller.getPurchasedWNum() + "/6)"
        color: "white"
        font.pixelSize: 32
        // anchors.left: parent.left
    }

    ListModel {
        id: purchasedWeaponsModel
    }

    GridView {
        id: weaponBar

        property int columns : 3
        property int spacing : 4
        property int cellSize : 63

        anchors.top: weaponText.bottom
        anchors.topMargin: 5
        anchors.left: weaponText.left
        // anchors.right: rightPanel.left
        // anchors.rightMargin: 15

        width: 3 * (cellSize + 5)
        height: 2 * (cellSize + 5)
        cellWidth: cellSize + 5
        cellHeight: cellSize + 5

        model: purchasedWeaponsModel

        interactive: false

        delegate: PurchasedWeaponsImage {
            width: weaponBar.cellSize
            height: weaponBar.cellSize

            itemData: weaponItem
            wIndex: index
            wGrade: weaponGrade
        }

    }
}
