cmake_minimum_required(VERSION 3.31)

project(Brotato VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON) # Globally preventing the fallback behaviour of C++ standard

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appBrotato)

qt_add_qml_module(appBrotato
    URI "Brotato"
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES main.cpp
    RESOURCES images.qrc
    QML_FILES tool.js
    RESOURCES singleton.qrc
    RESOURCES data/data.qrc
    QML_FILES components/ExperienceBar.qml
    QML_FILES components/DifficultyCard.qml components/Fork.qml components/HealthBar.qml components/LockCard.qml components/RecardCard.qml components/RoleCard.qml components/WaveCountdown.qml components/WaveNumberText.qml components/WeaponCard.qml
    QML_FILES weapons/SMG.qml
    QML_FILES weapons/Weapons.qml
    QML_FILES monsters/Monsters.qml monsters/Monster.qml
    QML_FILES page/Background.qml page/DifficultySelectionInterface.qml page/GameArea.qml page/GameWindow.qml page/RoleSelectionInterface.qml page/StartInterface.qml page/WeaponSelectionInterface.qml
    QML_FILES monsters/Player.qml
    QML_FILES data/WeaponCustomizationCore.qml data/RoleCustomizationCore.qml
    QML_FILES components/MaterialsBar.qml
    QML_FILES components/BagBar.qml
    QML_FILES monsters/BabyAlien.qml
    QML_FILES monsters/Chaser.qml
    QML_FILES weapons/Weapon.qml
    QML_FILES data/PropCustomizationCore.qml
    QML_FILES components/GoodsCard.qml
    QML_FILES components/UpgradeNotificationBar.qml
    QML_FILES page/UpgradeInterface.qml
    QML_FILES components/UpgradeOption.qml
    QML_FILES monsters/Charger.qml
    QML_FILES data/UpgradeOptionCustomizationCore.qml
    QML_FILES components/Attribute.qml
    QML_FILES components/AttributePanel.qml
    QML_FILES monsters/Sprayer.qml
    QML_FILES monsters/Pursuer.qml
    QML_FILES monsters/Brute.qml
    QML_FILES components/TimerCanPause.qml
    QML_FILES page/StoreInterface.qml
    QML_FILES logic/ShopLogicHandler.js
    QML_FILES logic/DataLoader.js
    QML_FILES components/PropsBar.qml
    QML_FILES components/PropItem.qml
    QML_FILES components/WeaponsBar.qml
    QML_FILES components/WeaponItem.qml
    QML_FILES color.js
    QML_FILES page/PauseInterface.qml
    QML_FILES components/SetButton.qml
    QML_FILES components/SwitchSettingButton.qml
    QML_FILES components/ProgressBarControlButton.qml
    QML_FILES components/ChestNotificationBar.qml
    QML_FILES page/ChestOpeningInterface.qml
    QML_FILES components/PropCard.qml
    QML_FILES page/SettlementInterface.qml
    QML_FILES page/SettingInterface.qml
    QML_FILES components/Forks.qml
    QML_FILES monsters/HelmetAlien.qml
    QML_FILES monsters/Summoner.qml
    QML_FILES monsters/Scavenger.qml
    QML_FILES monsters/HelmetBrute.qml
    QML_FILES monsters/HelmetCharger.qml
    QML_FILES monsters/FinChaser.qml
    QML_FILES monsters/Prayer.qml
    QML_FILES bullets/Bullets.qml bullets/EllipticalMovingBullet.qml bullets/RoundMovingBullet.qml  bullets/RoundStaticBullet.qml
    QML_FILES bullets/Bullet.qml
    QML_FILES bullets/StaticBullet.qml
    QML_FILES bullets/MovingBullet.qml
    QML_FILES weapons/Spear.qml
    QML_FILES bullets/MeleeBullet.qml
    QML_FILES weapons/RangedWeapon.qml
    QML_FILES weapons/MeleeWeapon.qml
    QML_FILES monsters/Tree.qml
    SOURCES Filemanager.h
    QML_FILES page/DyingBorder.qml
    QML_FILES drops/Material.qml drops/Fruit.qml drops/Drops.qml drops/Chest.qml
    RESOURCES audio.qrc
    QML_FILES sound/Sound.qml
)

target_compile_features(appBrotato PRIVATE cxx_std_23)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appBrotato PROPERTIES
    AUTORCC TRUE
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBrotato
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appBrotato
    PRIVATE
        Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appBrotato
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)




























































#qt_add_executable(Brotato)  //Creates and finalizes an application target of a platform-specific type.
#This command performs the following tasks:
#    1. Create a CMake target of the appropriate type for the target platform.
#    2. Link the target to the Qt::Core library.
#    3. Handle finalization of the CMake target.



# qt_standard_project_setup()     #set(CMAKE_AUTOUIC ON)  set(CMAKE_AUTOMOC ON)

# @if %{HasTranslation}
# find_package(Qt6 REQUIRED COMPONENTS Core Quick LinguistTools)
# @else
# find_package(Qt6 REQUIRED COMPONENTS Core Quick)
# @endif

# target_sources(appBrotato
#     PRIVATE
#         main.cpp
#         qml.qrc
#     @if %{HasTranslation}
#         %{TsFileName}
#     @endif
#
#     PUBLIC
#
# )

# qt_import_qml_plugins(Brotato)

















# cmake_minimum_required(VERSION 3.16)
#
# project(Brotato VERSION 0.1 LANGUAGES CXX)
#
# @if !true
# set(CMAKE_AUTOMOC ON)
# @endif
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
#
# find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
#
# @if true
# @if true
# qt_standard_project_setup(REQUIRES 6.5)
# @else
# qt_standard_project_setup()
# @endif
# @endif
#
# qt_add_executable(appBrotato
#     main.cpp
# )
#
# qt_add_qml_module(appBrotato
#     URI Brotato
#     VERSION 1.0
#     QML_FILES Main.qml
# )
#
# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(appBrotato PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBrotato
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )
#
# target_link_libraries(appBrotato
#     PRIVATE Qt6::Quick
# )
#
# include(GNUInstallDirs)
# install(TARGETS appBrotato
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )
