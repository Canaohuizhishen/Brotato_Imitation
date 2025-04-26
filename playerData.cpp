#include "playerData.h"

PlayerData::PlayerData(QObject *parent) : QObject{parent} {}

int PlayerData::maxHp()
{
    return m_maxHp;
}

void PlayerData::setMaxHp(int newMaxHp)
{
    m_maxHp = newMaxHp;
}

int PlayerData::hp()
{
    return m_hp;
}

void PlayerData::setHp(int newHp)
{
    m_hp = newHp;
}

int PlayerData::damage()
{
    return m_damage;
}

void PlayerData::setDamage(int newDamage)
{
    m_damage = newDamage;
}
