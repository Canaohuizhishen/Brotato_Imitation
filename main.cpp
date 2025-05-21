#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
//#include "monsterData.h"
//#include "playerData.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterSingletonType(QUrl("qrc:/singleton/PlayerData.qml"),
                             "singleton.PlayerData", // 模块名
                             1,
                             0,             // 版本号
                             "PlayerData"); // QML 中使用的类型名

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Brotato", "Main");

    // PlayerData player;
    // player.setHp(5);
    // player.setMaxHp(5);
    // engine.rootContext()->setContextProperty("playerData", &player);

    return app.exec();
}
