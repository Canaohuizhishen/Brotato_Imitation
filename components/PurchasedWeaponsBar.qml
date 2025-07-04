import QtQuick 2.15
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData

Rectangle {
    property double scaleFactor: 1.0
    property var purchasedWeaponsModel

    Component.onCompleted: {
         // PlayerData.shopContext._purchasedWeaponsModel = purchasedWeaponsModel
    }

    Text {
        id: weaponText
        text: "武器(" + Controller.getPurchasedWNum() + "/6)"
        color: "white"
        font.pixelSize: 32* scaleFactor
        // anchors.left: parent.left
    }

    // ListModel {
    //     id: purchasedWeaponsModel
    //     Component.onCompleted: {
    //                 for (var i = 0; i < PlayerData.shopContext._purchasedWeaponsModel.count; i++) {
    //                     append(PlayerData.shopContext._purchasedWeaponsModel.get(i))
    //                 }
    //             }
    // }

    GridView {
        id: weaponBar

        property int columns : 3
        property int spacing : 4*scaleFactor
        property int cellSize : 63*scaleFactor

        anchors.top: weaponText.bottom
        anchors.topMargin: 5* scaleFactor
        anchors.left: weaponText.left
        // anchors.right: rightPanel.left
        // anchors.rightMargin: 15

        width: columns * (cellSize + 5*scaleFactor)
        height: 2 * (cellSize + 5*scaleFactor)
        cellWidth: cellSize + 5*scaleFactor
        cellHeight: cellSize + 5*scaleFactor

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
