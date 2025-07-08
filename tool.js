.pragma library

function getDistance(p1,p2){
    var dx=p1.x-p2.x
    var dy=p1.y-p2.y
    return Math.sqrt(dx*dx+dy*dy)
}

function reduceAbs(n,reduction){
    if(n>0)return n-Math.abs(reduction)
    else return n+Math.abs(reduction)
}

function getQuadrant(angle){
    while(angle<0)angle+=360
    if(angle%360<90)return 1
    else if(angle%360<180)return 2
    else if(angle%360<270)return 3
    else return 4
}

function approximatelyEqual(a, b, epsilon = 1e-6) {
    return Math.abs(a - b) < epsilon;
}

function getMirrorX(x,targetX){
    var newX=x+(targetX-x)*2
    return newX
}

function createText(parent, text, size, color, _x, _y, duration=600, OutlineColor="black") {
    var component = Qt.createQmlObject(
                `import QtQuick 2.15;
                Text {
                    id: textEffect
                    x: ${_x}
                    y: ${_y}
                    text: "${text}"
                    color: "${color}"
                    font.pixelSize: Math.floor(${size})
                    font.bold: true
                    style: Text.Outline
                    styleColor: "${OutlineColor}"
                    z: 100

                    SequentialAnimation {
                        loops: 1
                        running: true
                        OpacityAnimator {
                            target: textEffect
                            from: 0
                            to: 0.8
                            duration: ${duration/2}
                        }
                        OpacityAnimator {
                            target: textEffect
                            from: 0.8
                            to: 0
                            duration: ${duration/2}
                        }
                        onStopped: textEffect.destroy()
                    }
                }`,
                parent,
                "dynamicText"
                )
}
