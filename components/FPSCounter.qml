import QtQuick 2.15

Text {
    id: fpsCounter

    property var gameLoop: null
    property int smoothedFPS: 0

    // 平滑参数
    property double _alpha: 0.05
    property double _instantFPS: 0

    color: smoothedFPS >= 55 ? "#4f4" : (smoothedFPS >= 30 ? "#ff4" : "#f44")
    font.pixelSize: 14
    font.bold: true
    text: smoothedFPS + " FPS"
    z: 1000

    Timer {
        id: refreshTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (fpsCounter.gameLoop && fpsCounter.gameLoop.realDeltaTime > 0) {
                _instantFPS = 1.0 / fpsCounter.gameLoop.realDeltaTime
                if (smoothedFPS === 0) {
                    smoothedFPS = Math.round(_instantFPS)
                } else {
                    smoothedFPS = Math.round(smoothedFPS * (1 - _alpha) + _instantFPS * _alpha)
                }
            }
        }
    }
}
