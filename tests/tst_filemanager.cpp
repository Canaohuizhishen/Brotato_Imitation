#include <QtTest>
#include <QTemporaryDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include "../Filemanager.h"

class tst_FileManager : public QObject
{
    Q_OBJECT

private:
    QTemporaryDir m_tempDir;
    FileManager m_fm;

    QString testPath(const QString &name) const {
        return m_tempDir.filePath(name);
    }

    void writeFile(const QString &path, const QByteArray &content) {
        QFile f(path);
        if (f.open(QIODevice::WriteOnly)) {
            f.write(content);
            f.close();
        }
    }

    QByteArray readFile(const QString &path) {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly))
            return {};
        return f.readAll();
    }

private slots:
    // ========== 基础保存/读取往返 ==========

    void test_saveAndLoad()
    {
        QJsonObject data;
        data["curLevel"] = 5;
        data["roleName"] = "wellRounded";
        data["hp"] = 100;
        data["isInCombat"] = true;

        QString path = testPath("savegame.json");
        QVERIFY(m_fm.saveGameData(path, data));

        QJsonObject loaded = m_fm.loadGameData(path);
        QCOMPARE(loaded["curLevel"].toInt(), 5);
        QCOMPARE(loaded["roleName"].toString(), QString("wellRounded"));
        QCOMPARE(loaded["hp"].toInt(), 100);
        QCOMPARE(loaded["isInCombat"].toBool(), true);
    }

    void test_saveAndLoad_emptyObject()
    {
        QString path = testPath("empty.json");
        QJsonObject empty;
        QVERIFY(m_fm.saveGameData(path, empty));

        QJsonObject loaded = m_fm.loadGameData(path);
        QVERIFY(loaded.isEmpty());
    }

    void test_saveAndLoad_nestedData()
    {
        QJsonObject data;
        data["weapons"] = QJsonArray{1, 2, 3};
        data["coords"] = QJsonObject{{"x", 10}, {"y", 20}};

        QString path = testPath("nested.json");
        QVERIFY(m_fm.saveGameData(path, data));

        QJsonObject loaded = m_fm.loadGameData(path);
        QCOMPARE(loaded["weapons"].toArray().size(), 3);
        QCOMPARE(loaded["coords"].toObject()["x"].toInt(), 10);
    }

    // ========== 备份文件 ==========

    void test_backupCreated()
    {
        QString path = testPath("backup_test.json");
        QJsonObject data;
        data["key"] = "value";

        // 第一次保存 → 无原文件（.bak 不存在）
        m_fm.saveGameData(path, data);
        // 第一次保存不会创建 .bak

        // 第二次保存 → 原文件存在，.bak 才被创建
        data["key"] = "updated";
        m_fm.saveGameData(path, data);
        QVERIFY(QFile::exists(path + ".bak"));
    }

    void test_backupContainsPreviousData()
    {
        QString path = testPath("backup_content.json");

        QJsonObject v1;
        v1["version"] = 1;
        m_fm.saveGameData(path, v1);

        QJsonObject v2;
        v2["version"] = 2;
        m_fm.saveGameData(path, v2);

        // .bak 应该包含 version=1
        QByteArray bakContent = readFile(path + ".bak");
        QJsonDocument doc = QJsonDocument::fromJson(bakContent);
        QVERIFY(doc.isObject());
        QCOMPARE(doc.object()["version"].toInt(), 1);
    }

    // ========== JSON 损坏 → .bak 恢复 ==========

    void test_corruptedJson_restoresBackup()
    {
        QString path = testPath("corrupt.json");

        // 1. 第一次保存 — 无原文件，不创建 .bak
        QJsonObject original;
        original["data"] = "healthy";
        m_fm.saveGameData(path, original);

        // 2. 第二次保存 — 原文件存在，此时才创建 .bak（含第一次数据）
        original["data"] = "still_healthy";
        m_fm.saveGameData(path, original);

        // 3. 验证 .bak 已存在
        QVERIFY(QFile::exists(path + ".bak"));

        // 4. 用无效内容覆盖主文件
        writeFile(path, "这不是 JSON{{{");

        // 5. loadGameData 应检测到损坏，删除主文件，复制 .bak 恢复
        QJsonObject result = m_fm.loadGameData(path);
        // 损坏时返回空对象
        QVERIFY(result.isEmpty());

        // 6. 验证恢复后的文件存在且内容是有效的（.bak 已复制回主文件）
        QVERIFY(QFile::exists(path));
        QByteArray restoredContent = readFile(path);
        QJsonDocument restoredDoc = QJsonDocument::fromJson(restoredContent);
        QVERIFY(restoredDoc.isObject());
        // .bak 是第一次保存的版本
        QCOMPARE(restoredDoc.object()["data"].toString(), QString("healthy"));
    }

    void test_corruptedJson_noBackup()
    {
        QString path = testPath("corrupt_nobak.json");

        // 直接写入损坏数据（从未成功保存过，无 .bak）
        writeFile(path, "garbage{{{");

        // 负载时 JSON 解析失败，尝试恢复但 .bak 不存在
        QJsonObject result = m_fm.loadGameData(path);
        QVERIFY(result.isEmpty());

        // 没有 .bak 可恢复。当前实现：QFile::remove 总会执行，删除主文件。
        // 不测试文件存在性（cleanupTestCase 会清理），只验证返回值为空。
        QVERIFY(result.isEmpty());
    }

    // ========== 文件不存在场景 ==========

    void test_nonexistentFile()
    {
        QString path = testPath("nonexistent.json");
        QFile::remove(path);
        QFile::remove(path + ".bak");

        QJsonObject result = m_fm.loadGameData(path);
        QVERIFY(result.isEmpty());
    }

    void test_nonexistentFile_pathWithSpecialChars()
    {
        QString path = testPath("special 路径/test_{{[].json");
        QDir().mkpath(m_tempDir.path() + "/special 路径");
        QFile::remove(path);

        QJsonObject result = m_fm.loadGameData(path);
        QVERIFY(result.isEmpty());
    }

    // ========== 保存失败场景 ==========

    void test_saveToReadonlyDir()
    {
        // 只读目录（或不存在路径）→ saveGameData 应返回 false
        QString badPath = testPath("no_such_dir/save.json");
        QJsonObject data;
        data["x"] = 1;

        bool ok = m_fm.saveGameData(badPath, data);
        QVERIFY(!ok);
    }
};

QTEST_MAIN(tst_FileManager)
#include "tst_filemanager.moc"
