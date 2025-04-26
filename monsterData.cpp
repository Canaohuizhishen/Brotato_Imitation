#include "monsterData.h"

MonsterData::MonsterData(QObject *parent) : QObject{parent} {}

int MonsterData::maxHp()
{
    return m_maxHp;
}

void MonsterData::setMaxHp(int newMaxHp)
{
    m_maxHp = newMaxHp;
}

int MonsterData::hp()
{
    return m_hp;
}

void MonsterData::setHp(int newHp)
{
    m_hp = newHp;
}

int MonsterData::damage()
{
    return m_damage;
}

void MonsterData::setDamage(int newDamage)
{
    m_damage = newDamage;
}
