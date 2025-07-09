import QtQuick
import QtMultimedia
import QtQuick.Controls

Item {
    id: root

    property int fadeDuration: 1500

    property real masterVolume: 1.0 //主音效
    property real musicVolume: 1.0 //音乐
    property real sfxVolume: 1.0 //声音
    function setMasterVolume(volume) {
        masterVolume  = volume
    }
    function setMusicVolume(volume) {
        musicVolume  = volume
    }
    function setSfxVolume(volume) {
        sfxVolume  = volume
    }

    property real mVolume: 0.8 * masterVolume * musicVolume
    property real reducedVolume: 0.4 * masterVolume * musicVolume

    property real sVolume: 0.6 * masterVolume * sfxVolume

    //背景音乐
    MediaPlayer {
        id: backgroundMusic
        audioOutput: AudioOutput {
            id: audioOutput
            volume: mVolume
        }
        loops: MediaPlayer.Infinite
        source: "qrc:/audio/backgroundMusic.mp3"
    }

    Component.onCompleted: {
        playBackgroundMusic()
    }

    NumberAnimation {
        id: volumeAnim
        target: audioOutput
        property: "volume"
        duration: 1500
        easing.type: Easing.InOutQuad
    }


    function fadeIn() {
        volumeAnim.stop()
        volumeAnim.from = audioOutput.volume
        volumeAnim.to = mVolume
        volumeAnim.start()
    }

    function fadeOut() {
        volumeAnim.stop()
        volumeAnim.from = audioOutput.volume
        volumeAnim.to = reducedVolume
        volumeAnim.start()
    }

    function playBackgroundMusic() {
        backgroundMusic.play()
    }

    //悬停音效
    SoundEffect {
        id: hoverSound
        source: "qrc:/audio/hover.wav"
        volume: sVolume
    }
    function playHoverSound() {
        hoverSound.play()
    }

    //悬停音效1
    SoundEffect {
        id: hoverSound1
        source: "qrc:/audio/hover1.wav"
        volume: sVolume
    }
    function playHoverSound1() {
        hoverSound1.play()
    }

    //点击音效
    SoundEffect {
        id: clickSound
        source: "qrc:/audio/click.wav"
        volume: sVolume
    }
    function playClickSound() {
        clickSound.play()
    }

    //回收和合成音效
    SoundEffect {
        id: recyclingAndsynthesizingSound
        source: "qrc:/audio/synthesis.wav"
        volume: sVolume
    }
    function playSynthesizeSound() {
        recyclingAndsynthesizingSound.play()
    }

    //开火音效
    SoundEffect {
        id: fireSound
        source: "qrc:/audio/fire.wav"
        volume: sVolume
    }
    function playFireSound() {
        fireSound.play()
    }

    //材料拾取音效
    SoundEffect {
        id: materialPickingSound
        source: "qrc:/audio/materialPicking.wav"
        volume: sVolume
    }
    function playMaterialPickingSound() {
        materialPickingSound.play()
    }

    //拾取箱子音效
    SoundEffect {
        id: pickBoxSound
        source: "qrc:/audio/pickBox.wav"
        volume: sVolume
    }
    function playPickBoxSound() {
        pickBoxSound.play()
    }

    //升级音效
    SoundEffect {
        id: upgradeSound
        source: "qrc:/audio/upgrade.wav"
        volume: sVolume
    }
    function playUpgradeSound() {
        upgradeSound.play()
    }
}
