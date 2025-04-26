#pragma once

#include <QObject>
#include <QQmlEngine>

class PlayerData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int maxHp READ maxHp WRITE setMaxHp NOTIFY maxHpChanged FINAL)
    Q_PROPERTY(int hp READ hp WRITE setHp NOTIFY hpChanged FINAL)
    Q_PROPERTY(int damage READ damage WRITE setDamage NOTIFY damageChanged FINAL)
    QML_ELEMENT
public:
    explicit PlayerData(QObject *parent = nullptr);

    int maxHp();
    void setMaxHp(int newMaxHp);
    int hp();
    void setHp(int newHp);
    int damage();
    void setDamage(int newDamage);

signals:
    void maxHpChanged();
    void hpChanged();
    void damageChanged();

private:
    int m_maxHp;
    int m_hp;
    int m_damage;
};
