# Brotato — 代码库指南

## 技术栈
- 语言: C++23 + QML (Qt 6.8+) + JavaScript (ECMAScript)
- 构建: CMake 3.31+, 需Qt 6.8, qt_standard_project_setup(REQUIRES 6.8)
- 依赖: Qt 6 Quick 主体；部分组件使用 QtQuick.Shapes 和 QtMultimedia
- 核心依赖: FileManager C++类 (Filemanager.h) 暴露为 com.mygame.utils 1.0 FileManager, JSON存取, 写入前自动.bak备份

## 目录结构
- components/ — 复用QML组件 (条、卡片、按钮、指示器)
- page/ — 全屏页 (开始、角色/武器/难度选择、游戏、商店、升级、宝箱、暂停、结算)
- monsters/ — 怪物/玩家QML组件 (每种敌人单独文件)
- weapons/ — 武器QML组件
- bullets/ — 子弹/投射物QML组件 (静态/移动变体)
- drops/ — 可拾取掉落 (材料、水果、宝箱)
- data/ — 数据/定制核心QML (武器/角色/属性/升级选项核心)
- logic/ — 纯JS逻辑 (ShopLogicHandler.js)
- singleton/ — QML单例 (PlayerData.qml, MonstersData.qml), C++侧 qmlRegisterSingletonType 注册
- `singleton.qrc` — 单例QML资源包（打包 PlayerData.qml, MonstersData.qml）
- sound/ — Sound.qml 音频播放
- audio/ — .wav/.mp3 资源 (audio.qrc打包)
- images/ — .png 资源 (images.qrc打包)
- .qtcreator/ — Qt Creator IDE 配置（仅 .user 文件被 git 忽略）

## 命令
- 构建: cmake -B build && cmake --build build (标准CMake, 无自定义脚本)
- 未见测试/检查/格式化/类型检查器

## 约定
- QML导入: 多数文件使用 QtQuick 2.15, QtQuick.Controls 2.15, QtQuick.Layouts 1.15；部分文件使用无版本导入（如 GoodsCard.qml）
- JavaScript: 工具文件用 .pragma library (tool.js, color.js)
- 模块URI: Brotato (CMake qt_add_qml_module 设定)
- 单例模式: 数据单例由 main.cpp 通过 qmlRegisterSingletonType 注册; QML以 import singleton.PlayerData 导入
- C++→QML桥: FileManager 注册为QML类型; appDataPath 暴露为上下文属性指向存档路径
- 存档: JSON文件位于可执行文件旁 savegames/ 目录; 覆写前写.bak; JSON解析失败自动恢复备份
- 怪物命名: 每种怪物在 monsters/ 下独立文件, 带精灵变体 (*_faceLeft.png, *_faceRight.png, *_mask_*.png, *_redMask_*.png)

## 注意
- build/ 已git忽略 — 始终源外构建
- 无检查/格式化 — 编辑QML注意缩进一致
- `.qrc` 文件（`images.qrc` / `audio.qrc` / `singleton.qrc`）增删资源须同步更新 — CMake 不自动发现
- images/ 含220+ PNG — 直接列目录慢; 用 search_content / search_files 查找资源
