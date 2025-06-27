import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Brotato

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 720
    title: "土豆兄弟(Brotato)(仿)"
    color: "black"

    Component.onCompleted:{
    }

    GameWindow{
        id: gameWindow
        width: window.width/window.height > 1.7777 ? window.height*1.7777 : window.width
        height: window.width/window.height > 1.7777 ? window.height : gameWindow.width/1.7777
    }
}
