import QtQuick 2.15
import QtQuick.Controls 2.15
import singleton.PlayerData
import "../components"
import "../data"

Rectangle {
    id: root
    anchors.fill: parent
    color: Qt.rgba(0,0,0,0.5)
    property int recwidth : 230
    property int recheight: 160
    property bool isMain :true

    Component.onCompleted: {
        upgradeOptionsRow.addOptions()
        mainAttributes.addAttributes()
        secondaryAttributes.addAttributes()
    }

    onVisibleChanged: {
        refreshButton.count=0
        mainAttributes.model.clear()
        mainAttributes.addAttributes()
        secondaryAttributes.addAttributes()
    }

    // 升级标题
    Text {
        id: upgradeTitle
        text: "升级!"
        font.pixelSize: 30
        width:60
        color: "white"
        anchors.top: parent.top
        anchors.topMargin: 70
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // 升级选项区域
    ListView {
        id: upgradeOptionsRow
        width: 983
        height: 175
        interactive: false
        orientation: ListView.Horizontal
        spacing: 5
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: root.top
        anchors.topMargin: 260
        model: ListModel {}

        // 升级选项组件
        delegate:UpgradeOption {
            required property string name
            required property string upgradeOptionName
            required property string description

            optionName: name
            iconSource: "/images/"+name+".png"
            title: upgradeOptionName
            talentText: description
        }

        function addOptions(){
            var array=core.getOptionRandomly(4)
            for(var i=0;i<array.length;i++){
                model.append({ "name": array[i].objectName, "upgradeOptionName":array[i].optionName , "description": array[i].talentText })
            }
        }

    }

    UpgradeOptionCustomizationCore{
        id:core
    }

    //刷新按钮***********************************************************
    Button {
        id: refreshButton
        //text: "刷新"
        font.pixelSize: 20
        width: 150
        height: 42
        // 使用内置hover属性
        hoverEnabled: true
        background: Rectangle {
            radius: 5
            color: refreshButton.hovered ? "white" : "black"
        }
        anchors.top: upgradeOptionsRow.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: upgradeOptionsRow.horizontalCenter
        property int value: 3+count
        property int count: 0
        onClicked: {
            console.log("刷新")
            //
            count++
            PlayerData.materialsNumber-=value
            upgradeOptionsRow.model.clear()
            upgradeOptionsRow.addOptions()
        }
        Row{
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text:"刷新-"+refreshButton.value
                font.pixelSize: 28
                color: refreshButton.hovered ? "black" : "white"
            }

            Image {
                width: 30
                height:30
                source: "/images/material_icon.png"
            }

        }
    }
    //属性面板***************************************************************
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: upgradeOptionsRow.verticalCenter
        width: 250
        height: 530
        color: "#80000000"
        radius: 10

        // 标题
        Text {
            text: "属性"
            color: "white"
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
        }

        // 按钮容器
        Row {
            id: buttonRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 60
            spacing: 0

            Button {
                width: 105
                height: 32
                text: "主要"
                onClicked: {
                    root.isMain = true
                    mainAttributes.visible = true
                    secondaryAttributes.visible = false
                }
                background: Rectangle{
                    radius: 5
                    visible: !root.isMain
                    color: !parent.hovered&&!root.isMain ? "black" : "white"
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered&&!root.isMain ? "black" : "white"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter

                }

            }

            Button {
                width: 105
                height: 32
                text: "次要"
                onClicked: {
                    root.isMain = false
                    mainAttributes.visible = false
                    secondaryAttributes.visible = true
                }
                background: Rectangle{
                    radius: 5
                    visible: root.isMain
                    color: !parent.hovered&&root.isMain ? "black" : "white"
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered&&root.isMain ? "black" : "white"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        //主要属性*******************************************************
        ListView{
            id: mainAttributes
            interactive: false
            anchors.top: buttonRow.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10
            model: ListModel {
                id: mainattributesModel
            }
            delegate:Attribute{
                required property string name
                required property string value
                required property string imageSource

               attribute: name
               attributevalue: value
               iconSource: imageSource
            }
            function addAttributes(){
                mainattributesModel.append({ "name": "目前等级","value":PlayerData.curLevel ,"imageSource":"/images/upgrade_icon.png"})
                mainattributesModel.append({ "name": "最大生命值","value":PlayerData.maxHp })
                mainattributesModel.append({ "name": "生命再生","value":PlayerData.hpRegeneration })
                mainattributesModel.append({ "name": "%生命窃取","value":PlayerData.lifeSteal })
                mainattributesModel.append({ "name": "%伤害","value":PlayerData.damage })
                mainattributesModel.append({ "name": "近战伤害","value":PlayerData.meleeDamage })
                mainattributesModel.append({ "name": "远程伤害","value":PlayerData.rangedDamage })
                mainattributesModel.append({ "name": "元素伤害","value":PlayerData.elementalDamage })
                mainattributesModel.append({ "name": "%攻击速度","value":PlayerData.attackSpeed })
                mainattributesModel.append({ "name": "%暴击率","value":PlayerData.critChance })
                mainattributesModel.append({ "name": "工程学","value":PlayerData.engineering })
                mainattributesModel.append({ "name": "范围","value":PlayerData.range })
                mainattributesModel.append({ "name": "护甲","value":PlayerData.armor })
                mainattributesModel.append({ "name": "%闪避","value":PlayerData.dodge })
                mainattributesModel.append({ "name": "%速度","value":PlayerData.speed })
                mainattributesModel.append({ "name": "幸运","value":PlayerData.luck })
                mainattributesModel.append({ "name": "收获","value":PlayerData.harvesting })
            }
        }

        //次要属性************************************************************
        ListView{
            id: secondaryAttributes
            interactive: false
            anchors.top: buttonRow.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 5
            visible: false
            model: ListModel{
                id:secondaryAttributesModel

            }
            delegate:Attribute{
                required property string name
                required property string value

               attribute: name
               attributevalue: value
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
}



