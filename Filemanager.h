#pragma once
#include <QObject>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QDebug>

class FileManager : public QObject
{
    Q_OBJECT
public:
    explicit FileManager(QObject *parent = nullptr) : QObject(parent) {}

    // 基础保存功能（带自动备份）
    Q_INVOKABLE bool saveGameData(const QString &filePath, const QJsonObject &data)
    {
        // 创建备份
        const QString backupPath = filePath + ".bak";
        QFile::remove(backupPath);
        QFile::copy(filePath, backupPath);

        // 写入新数据
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qWarning() << "保存失败：无法打开文件" << filePath;
            return false;
        }

        QJsonDocument doc(data);
        file.write(doc.toJson(QJsonDocument::Indented));

        if (file.error() != QFile::NoError) {
            qWarning() << "文件写入错误：" << file.errorString();
            return false;
        }

        qDebug() << "游戏数据已保存至：" << filePath;
        return true;
    }

    // 基础加载功能
    Q_INVOKABLE QJsonObject loadGameData(const QString &filePath)
    {
        QFile file(filePath);
        if (!file.exists()) {
            qWarning() << "存档文件不存在：" << filePath;
            return QJsonObject();
        }

        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "加载失败：无法打开文件" << filePath;
            return QJsonObject();
        }

        QByteArray rawData = file.readAll();
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(rawData, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            qWarning() << "JSON解析错误，正在恢复备份...";
            QFile::remove(filePath);
            QFile::copy(filePath + ".bak", filePath);
            return QJsonObject();
        }

        if (!doc.isObject()) {
            qWarning() << "存档数据格式无效";
            return QJsonObject();
        }

        return doc.object();
    }
};
