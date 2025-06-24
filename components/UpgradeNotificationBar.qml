pragma ComponentBehavior: Bound
import QtQuick 2.15
import singleton.PlayerData

Item {
    id: upgradeBar
    property int curLevel: PlayerData.curLevel
    property double scaleFactor: 1.0
    width: parent.width
    height: 50*scaleFactor
    anchors.top: parent.top
    anchors.topMargin: 20*scaleFactor
    anchors.right: parent.right
    anchors.rightMargin: 20*scaleFactor
    property alias number: repeater.model

    onCurLevelChanged: {
        if(curLevel!=0)addOne()
    }

    Repeater{
        id: repeater
        model: 0
        delegate: Image{
            required property int index
            source: "/images/upgrade_icon.png"
            width: upgradeBar.height
            height: upgradeBar.height
            anchors.verticalCenter: upgradeBar.verticalCenter
            anchors.right: upgradeBar.right
            anchors.rightMargin: (5*upgradeBar.scaleFactor+width)*index
            opacity: PlayerData.isInCombat ? 0.5 : 1
        }
    }

    function addOne(){
        number++
    }

    function reduceOne(){
        number--
    }

    function init(){
        number=0
    }
}
