// tst_core 主程序：QUICK_TEST_MAIN_WITH_SETUP — 与 app main.cpp 同款注册，
// 使 QML 测试可直接加载真实 singleton（PlayerData / MonstersData）与 FileManager；
// 此前 QUICK_TEST_MAIN 无注册钩子，涉及单例的逻辑只能靠 JS mock。
#include <QtQuickTest>
#include <QQmlEngine>
#include <QQmlContext>
#include <QTemporaryDir>
#include <QUrl>
#include "../Filemanager.h"

class TestSetup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        // appDataPath 指向临时目录：测试读写（settings/savegame.json）落在临时目录，
        // 绝不触碰真实存档
        static QTemporaryDir appDataDir;
        engine->rootContext()->setContextProperty("appDataPath", appDataDir.path());

        // 类型注册是进程级全局的，多次引擎回调只注册一次
        static bool registered = false;
        if (registered) return;
        registered = true;

        qmlRegisterType<FileManager>("com.mygame.utils", 1, 0, "FileManager");

        // 与 app main.cpp 同款单例注册，但走源文件 URL（测试二进制无 qrc）；
        // 路径由 CMake 编译定义注入（BROTATO_SOURCE_DIR），不依赖运行时 cwd
        const QString srcDir = QStringLiteral(BROTATO_SOURCE_DIR);
        qmlRegisterSingletonType(
            QUrl::fromLocalFile(srcDir + "/singleton/PlayerData.qml"), "singleton.PlayerData", 1, 0, "PlayerData");
        qmlRegisterSingletonType(QUrl::fromLocalFile(srcDir + "/singleton/MonstersData.qml"),
                                 "singleton.MonstersData",
                                 1,
                                 0,
                                 "MonstersData");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(tst_core, TestSetup)

#include "main.moc"
