import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData

Rectangle {
    id: root
    property double scaleFactor: 1.0
    width: 255*root.scaleFactor
    height: autoChangeHight && isMain ? 490*root.scaleFactor : 520*root.scaleFactor
    color: Qt.rgba(0,0,0,0.4)
    radius: 7*root.scaleFactor
    property bool isMain: true
    property bool inLeft: true
    property bool autoChangeHight: false

    Component.onCompleted: {
        mainAttributes.addAttributes()
        secondaryAttributes.addAttributes()
    }

    onVisibleChanged: {
        upData()
    }

    function upData(){
        mainAttributes.clear()
        mainAttributes.addAttributes()
        secondaryAttributes.clear()
        secondaryAttributes.addAttributes()
    }

    Text {
        text: "属性"
        color: "white"
        font.pixelSize: 29*root.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14*root.scaleFactor
    }

    Button {
        id: mainButton
        width: 105*root.scaleFactor
        height: 32*root.scaleFactor
        anchors.right: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 65*root.scaleFactor
        text: "主要"
        onClicked: {
            root.isMain = true
            mainAttributes.visible = true
            secondaryAttributes.visible = false
            sound.playClickSound()
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
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
    }

    Button {
        id: minorButton
        width: 105*root.scaleFactor
        height: 32*root.scaleFactor
        anchors.left: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 65*root.scaleFactor
        text: "次要"
        onClicked: {
            root.isMain = false
            mainAttributes.visible = false
            secondaryAttributes.visible = true
            sound.playClickSound()
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
            verticalAlignment: Text.AlignVCenter
        }

        onHoveredChanged: {
            if(hovered) {
                sound.playHoverSound1()
            }
        }
    }

    Item{
        id: mainAttributes
        width: root.width*0.9
        anchors.top: root.top
        anchors.topMargin: 108*root.scaleFactor
        anchors.bottom: root.bottom
        anchors.horizontalCenter: root.horizontalCenter

        Attribute{
            id: levelAttribute
            width: parent.width
            anchors.top: mainAttributes.top
            anchors.horizontalCenter: mainAttributes.horizontalCenter
            scaleFactor: root.scaleFactor
            attribute: "目前等级"
            attributeValue: PlayerData.curLevel
            iconSource: "qrc:/images/upgrade_icon.png"
        }

        ListView{
            id: mainAttributesList
            width: mainAttributes.width
            height: root.height-20*root.scaleFactor
            interactive: false
            anchors.top: mainAttributes.top
            anchors.topMargin: 35*root.scaleFactor
            anchors.horizontalCenter: mainAttributes.horizontalCenter
            spacing: 5*root.scaleFactor
            model: ListModel {
                id: mainattributesModel
            }
            delegate: Attribute{
                required property string name
                required property string value
                required property string imageSource
                required property string imageSource2
                required property string detail
                required property int index

                width: mainAttributes.width
                scaleFactor: root.scaleFactor
                attribute: name
                attributeValue: value
                iconSource: imageSource
                detailImage:imageSource2
                detailDescription:detail
                inUp: index>mainAttributesList.model.count-7 ? true: false
                inLeft: root.inLeft
            }
            onVisibleChanged: {
                model.clear()
                addAttributes()
            }
            function addAttributes(){
                mainattributesModel.append({ "name": "最大生命值","value":PlayerData.maxHp ,"imageSource":"/images/attribute-maxHp.png",imageSource2:"/images/heart.png","detail":"你可承受的伤害不能超过"+PlayerData.maxHp})
                mainattributesModel.append({ "name": "生命再生","value":PlayerData.hpRegeneration, "imageSource":"/images/attribute-hpRegeneration.png",imageSource2:"/images/lung.png","detail":"每隔"+(1/PlayerData.hpRegenerationPerSecond()).toFixed(2)+"秒，你恢复1点生命值("+PlayerData.hpRegenerationPerSecond().toFixed(2)+"点生命值/秒"})
                mainattributesModel.append({ "name": "%生命窃取","value":PlayerData.lifeSteal , "imageSource":"/images/attribute-lifeSteal.png",imageSource2:"/images/teeth.png","detail":"你的攻击有"+PlayerData.lifeSteal+"%概率为自己恢复1生命值。上限：10生命值/秒"})
                mainattributesModel.append({ "name": "%伤害","value":PlayerData.damage , "imageSource":"/images/attribute-damage.png",imageSource2:"/images/triceps.png","detail":"你的攻击造成的伤害"+PlayerData.damage+"%"})
                mainattributesModel.append({ "name": "近战伤害","value":PlayerData.meleeDamage, "imageSource":"/images/attribute-meleeDamage.png" ,imageSource2:"/images/foream.png","detail":"你的近战攻击造成的伤害"+PlayerData.meleeDamage})
                mainattributesModel.append({ "name": "远程伤害","value":PlayerData.rangedDamage , "imageSource":"/images/attribute-rangedDamage.png",imageSource2:"/images/shoulder.png","detail":"你的远战攻击造成的伤害"+PlayerData.rangedDamage})
                mainattributesModel.append({ "name": "元素伤害","value":PlayerData.elementalDamage, "imageSource":"/images/attribute-elementalDamage.png" ,imageSource2:"/images/brain.png","detail":"元素伤害增加"+PlayerData.elementalDamage})
                mainattributesModel.append({ "name": "%攻击速度","value":PlayerData.attackSpeed , "imageSource":"/images/attribute-attackSpeed.png",imageSource2:"/images/reflexes.png","detail":"攻击速度提高"+PlayerData.attackSpeed+",同样适用于远战武器"})
                mainattributesModel.append({ "name": "%暴击率","value":PlayerData.critChance, "imageSource":"/images/attribute-critChance.png",imageSource2:"/images/finger.png","detail":"你的攻击有"+PlayerData.critChance+"%概率造成更多伤害"})
                mainattributesModel.append({ "name": "工程学","value":PlayerData.engineering,"imageSource":"/images/attribute-engineering.png" ,imageSource2:"/images/skull.png","detail":"增强构筑物的力量。除次要属性外的其他主要属性皆不会影响构筑物。(例如贯通,反弹，爆炸等)"})
                mainattributesModel.append({ "name": "范围","value":PlayerData.range ,"imageSource":"/images/attribute-range.png",imageSource2:"/images/eyes.png","detail":"你的武器最大射程增加"+PlayerData.range+"，对近战武器的效果减半。攻击范围变大也会延长近战武器的冷却时间（移动距离增长）"})
                mainattributesModel.append({ "name": "护甲","value":PlayerData.armor ,"imageSource":"/images/attribute-armor.png",imageSource2:"/images/chest.png","detail":"你受到的伤害减少"+PlayerData.damageReduction()*100+"%"})
                mainattributesModel.append({ "name": "%闪避","value":PlayerData.dodge ,"imageSource":"/images/attribute-dodge.png",imageSource2:"/images/back.png","detail":"你有"+PlayerData.dodge+"%的概率闪避攻击。上限：60%"})
                mainattributesModel.append({ "name": "%速度","value":PlayerData.speed ,"imageSource":"/images/attribute-speed.png",imageSource2:"/images/leg.png","detail":"移速提高"+PlayerData.speed+"%"})
                mainattributesModel.append({ "name": "幸运","value":PlayerData.luck ,"imageSource":"/images/attribute-luck.png",imageSource2:"/images/nose.png","detail":"击杀敌人发现道具或消耗品的概率提高"+PlayerData.luck+"%。此外，提高商店中道具的品级和等级提升"})
                mainattributesModel.append({ "name": "收获","value":PlayerData.harvesting ,"imageSource":"/images/attribute-harvesting.png",imageSource2:"/images/hand.png","detail":"敌袭结束后获得"+PlayerData.harvesting+"材料和XP。每次发动时增加5%直至第20波敌袭，随后减低至20%"})
            }
        }
        function clear(){mainAttributesList.model.clear()}
        function addAttributes(){mainAttributesList.addAttributes()}
    }

    ListView{
        id: secondaryAttributes
        width: root.width*0.9
        interactive: false
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.topMargin: 108*root.scaleFactor
        anchors.horizontalCenter: root.horizontalCenter
        spacing: 4*root.scaleFactor
        visible: false
        model: ListModel{
            id:secondaryAttributesModel

        }
        delegate:Attribute{
            required property string name
            required property string value

            width: secondaryAttributes.width
            scaleFactor: root.scaleFactor
            attribute: name
            attributeValue: value
        }
        onVisibleChanged: {
            model.clear()
            addAttributes()
        }
        function clear(){secondaryAttributes.model.clear()}
        function addAttributes(){
            secondaryAttributesModel.clear();
            secondaryAttributesModel.append({ "name": "消耗性治疗","value":PlayerData.consumptiveTherapy})
            secondaryAttributesModel.append({ "name": "%材料治疗","value":PlayerData.materialTherapy })
            secondaryAttributesModel.append({ "name": "获得%经验","value":PlayerData.gainExperience })
            secondaryAttributesModel.append({ "name": "%拾取范围","value":PlayerData.pickingRegion })
            secondaryAttributesModel.append({ "name": "%道具价格","value":PlayerData.propPrices })
            secondaryAttributesModel.append({ "name": "%爆炸伤害","value":PlayerData.explosiveDamage })
            secondaryAttributesModel.append({ "name": "%爆炸范围","value":PlayerData.explosionRange })
            secondaryAttributesModel.append({ "name": "反弹","value":PlayerData.rebound })
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
