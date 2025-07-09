import QtQuick 2.15
import "../logic/ShopLogicHandler.js" as Controller
import singleton.PlayerData
import "../data"

Item{
    id: root
    width: weaponBar.width
    height: weaponBar.height
    property double scaleFactor: 1.0
    // property var purchasedWeaponsModel
    property int columns: 3
    property bool showNumber: true
    property bool showButton: true
    property bool inUp: true
    property bool inLeft: true

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
            height: 30* scaleFactor
            font.pixelSize: height
        }

        WeaponCustomizationCore {
            id: weaponCore
        }

        GridView {
            id: weaponView
            property int columns: root.columns
            property int spacing: 4*scaleFactor
            property int cellSize: 65*scaleFactor
            anchors.left: weaponText.left
            width: columns * (cellSize + 5*scaleFactor)
            height: Math.max(Math.ceil(model.count/columns),1) * (cellSize + 5*scaleFactor)
            cellWidth: cellSize + 5*scaleFactor
            cellHeight: cellSize + 5*scaleFactor
            // model: purchasedWeaponsModel
            model: PlayerData.weapons
            interactive: false
            delegate: WeaponItem {
                scaleFactor: root.scaleFactor
                width: weaponView.cellSize
                height: weaponView.cellSize
                itemData: weaponCore.getWeapon(itemName,grade)
                itemName: weaponName
                wIndex: index
                wGrade: grade
                showButton: root.showButton
                inUp: root.inUp
                inLeft: root.inLeft
            }
        }
    }
}
