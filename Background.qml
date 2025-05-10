import QtQuick 2.15

Rectangle {
    id: background
    anchors.fill: parent
    color: "#796461"
    focus: false
    property double scaleFactor: 1.0
    property int stoneNum: 100
    property int stoneWidth: 40*scaleFactor
    property int stoneHeight: 40*scaleFactor

    Component.onCompleted: {
        stoneNum=width*height/stoneWidth/stoneHeight*0.12
        createStones()
    }

    function createJaggedEdges(){
        var edgeWidth=100
        var edgeHeight=20
        var widthEdgeNum=background.width/edgeWidth
        var heightEdgeNum=background.height/edgeHeight

        for(var i=0;i<widthEdgeNum;i++){

        }


    }

    function createStones(){
        var stones = []; // 用于存储已生成的石头信息（x, y, width, height）
        var distribution = distributeStones(background.stoneNum);

        for (var i = 0; i < background.stoneNum; i++) {
            var stoneCreated = false;
            while (!stoneCreated) {
                var stoneWidth = background.stoneWidth;
                var stoneHeight = background.stoneHeight;
                var x = Math.random() * (background.width - stoneWidth * 2) + stoneWidth;
                var y = Math.random() * (background.height - stoneHeight * 2) + stoneHeight;

                // 检查新位置是否与已存在的石头重叠
                var overlaps = false;
                for (var j = 0; j < stones.length; j++) {
                    var existingStone = stones[j];
                    if (
                            x < existingStone.x + existingStone.width &&
                            x + stoneWidth > existingStone.x &&
                            y < existingStone.y + existingStone.height &&
                            y + stoneHeight > existingStone.y
                            ) {
                        overlaps = true;
                        break;
                    }
                }

                if (!overlaps) {
                    if(i>distribution.sp3){
                        var stone = Qt.createQmlObject(
                                    `import QtQuick 2.15;
                                    Image {
                                    source: "/images/石头4.png";
                                    width: ${stoneWidth}*parent.scaleFactor;
                                    height: ${stoneHeight}*parent.scaleFactor;
                                    objectName: "stone"
                                    x: ${x}*parent.scaleFactor;
                                    y: ${y}*parent.scaleFactor;
                                    z: 0;
                                    }`,
                                    background,
                                    "dynamicImage" + i
                                    );
                    }else if(i>distribution.sp2){
                        var stone = Qt.createQmlObject(
                                    `import QtQuick 2.15;
                                    Image {
                                    source: "/images/石头3.png";
                                    width: ${stoneWidth}*parent.scaleFactor;
                                    height: ${stoneHeight}*parent.scaleFactor;
                                    objectName: "stone"
                                    x: ${x}*parent.scaleFactor;
                                    y: ${y}*parent.scaleFactor;
                                    z: 0;
                                    }`,
                                    background,
                                    "dynamicImage" + i
                                    );
                    }else if(i>distribution.sp1){
                        var stone = Qt.createQmlObject(
                                    `import QtQuick 2.15;
                                    Image {
                                    source: "/images/石头2.png";
                                    width: ${stoneWidth}*parent.scaleFactor;
                                    height: ${stoneHeight}*parent.scaleFactor;
                                    objectName: "stone"
                                    x: ${x}*parent.scaleFactor;
                                    y: ${y}*parent.scaleFactor;
                                    z: 0;
                                    }`,
                                    background,
                                    "dynamicImage" + i
                                    );
                    }else if(i>0){
                        var stone = Qt.createQmlObject(
                                    `import QtQuick 2.15;
                                    Image {
                                    source: "/images/石头1.png";
                                    width: ${stoneWidth}*parent.scaleFactor;
                                    height: ${stoneHeight}*parent.scaleFactor;
                                    objectName: "stone"
                                    x: ${x}*parent.scaleFactor;
                                    y: ${y}*parent.scaleFactor;
                                    z: 0;
                                    }`,
                                    background,
                                    "dynamicImage" + i
                                    );
                    }
                    stones.push({ x: x, y: y, width: stoneWidth, height: stoneHeight });
                    stoneCreated = true;
                }
            }
        }
    }

    function deleteStones(){
        for(var i=0;i<background.children.length;i++){
            var child=background.children[i]
            if(child.objectName=="stone")child.destroy()
        }
    }

    function distributeStones(num) {
        var split1 = num/4;
        var split2 = num/2;
        var split3 = num*3/4;

        return { sp1: split1, sp2: split2, sp3: split3 };
    }
}
