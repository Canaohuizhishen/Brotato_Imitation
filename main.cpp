#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Filemanager.h"
//#include "monsterData.h"
//#include "playerData.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.addImportPath("/usr/lib/qt/qml/Qt/labs/");

    qmlRegisterType<FileManager>("com.mygame.utils", 1, 0, "FileManager");

    // 暴露安全的应用路径
    engine.rootContext()->setContextProperty("appDataPath",
                                             QDir::cleanPath(QCoreApplication::applicationDirPath() + "/savegames/"));

    // 确保保存目录存在
    QDir saveDir(QCoreApplication::applicationDirPath() + "/savegames/");
    if (!saveDir.exists() && !saveDir.mkpath(".")) { qFatal("无法创建保存目录！"); }

    qmlRegisterSingletonType(QUrl("qrc:/singleton/PlayerData.qml"),
                             "singleton.PlayerData", // 模块名
                             1,                      // 主版本号
                             0,                      // 次版本号
                             "PlayerData");          // QML 中使用的类型名
    qmlRegisterSingletonType(QUrl("qrc:/singleton/MonstersData.qml"),
                             "singleton.MonstersData", // 模块名
                             1,                        // 主版本号
                             0,                        // 次版本号
                             "MonstersData");          // QML 中使用的类型名

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
