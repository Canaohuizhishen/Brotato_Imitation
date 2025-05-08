import QtQuick 2.15

Rectangle {
    id: background
    property var target: parent
    width: target.width
    height: target.height
    color: "#796461"
    focus: false
    property int stoneNum: 100
    property int stoneWidth: 40
    property int stoneHeight: 40

    Component.onCompleted: {
        stoneNum=width*height/stoneWidth/stoneHeight*0.12
        createStones()
    }

    onWidthChanged: {
        stoneNum=width*height/stoneWidth/stoneHeight*0.12
        deleteStones()
        createStones()
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
                                    width: ${stoneWidth};
                                    height: ${stoneHeight};
                                    objectName: "stone"
                                    x: ${x};
                                    y: ${y};
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
                                    width: ${stoneWidth};
                                    height: ${stoneHeight};
                                    objectName: "stone"
                                    x: ${x};
                                    y: ${y};
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
                                    width: ${stoneWidth};
                                    height: ${stoneHeight};
                                    objectName: "stone"
                                    x: ${x};
                                    y: ${y};
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
                                    width: ${stoneWidth};
                                    height: ${stoneHeight};
                                    objectName: "stone"
                                    x: ${x};
                                    y: ${y};
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
        // 生成三个随机分割点，范围在 [1, num-1] 之间
        var split1 = Math.floor(Math.random() * (num - 1)) + 1;
        var split2 = Math.floor(Math.random() * (num - 1)) + 1;
        var split3 = Math.floor(Math.random() * (num - 1)) + 1;

        // 对分割点进行排序
        var splits = [split1, split2, split3].sort((a, b) => a - b);

        return { sp1: splits[0], sp2: splits[1], sp3: splits[2] };
    }
}
