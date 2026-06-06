import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import singleton.SettingsData
import "../logic/utils/i18n.js" as I18n

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

    // 语言切换时刷新
    Connections {
        target: SettingsData
        function onLanguageChanged() {
            upData()
        }
    }

    function upData(){
        mainAttributes.clear()
        mainAttributes.addAttributes()
        secondaryAttributes.clear()
        secondaryAttributes.addAttributes()
    }

    ScaledText {
        text: I18n.tr("属性", SettingsData.language)
        color: "white"
        basePixelSize: 29
        uiScale: root.scaleFactor
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
        text: I18n.tr("主要", SettingsData.language)
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
        contentItem: ScaledText {
            text: mainButton.text
            color: mainButton.hovered&&!root.isMain ? "black" : "white"
            basePixelSize: 20
            uiScale: root.scaleFactor
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
        text: I18n.tr("次要", SettingsData.language)
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
        contentItem: ScaledText {
            text: minorButton.text
            color: minorButton.hovered&&root.isMain ? "black" : "white"
            basePixelSize: 20
            uiScale: root.scaleFactor
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
            attribute: I18n.tr("目前等级", SettingsData.language)
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
                var lang = SettingsData.language
                mainattributesModel.append({ "name": I18n.tr("最大生命值", lang),"value":PlayerData.maxHp ,"imageSource":"/images/attribute-maxHp.png",imageSource2:"/images/heart.png","detail":I18n.translateRichText("你可承受的伤害不能超过"+PlayerData.maxHp, lang)})
                mainattributesModel.append({ "name": I18n.tr("生命再生", lang),"value":PlayerData.hpRegeneration, "imageSource":"/images/attribute-hpRegeneration.png",imageSource2:"/images/lung.png","detail":I18n.translateRichText("每隔"+(1/PlayerData.hpRegenerationPerSecond()).toFixed(2)+"秒，你恢复1点生命值("+PlayerData.hpRegenerationPerSecond().toFixed(2)+"点生命值/秒", lang)})
                mainattributesModel.append({ "name": I18n.tr("%生命窃取", lang),"value":PlayerData.lifeSteal , "imageSource":"/images/attribute-lifeSteal.png",imageSource2:"/images/teeth.png","detail":I18n.translateRichText("你的攻击有"+PlayerData.lifeSteal+"%概率为自己恢复1生命值。上限：10生命值/秒", lang)})
                mainattributesModel.append({ "name": I18n.tr("%伤害", lang),"value":PlayerData.damage , "imageSource":"/images/attribute-damage.png",imageSource2:"/images/triceps.png","detail":I18n.translateRichText("你的攻击造成的伤害"+PlayerData.damage+"%", lang)})
                mainattributesModel.append({ "name": I18n.tr("近战伤害", lang),"value":PlayerData.meleeDamage, "imageSource":"/images/attribute-meleeDamage.png" ,imageSource2:"/images/foream.png","detail":I18n.translateRichText("你的近战攻击造成的伤害"+PlayerData.meleeDamage, lang)})
                mainattributesModel.append({ "name": I18n.tr("远程伤害", lang),"value":PlayerData.rangedDamage , "imageSource":"/images/attribute-rangedDamage.png",imageSource2:"/images/shoulder.png","detail":I18n.translateRichText("你的远战攻击造成的伤害"+PlayerData.rangedDamage, lang)})
                mainattributesModel.append({ "name": I18n.tr("元素伤害", lang),"value":PlayerData.elementalDamage, "imageSource":"/images/attribute-elementalDamage.png" ,imageSource2:"/images/brain.png","detail":I18n.translateRichText("元素伤害增加"+PlayerData.elementalDamage, lang)})
                mainattributesModel.append({ "name": I18n.tr("%攻击速度", lang),"value":PlayerData.attackSpeed , "imageSource":"/images/attribute-attackSpeed.png",imageSource2:"/images/reflexes.png","detail":I18n.translateRichText("攻击速度提高"+PlayerData.attackSpeed+",同样适用于远战武器", lang)})
                mainattributesModel.append({ "name": I18n.tr("%暴击率", lang),"value":PlayerData.critChance, "imageSource":"/images/attribute-critChance.png",imageSource2:"/images/finger.png","detail":I18n.translateRichText("你的攻击有"+PlayerData.critChance+"%概率造成更多伤害", lang)})
                mainattributesModel.append({ "name": I18n.tr("工程学", lang),"value":PlayerData.engineering,"imageSource":"/images/attribute-engineering.png" ,imageSource2:"/images/skull.png","detail":I18n.translateRichText("增强构筑物的力量。除次要属性外的其他主要属性皆不会影响构筑物。(例如贯通,反弹，爆炸等)", lang)})
                mainattributesModel.append({ "name": I18n.tr("范围", lang),"value":PlayerData.range ,"imageSource":"/images/attribute-range.png",imageSource2:"/images/eyes.png","detail":I18n.translateRichText("你的武器最大射程增加"+PlayerData.range+"，对近战武器的效果减半。攻击范围变大也会延长近战武器的冷却时间（移动距离增长）", lang)})
                mainattributesModel.append({ "name": I18n.tr("护甲", lang),"value":PlayerData.armor ,"imageSource":"/images/attribute-armor.png",imageSource2:"/images/chest.png","detail":I18n.translateRichText("你受到的伤害减少"+PlayerData.damageReduction()*100+"%", lang)})
                mainattributesModel.append({ "name": I18n.tr("%闪避", lang),"value":PlayerData.dodge ,"imageSource":"/images/attribute-dodge.png",imageSource2:"/images/back.png","detail":I18n.translateRichText("你有"+PlayerData.dodge+"%的概率闪避攻击。上限：60%", lang)})
                mainattributesModel.append({ "name": I18n.tr("%速度", lang),"value":PlayerData.speed ,"imageSource":"/images/attribute-speed.png",imageSource2:"/images/leg.png","detail":I18n.translateRichText("移速提高"+PlayerData.speed+"%", lang)})
                mainattributesModel.append({ "name": I18n.tr("幸运", lang),"value":PlayerData.luck ,"imageSource":"/images/attribute-luck.png",imageSource2:"/images/nose.png","detail":I18n.translateRichText("击杀敌人发现道具或消耗品的概率提高"+PlayerData.luck+"%。此外，提高商店中道具的品级和等级提升", lang)})
                mainattributesModel.append({ "name": I18n.tr("收获", lang),"value":PlayerData.harvesting ,"imageSource":"/images/attribute-harvesting.png",imageSource2:"/images/hand.png","detail":I18n.translateRichText("敌袭结束后获得"+PlayerData.harvesting+"材料和XP。每次发动时增加5%直至第20波敌袭，随后减低至20%", lang)})
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
            var lang = SettingsData.language
            secondaryAttributesModel.clear();
            secondaryAttributesModel.append({ "name": I18n.tr("消耗性治疗", lang),"value":PlayerData.consumptiveTherapy})
            secondaryAttributesModel.append({ "name": I18n.tr("%材料治疗", lang),"value":PlayerData.materialTherapy })
            secondaryAttributesModel.append({ "name": I18n.tr("获得%经验", lang),"value":PlayerData.gainExperience })
            secondaryAttributesModel.append({ "name": I18n.tr("%拾取范围", lang),"value":PlayerData.pickingRegion })
            secondaryAttributesModel.append({ "name": I18n.tr("%道具价格", lang),"value":PlayerData.propPrices })
            secondaryAttributesModel.append({ "name": I18n.tr("%爆炸伤害", lang),"value":PlayerData.explosiveDamage })
            secondaryAttributesModel.append({ "name": I18n.tr("%爆炸范围", lang),"value":PlayerData.explosionRange })
            secondaryAttributesModel.append({ "name": I18n.tr("反弹", lang),"value":PlayerData.rebound })
            secondaryAttributesModel.append({ "name": I18n.tr("贯通", lang),"value":PlayerData.penetrate })
            secondaryAttributesModel.append({ "name": I18n.tr("%贯通伤害", lang),"value":PlayerData.penetratingDamage })
            secondaryAttributesModel.append({ "name": I18n.tr("%对BOSS伤害", lang),"value":PlayerData.damageToBoss })
            secondaryAttributesModel.append({ "name": I18n.tr("%燃烧速度", lang),"value":PlayerData.burningRatePercentage })
            secondaryAttributesModel.append({ "name": I18n.tr("燃烧速度", lang),"value":PlayerData.burningRate })
            secondaryAttributesModel.append({ "name": I18n.tr("击退", lang),"value":PlayerData.repel })
            secondaryAttributesModel.append({ "name": I18n.tr("%几率获得双倍材料", lang),"value":PlayerData.obtainingDoubleMaterial })
            secondaryAttributesModel.append({ "name": I18n.tr("箱子里的材料", lang),"value":PlayerData.materialsInTheBox })
            secondaryAttributesModel.append({ "name": I18n.tr("免费刷新", lang),"value":PlayerData.freeRefresh })
            secondaryAttributesModel.append({ "name": I18n.tr("树木", lang),"value":PlayerData.trees })
            secondaryAttributesModel.append({ "name": I18n.tr("%敌人", lang),"value":PlayerData.enemy })
            secondaryAttributesModel.append({ "name": I18n.tr("%敌人速度", lang),"value":PlayerData.enemySpeed })
        }
    }

}
