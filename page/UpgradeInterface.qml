import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"

Rectangle {
    id: root
    anchors.fill: parent
    color: "#796461"
    property int recwidth : 230
    property int recheight: 160

    // 升级标题
    Text {
        id: upgradeTitle
        text: "升级！"
        font.pixelSize: 24
        color: "white"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
    }

    // 升级选项区域
    Row {
        id: upgradeOptionsRow
        spacing: 5
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: root.top
        anchors.topMargin: 260

        // 升级选项组件
        UpgradeOption {
            iconSource: "/images/leg.png"
            title: "腿"
            valueText: "+3"
            description: "%速度"
        }

        // 胸升级
        UpgradeOption {
            iconSource: "/images/chest.png"
            title: "胸"
            valueText: "+1"
            description: "护甲"
        }

        // 牙齿升级
        UpgradeOption {
            iconSource: "/images/teeth.png"
            title: "牙齿"
            valueText: "+1"
            description: "%生命窃取"
        }

        // 脑升级
        UpgradeOption {
            iconSource: "/images/brain.png"
            title: "脑"
            valueText: "+1"
            description: "元素伤害"
        }
    }

    //刷新按钮***********************************************************
    Button {
        id: refreshButton
        text: "刷新"
        font.pixelSize: 20
        // 使用内置hover属性
        hoverEnabled: true
        background: Rectangle {
            radius: 5
            color: refreshButton.hovered ? "white" : "#000000"
        }
        width: 150
        height: 42
        anchors.top: upgradeOptionsRow.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: upgradeOptionsRow.horizontalCenter
        onHoveredChanged: {
            text.color = hovered ? "white" : "#404040"
            contentItem.color = hovered ? "black" : "white"
        }
        onClicked: {
            console.log("刷新")
            // 这里添加刷新逻辑
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
            spacing: 30

            Button {
                width: 60
                text: "主要"
                onClicked: {
                    mainAttributes.visible = true
                    secondaryAttributes.visible = false
                }
                background: Rectangle{
                    radius: 5
                    color: parent.hovered ? "#80000000" : "white"
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? "white" : "#000000"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                }

            }

            Button {
                width: 60
                text: "次要"
                onClicked: {
                    mainAttributes.visible = false
                    secondaryAttributes.visible = true
                }
                background: Rectangle{
                    radius: 5
                    color: parent.hovered ? "#80000000" : "white"
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? "white" : "#000000"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

    //     Column {
    //         id: mainAttributes
    //         anchors.top: buttonRow.bottom
    //         anchors.topMargin: 20
    //         anchors.left: parent.left
    //         anchors.right: parent.right
    //         spacing: 10
    //         visible: true  // 初始显示主要属性

    //         // 示例属性项*******************************************
    //         MainAttribute{
    //             iconSource: "images/升级.png"
    //             attribute: "目前等级"
    //             value: "1"
    //             fontSize: 15
    //         }

    //         MainAttribute {
    //             iconSource: "images/最大生命值.png"
    //             attribute:"最大生命值"
    //             value: "12"
    //             attributeColor: "#00FF00"
    //             valueColor: "#00FF00"
    //         }

    //         MainAttribute{
    //             attribute: "生命再生"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "%生命窃取"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "%伤害"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "近战伤害"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "远程伤害"
    //             value: "-1"
    //         }

    //         MainAttribute{
    //             attribute: "元素伤害"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "%攻击速度"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "%暴击率"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "工程学"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "范围"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "护甲"
    //             value: "0"
    //         }

    //         MainAttribute{
    //             attribute: "%闪避"
    //             value: "0"
    //         }


    //         MainAttribute{
    //             attribute: "%速度"
    //             value: "1"
    //         }

    //         MainAttribute{
    //             attribute: "幸运"
    //             value: "1"
    //         }

    //         MainAttribute{
    //             attribute: "收获"
    //             value: "0"
    //         }
    //     }



    //     //次要属性************************************************************

    //     Column {
    //         id: secondaryAttributes
    //         anchors.top: buttonRow.bottom
    //         anchors.topMargin: 20
    //         anchors.left: parent.left
    //         anchors.right: parent.right
    //         spacing: 10
    //         visible: false

    //         SecondaryAttribute{
    //             attribute: "消耗性治疗"

    //         }
    //         SecondaryAttribute{
    //             attribute: "%材料治疗"

    //         }

    //         SecondaryAttribute{
    //             attribute: "获得%经验"

    //         }

    //         SecondaryAttribute{
    //             attribute: "%拾取范围"

    //         }
    //         SecondaryAttribute{
    //             attribute: "%道具价格"

    //         }
    //         SecondaryAttribute{
    //             attribute: "%爆炸伤害"

    //         }
    //         SecondaryAttribute{
    //             attribute: "%爆炸范围"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%反弹"
    //         }
    //         SecondaryAttribute{
    //             attribute: "贯通"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%贯通伤害"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%对BOSS伤害"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%燃烧速度"
    //         }
    //         SecondaryAttribute{
    //             attribute: "燃烧速度"
    //         }
    //         SecondaryAttribute{
    //             attribute: "击退"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%几率获得双倍材料"
    //         }
    //         SecondaryAttribute{
    //             attribute: "箱子里的材料"
    //         }
    //         SecondaryAttribute{
    //             attribute: "免费刷新"
    //         }
    //         SecondaryAttribute{
    //             attribute: "树木"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%敌人"
    //         }
    //         SecondaryAttribute{
    //             attribute: "%敌人速度"
    //         }
    //     }
    // }

}
}



