import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData

Rectangle {
    id: root
    property double scaleFactor: 1.0
    property bool isMain :true
    width: 260*root.scaleFactor
    height: 500*root.scaleFactor
    color: "#80000000"
    radius: 10*root.scaleFactor

    Component.onCompleted: {
        mainAttributes.addAttributes()
        secondaryAttributes.addAttributes()
    }

    onVisibleChanged: {
        upData()
    }

    function upData(){
        mainAttributes.model.clear()
        mainAttributes.addAttributes()
        secondaryAttributes.model.clear()
        secondaryAttributes.addAttributes()
    }

    Text {
        text: "属性"
        color: "white"
        font.pixelSize: 24*root.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10*root.scaleFactor
    }

    Button {
        id: mainButton
        width: 105*root.scaleFactor
        height: 32*root.scaleFactor
        anchors.right: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 60*root.scaleFactor
        text: "主要"
        onClicked: {
            root.isMain = true
            mainAttributes.visible = true
            secondaryAttributes.visible = false
        }
        background: Rectangle{
            radius: 5*root.scaleFactor
            visible: !root.isMain
            color: !mainButton.hovered&&!root.isMain ? "black" : "white"
            anchors.fill: parent
        }
        contentItem: Text {
            text: mainButton.text
            color: mainButton.hovered&&!root.isMain ? "black" : "white"
            font.pixelSize: 20*root.scaleFactor
            horizontalAlignment: Text.AlignHCenter

        }

    }

    Button {
        id: minorButton
        width: 105*root.scaleFactor
        height: 32*root.scaleFactor
        anchors.left: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 60*root.scaleFactor
        text: "次要"
        onClicked: {
            root.isMain = false
            mainAttributes.visible = false
            secondaryAttributes.visible = true
        }
        background: Rectangle{
            radius: 5*root.scaleFactor
            visible: root.isMain
            color: !minorButton.hovered&&root.isMain ? "black" : "white"
            anchors.fill: parent
        }
        contentItem: Text {
            text: minorButton.text
            color: minorButton.hovered&&root.isMain ? "black" : "white"
            font.pixelSize: 20*root.scaleFactor
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ListView{
        id: mainAttributes
        interactive: false
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.topMargin: 112*root.scaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        spacing: 10*root.scaleFactor
        model: ListModel {
            id: mainattributesModel
        }
        delegate:Attribute{
            required property string name
            required property string value
            required property string imageSource

            scaleFactor: root.scaleFactor
            attribute: name
            attributeValue: value
            iconSource: imageSource
        }
        onVisibleChanged: {
            model.clear()
            addAttributes()
        }
        function addAttributes(){
            mainattributesModel.append({ "name": "目前等级","value":PlayerData.curLevel ,"imageSource":"/images/upgrade_icon.png"})
            mainattributesModel.append({ "name": "最大生命值","value":PlayerData.maxHp ,"imageSource":"/images/attribute-maxHp.png"})
            mainattributesModel.append({ "name": "生命再生","value":PlayerData.hpRegeneration, "imageSource":"/images/attribute-hpRegeneration.png"})
            mainattributesModel.append({ "name": "%生命窃取","value":PlayerData.lifeSteal , "imageSource":"/images/attribute-lifeSteal.png"})
            mainattributesModel.append({ "name": "%伤害","value":PlayerData.damage , "imageSource":"/images/attribute-damage.png"})
            mainattributesModel.append({ "name": "近战伤害","value":PlayerData.meleeDamage, "imageSource":"/images/attribute-meleeDamage.png" })
            mainattributesModel.append({ "name": "远程伤害","value":PlayerData.rangedDamage , "imageSource":"/images/attribute-rangedDamage.png"})
            mainattributesModel.append({ "name": "元素伤害","value":PlayerData.elementalDamage, "imageSource":"/images/attribute-elementalDamage.png" })
            mainattributesModel.append({ "name": "%攻击速度","value":PlayerData.attackSpeed , "imageSource":"/images/attribute-attackSpeed.png"})
            mainattributesModel.append({ "name": "%暴击率","value":PlayerData.critChance, "imageSource":"/images/attribute-critChance.png"})
            mainattributesModel.append({ "name": "工程学","value":PlayerData.engineering,"imageSource":"/images/attribute-engineering.png" })
            mainattributesModel.append({ "name": "范围","value":PlayerData.range ,"imageSource":"/images/attribute-range.png"})
            mainattributesModel.append({ "name": "护甲","value":PlayerData.armor ,"imageSource":"/images/attribute-armor.png"})
            mainattributesModel.append({ "name": "%闪避","value":PlayerData.dodge ,"imageSource":"/images/attribute-dodge.png"})
            mainattributesModel.append({ "name": "%速度","value":PlayerData.speed ,"imageSource":"/images/attribute-speed.png"})
            mainattributesModel.append({ "name": "幸运","value":PlayerData.luck ,"imageSource":"/images/attribute-luck.png"})
            mainattributesModel.append({ "name": "收获","value":PlayerData.harvesting ,"imageSource":"/images/attribute-harvesting.png"})
        }
    }

    ListView{
        id: secondaryAttributes
        interactive: false
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.topMargin: 112*root.scaleFactor
        anchors.left: root.left
        anchors.right: root.right
        spacing: 5*root.scaleFactor
        visible: false
        model: ListModel{
            id:secondaryAttributesModel

        }
        delegate:Attribute{
            required property string name
            required property string value

            scaleFactor: root.scaleFactor
            attribute: name
            attributeValue: value
        }
        onVisibleChanged: {
            model.clear()
            addAttributes()
        }
        function addAttributes(){
            secondaryAttributesModel.clear();
            secondaryAttributesModel.append({ "name": "消耗性治疗","value":PlayerData.consumptiveTherapy})
            secondaryAttributesModel.append({ "name": "%材料治疗","value":PlayerData.materialTherapy })
            secondaryAttributesModel.append({ "name": "获得%经验","value":PlayerData.gainExperience })
            secondaryAttributesModel.append({ "name": "%拾取范围","value":PlayerData.pickingRegion })
            secondaryAttributesModel.append({ "name": "%道具价格","value":PlayerData.propPrices })
            secondaryAttributesModel.append({ "name": "%爆炸伤害","value":PlayerData.explosiveDamage })
            secondaryAttributesModel.append({ "name": "%爆炸范围","value":PlayerData.explosionRange })
            secondaryAttributesModel.append({ "name": "%反弹","value":PlayerData.rebound })
            secondaryAttributesModel.append({ "name": "贯通","value":PlayerData.penetrate })
            secondaryAttributesModel.append({ "name": "%贯通伤害","value":PlayerData.penetratingDamage })
            secondaryAttributesModel.append({ "name": "%对BOSS伤害","value":PlayerData.damageToBoss })
            secondaryAttributesModel.append({ "name": "%燃烧速度","value":PlayerData.burningRatePercentage })
            secondaryAttributesModel.append({ "name": "燃烧速度","value":PlayerData.burningRate })
            secondaryAttributesModel.append({ "name": "击退","value":PlayerData.repel })
            secondaryAttributesModel.append({ "name": "%几率获得双倍材料","value":PlayerData.obtainingDoubleMaterial })
            secondaryAttributesModel.append({ "name": "箱子里的材料","value":PlayerData.materialsInTheBox })
            secondaryAttributesModel.append({ "name": "免费刷新","value":PlayerData.freeRefresh })
            secondaryAttributesModel.append({ "name": "树木","value":PlayerData.trees })
            secondaryAttributesModel.append({ "name": "%敌人","value":PlayerData.enemy })
            secondaryAttributesModel.append({ "name": "%敌人速度","value":PlayerData.enemySpeed })
        }
    }

}
