.pragma library

/**
 * i18n — 国际化翻译表
 *
 * 支持语言列表（与 SettingInterface 中的 ComboBox 索引一致）：
 *   0=中文  1=繁体中文  2=English  3=Français  4=日本語
 *   5=한국어  6=Русский  7=Polski  8=Español  9=Português
 *   10=Deutsch  11=Türk  12=Italiano
 *
 * 当前仅实现 中文 / English 的常用翻译，其余语言 fallback 到英文。
 * 用法：
 *   import "../logic/utils/i18n.js" as I18n
 *   I18n.tr("开始游戏")
 */

// 当前语言缓存 — 由 setLanguage() 更新，tr() 无 langIndex 时从此读取
// 替代原来脆弱的 Qt.createQmlObject() 方式（纯 JS 上下文静默失败→永远回退中文）
var _currentLanguage = 0

/**
 * 设置当前语言索引（由 Main.qml 的 Connections 在启动和切换时调用）
 * @param {number} lang - 语言索引（与 ComboBox 一致）
 */
function setLanguage(lang) {
    _currentLanguage = lang
}

// 翻译表：中文 → 各语言映射
// 格式：strings[中文原文] = [zh, zh_TW, en, fr, ja, ko, ru, pl, es, pt, de, tr, it]
var strings = {
    // === 主界面 ===
    "开始游戏":       ["开始游戏", "開始遊戲", "Start", "Démarrer", "開始", "시작", "Начать", "Start", "Iniciar", "Iniciar", "Starten", "Başlat", "Avvia"],
    "角色选择":       ["角色选择", "角色選擇", "Character", "Personnage", "キャラクター", "캐릭터", "Персонаж", "Postać", "Personaje", "Personagem", "Charakter", "Karakter", "Personaggio"],
    "武器选择":       ["武器选择", "武器選擇", "Weapon", "Arme", "武器", "무기", "Оружие", "Broń", "Arma", "Arma", "Waffe", "Silah", "Arma"],
    "难度选择":       ["难度选择", "難度選擇", "Difficulty", "Difficulté", "難易度", "난이도", "Сложность", "Trudność", "Dificultad", "Dificuldade", "Schwierigkeit", "Zorluk", "Difficoltà"],
    "设置":           ["设置", "設置", "Settings", "Paramètres", "設定", "설정", "Настройки", "Ustawienia", "Ajustes", "Configurações", "Einstellungen", "Ayarlar", "Impostazioni"],
    "返回主菜单":     ["返回主菜单", "返回主菜單", "Main Menu", "Menu principal", "メインメニュー", "메인 메뉴", "Главное меню", "Menu główne", "Menú principal", "Menu principal", "Hauptmenü", "Ana Menü", "Menu principale"],

    // === 设置页 ===
    "一般设定":       ["一般设定", "一般設定", "General", "Général", "一般", "일반", "Общие", "Ogólne", "General", "Geral", "Allgemein", "Genel", "Generale"],
    "游戏操作":       ["游戏操作", "遊戲操作", "Controls", "Contrôles", "操作", "조작", "Управление", "Sterowanie", "Controles", "Controles", "Steuerung", "Kontroller", "Controlli"],
    "视频":           ["视频", "視頻", "Video", "Vidéo", "ビデオ", "비디오", "Видео", "Wideo", "Video", "Vídeo", "Video", "Video", "Video"],
    "声音":           ["声音", "聲音", "Audio", "Audio", "オーディオ", "오디오", "Аудио", "Audio", "Audio", "Áudio", "Audio", "Ses", "Audio"],
    "辅助功能":       ["辅助功能", "輔助功能", "Accessibility", "Accessibilité", "アクセシビリティ", "접근성", "Доступность", "Dostępność", "Accesibilidad", "Acessibilidade", "Barrierefreiheit", "Erişilebilirlik", "Accessibilità"],
    "返回":           ["返回", "返回", "Back", "Retour", "戻る", "뒤로", "Назад", "Wstecz", "Volver", "Voltar", "Zurück", "Geri", "Indietro"],
    "重置至默认":     ["重置至默认", "重置至默認", "Reset to Default", "Réinitialiser", "デフォルトに戻す", "기본값 재설정", "Сбросить", "Reset", "Restablecer", "Redefinir", "Zurücksetzen", "Sıfırla", "Ripristina"],

    // === 设置项标签 ===
    "屏幕振动":       ["屏幕振动", "屏幕振動", "Screen Shake", "Secousses écran", "画面振動", "화면 흔들림", "Тряска экрана", "Drganie ekranu", "Sacudida de pantalla", "Tremor de tela", "Bildschirm erschüttern", "Ekran Sallanması", "Scuotimento schermo"],
    "全屏模式":       ["全屏模式", "全屏模式", "Fullscreen", "Plein écran", "フルスクリーン", "전체 화면", "Полный экран", "Pełny ekran", "Pantalla completa", "Tela cheia", "Vollbild", "Tam Ekran", "Schermo intero"],
    "视觉效果":       ["视觉效果", "視覺效果", "Visual Effects", "Effets visuels", "視覚効果", "시각 효과", "Визуальные эффекты", "Efekty wizualne", "Efectos visuales", "Efeitos visuais", "Visuelle Effekte", "Görsel Efektler", "Effetti visivi"],
    "伤害显示":       ["伤害显示", "傷害顯示", "Show Damage", "Dégâts", "ダメージ表示", "피해 표시", "Показывать урон", "Pokaż obrażenia", "Mostrar daño", "Mostrar dano", "Schaden anzeigen", "Hasar Göster", "Mostra danno"],
    "敌袭结束优化":   ["敌袭结束优化", "敵襲結束優化", "End Wave Optimization", "Optimisation fin de vague", "ウェーブ終了最適化", "웨이브 종료 최적화", "Оптимизация конца волны", "Optymalizacja końca fali", "Optimización fin de oleada", "Otimização fim de onda", "Wellenende-Optimierung", "Dalga Sonu Optimizasyonu", "Ottimizzazione fine ondata"],
    "仅限鼠标":       ["仅限鼠标", "僅限滑鼠", "Mouse Only", "Souris seulement", "マウスのみ", "마우스만", "Только мышь", "Tylko mysz", "Solo ratón", "Apenas mouse", "Nur Maus", "Sadece Fare", "Solo mouse"],
    "手动瞄准":       ["手动瞄准", "手動瞄準", "Manual Aim", "Visée manuelle", "手動照準", "수동 조준", "Ручное прицеливание", "Ręczne celowanie", "Apuntería manual", "Mira manual", "Manuelles Zielen", "Manuel Nişan", "Mira manuale"],
    "锁定物品":       ["锁定物品", "鎖定物品", "Lock Items", "Verrouiller objets", "アイテムロック", "아이템 잠금", "Блокировать предметы", "Zablokuj przedmioty", "Bloquear objetos", "Bloquear itens", "Gegenstände sperren", "Eşyaları Kilitle", "Blocca oggetti"],
    "突显角色":       ["突显角色", "突顯角色", "Highlight Character", "Surligner personnage", "キャラクター強調", "캐릭터 강조", "Выделить персонажа", "Podświetl postać", "Resaltar personaje", "Destacar personagem", "Charakter hervorheben", "Karakteri Vurgula", "Evidenzia personaggio"],
    "突显武器":       ["突显武器", "突顯武器", "Highlight Weapon", "Surligner arme", "武器強調", "무기 강조", "Выделить оружие", "Podświetl broń", "Resaltar arma", "Destacar arma", "Waffe hervorheben", "Silahı Vurgula", "Evidenzia arma"],
    "爆炸":           ["爆炸", "爆炸", "Explosion", "Explosion", "爆発", "폭발", "Взрыв", "Eksplozja", "Explosión", "Explosão", "Explosion", "Patlama", "Esplosione"],
    "屏幕变暗":       ["屏幕变暗", "屏幕變暗", "Dim Screen", "Assombrir écran", "画面暗転", "화면 어둡게", "Затемнение экрана", "Przyciemnij ekran", "Oscurecer pantalla", "Escurecer tela", "Bildschirm abdunkeln", "Ekranı Karart", "Schermo scuro"],
    "突显投射物":     ["突显投射物", "突顯投射物", "Highlight Projectiles", "Surligner projectiles", "投射物強調", "투사체 강조", "Выделить снаряды", "Podświetl pociski", "Resaltar proyectiles", "Destacar projéteis", "Projektile hervorheben", "Mermileri Vurgula", "Evidenzia proiettili"],
    "窗口未置于前方时静音":   ["窗口未置于前方时静音", "視窗未置於前方時靜音", "Mute When Unfocused", "Couper le son si inactif", "フォーカス損失時にミュート", "포커스 잃을 때 음소거", "Отключать звук при свертывании", "Wycisz gdy nieaktywne", "Silenciar al perder foco", "Silenciar quando não focado", "Stumm bei Unfokus", "Odaklanınca Sessiz", "Silenzia se inattiva"],
    "窗口未置于前方时暂停":   ["窗口未置于前方时暂停", "視窗未置於前方時暫停", "Pause When Unfocused", "Pause si inactif", "フォーカス損失時に一時停止", "포커스 잃을 때 일시정지", "Пауза при свертывании", "Wstrzymaj gdy nieaktywne", "Pausa al perder foco", "Pausa quando não focado", "Pause bei Unfokus", "Odaklanınca Durdur", "Metti in pausa se inattiva"],
    "—按下鼠标时手动瞄准":   ["—按下鼠标时手动瞄准", "—按下滑鼠時手動瞄準", "Manual Aim on Press", "Visée manuelle au clic", "押下時に手動照準", "누르면 수동 조준", "Ручное прицеливание при нажатии", "Ręczne celowanie przy kliknięciu", "Apuntar manual al presionar", "Mira manual ao pressionar", "Manuelles Zielen bei Druck", "Basınca Manuel Nişan", "Mira manuale alla pressione"],
    "角色头顶显示血条":     ["角色头顶显示血条", "角色頭頂顯示血條", "Show Character Health Bar", "Barre de vie du personnage", "キャラクターHP表示", "캐릭터 체력바 표시", "Показывать полосу здоровья персонажа", "Pasek zdrowia postaci", "Barra de salud del personaje", "Barra de vida do personagem", "Charakter-Leiste anzeigen", "Karakter Can Barını Göster", "Barra salute personaggio"],
    "头目头顶显示血条":     ["头目头顶显示血条", "頭目頭頂顯示血條", "Show Boss Health Bar", "Barre de vie du boss", "ボスHP表示", "보스 체력바 표시", "Показывать полосу здоровья босса", "Pasek zdrowia bossa", "Barra de salud del jefe", "Barra de vida do chefe", "Boss-Leiste anzeigen", "Patron Can Barını Göster", "Barra salute boss"],
    "改变材料的声音":     ["改变材料的声音", "改變材料的聲音", "Material Pickup Sound", "Son de ramassage", "素材取得音", "재료 획득 소리", "Звук подбора материалов", "Dźwięk podnoszenia materiałów", "Sonido de recoger materiales", "Som de coleta de material", "Material-Sammel-Sound", "Malzeme Toplama Sesi", "Suono raccolta materiali"],
    "主音效":         ["主音效", "主音效", "Master Volume", "Volume principal", "マスター音量", "마스터 볼륨", "Основная громкость", "Głośność główna", "Volumen principal", "Volume principal", "Hauptlautstärke", "Ana Ses", "Volume principale"],
    "音效":           ["音效", "音效", "SFX Volume", "Volume SFX", "効果音", "SFX 볼륨", "Громкость эффектов", "Głośność efektów", "Volumen de SFX", "Volume de SFX", "SFX-Lautstärke", "SFX Sesi", "Volume SFX"],
    "音乐":           ["音乐", "音樂", "Music Volume", "Volume musique", "音楽音量", "음악 볼륨", "Громкость музыки", "Głośność muzyki", "Volumen de música", "Volume da música", "Musiklautstärke", "Müzik Sesi", "Volume musica"],
    "敌人生命值":     ["敌人生命值", "敵人生命值", "Enemy HP", "PV ennemis", "敵HP", "적 체력", "Здоровье врагов", "Punkty życia wrogów", "Vida de enemigos", "Vida dos inimigos", "Gegner-Leben", "Düşman Canı", "HP nemici"],
    "敌人伤害":       ["敌人伤害", "敵人傷害", "Enemy Damage", "Dégâts ennemis", "敵ダメージ", "적 대미지", "Урон врагов", "Obrażenia wrogów", "Daño de enemigos", "Dano dos inimigos", "Gegner-Schaden", "Düşman Hasarı", "Danno nemici"],
    "敌人速度":       ["敌人速度", "敵人速度", "Enemy Speed", "Vitesse ennemis", "敵速度", "적 속도", "Скорость врагов", "Prędkość wrogów", "Velocidad de enemigos", "Velocidade dos inimigos", "Gegner-Tempo", "Düşman Hızı", "Velocità nemici"],
    "字体大小":       ["字体大小", "字體大小", "Font Size", "Taille police", "フォントサイズ", "글꼴 크기", "Размер шрифта", "Rozmiar czcionki", "Tamaño de fuente", "Tamanho da fonte", "Schriftgröße", "Yazı Boyutu", "Dimensione carattere"],

    // === 商店 ===
    "刷新":           ["刷新", "刷新", "Refresh", "Actualiser", "更新", "새로고침", "Обновить", "Odśwież", "Actualizar", "Atualizar", "Aktualisieren", "Yenile", "Aggiorna"],
    "锁定":           ["锁定", "鎖定", "Lock", "Verrouiller", "ロック", "잠금", "Блокировать", "Zablokuj", "Bloquear", "Bloquear", "Sperren", "Kilitle", "Blocca"],
    "开始":           ["开始", "開始", "Start", "Commencer", "スタート", "시작", "Начать", "Rozpocznij", "Empezar", "Iniciar", "Starten", "Başlat", "Inizia"],

    // === 暂停/通用 ===
    "继续":           ["继续", "繼續", "Resume", "Reprendre", "続行", "계속", "Продолжить", "Kontynuuj", "Reanudar", "Continuar", "Fortsetzen", "Devam", "Continua"],
    "重新开始":       ["重新开始", "重新開始", "Restart", "Recommencer", "再開", "다시 시작", "Перезапуск", "Restart", "Reiniciar", "Reiniciar", "Neustart", "Yeniden Başla", "Riavvia"],
    "是否返回主菜单?": ["是否返回主菜单?", "是否返回主菜單?", "Return to main menu?", "Retour au menu principal?", "メインメニューに戻る？", "메인 메뉴로 돌아갈까요?", "Вернуться в главное меню?", "Powrót do menu głównego?", "¿Volver al menú principal?", "Voltar ao menu principal?", "Zum Hauptmenü?", "Ana menüye dönülsün mü?", "Tornare al menu principale?"],
    "是":             ["是", "是", "Yes", "Oui", "はい", "예", "Да", "Tak", "Sí", "Sim", "Ja", "Evet", "Sì"],
    "否":             ["否", "否", "No", "Non", "いいえ", "아니오", "Нет", "Nie", "No", "Não", "Nein", "Hayır", "No"],
    "是否重新开始本轮游戏?": ["是否重新开始本轮游戏?", "是否重新開始本輪遊戲?", "Restart this run?", "Recommencer cette partie?", "このゲームを再開する？", "이번 게임을 다시 시작할까요?", "Перезапустить эту игру?", "Zrestartować tę rozgrywkę?", "¿Reiniciar esta partida?", "Reiniciar esta partida?", "Diesen Durchlauf neustarten?", "Bu oyunu yeniden başlat?", "Riavviare questa partita?"],

    // === 宝箱 ===
    "发现道具!":      ["发现道具!", "發現道具!", "Item Found!", "Objet trouvé!", "アイテム発見!", "아이템 발견!", "Предмет найден!", "Przedmiot znaleziony!", "¡Objeto encontrado!", "Item encontrado!", "Gegenstand gefunden!", "Eşya Bulundu!", "Oggetto trovato!"],
    "拿取":           ["拿取", "拿取", "Take", "Prendre", "取る", "획득", "Взять", "Weź", "Tomar", "Pegar", "Nehmen", "Al", "Prendi"],
    "回收":           ["回收", "回收", "Recycle", "Recycler", "リサイクル", "재활용", "Переработать", "Przetwórz", "Reciclar", "Reciclar", "Recyceln", "Geri Dönüştür", "Ricicla"],

    // === 升级 ===
    "升级!":          ["升级!", "升級!", "Level Up!", "Niveau supérieur!", "レベルアップ!", "레벨 업!", "Повышение уровня!", "Poziom wyżej!", "¡Subir de nivel!", "Subiu de nível!", "Aufgestiegen!", "Seviye Atladı!", "Livello su!"],
    "选择":           ["选择", "選擇", "Choose", "Choisir", "選択", "선택", "Выбрать", "Wybierz", "Elegir", "Escolher", "Wählen", "Seç", "Scegli"],

    // === 开始页面 ===
    "退出":           ["退出", "退出", "Quit", "Quitter", "終了", "종료", "Выйти", "Wyjście", "Salir", "Sair", "Beenden", "Çıkış", "Esci"],

    // === 属性面板 ===
    "属性":           ["属性", "屬性", "Stats", "Statistiques", "ステータス", "능력치", "Характеристики", "Statystyki", "Estadísticas", "Estatísticas", "Werte", "İstatistikler", "Statistiche"],
    "主要":           ["主要", "主要", "Primary", "Principal", "主要", "주요", "Основные", "Główne", "Principal", "Principal", "Primär", "Birincil", "Principali"],
    "次要":           ["次要", "次要", "Secondary", "Secondaire", "次要", "보조", "Второстепенные", "Drugorzędne", "Secundario", "Secundário", "Sekundär", "İkincil", "Secondari"],

    // === 武器 ===
    "武器":           ["武器", "武器", "Weapons", "Armes", "武器", "무기", "Оружие", "Broń", "Armas", "Armas", "Waffen", "Silahlar", "Armi"],
    "合成":           ["合成", "合成", "Craft", "Fusionner", "合成", "합성", "Скрафтить", "Wytwórz", "Fusionar", "Fusionar", "Herstellen", "Üret", "Fondi"],
    "回收(+":         ["回收(+", "回收(+", "Recycle(+", "Recycler(+", "リサイクル(+", "재활용(+", "Переработка(+", "Przetwórz(+", "Reciclar(+", "Reciclar(+", "Recyceln(+", "Geri Dönüştür(+", "Ricicla(+"],
    "取消":           ["取消", "取消", "Cancel", "Annuler", "キャンセル", "취소", "Отмена", "Anuluj", "Cancelar", "Cancelar", "Abbrechen", "İptal", "Annulla"],

    // === 角色/难度/记录 ===
    "角色":           ["角色", "角色", "Role", "Rôle", "役割", "역할", "Роль", "Rola", "Rol", "Papel", "Rolle", "Rol", "Ruolo"],
    "危险":           ["危险", "危險", "Danger", "Danger", "危険", "위험", "Опасность", "Niebezpieczeństwo", "Peligro", "Perigo", "Gefahr", "Tehlike", "Pericolo"],
    "难度":           ["难度", "難度", "Difficulty", "Difficulté", "難易度", "난이도", "Сложность", "Trudność", "Dificultad", "Dificuldade", "Schwierigkeit", "Zorluk", "Difficoltà"],
    "道具":           ["道具", "道具", "Item", "Objet", "アイテム", "아이템", "Предмет", "Przedmiot", "Objeto", "Item", "Gegenstand", "Eşya", "Oggetto"],
    "敬请期待":       ["敬请期待", "敬請期待", "Coming Soon", "Bientôt disponible", "準備中", "준비 중", "Скоро", "Wkrótce", "Próximamente", "Em breve", "Demnächst", "Çok Yakında", "Prossimamente"],

    // === 记录 ===
    "纪录":           ["纪录", "紀錄", "Records", "Records", "記録", "기록", "Рекорды", "Rekordy", "Récords", "Recordes", "Rekorde", "Rekorlar", "Record"],
    "通关最高难度":   ["通关最高难度", "通關最高難度", "Cleared Max Difficulty", "Difficulté max terminée", "最高難度クリア", "최고 난이도 클리어", "Макс. сложность пройдена", "Ukończono max trudność", "Dificultad máxima superada", "Dificuldade máxima concluída", "Max. Schwierigkeit geschafft", "Maks Zorluk Geçildi", "Difficoltà max superata"],
    "尚无记录":       ["尚无记录", "尚無記錄", "No Records Yet", "Aucun record", "記録なし", "기록 없음", "Нет рекордов", "Brak rekordów", "Sin registros", "Nenhum registro", "Keine Rekorde", "Henüz Kayıt Yok", "Nessun record"],

    // === 背景选项 ===
    "随机":           ["随机", "隨機", "Random", "Aléatoire", "ランダム", "랜덤", "Случайно", "Losowo", "Aleatorio", "Aleatório", "Zufall", "Rastgele", "Casuale"],
    "泥地":           ["泥地", "泥地", "Mud", "Boue", "泥", "진흙", "Грязь", "Błoto", "Barro", "Lama", "Schlamm", "Çamur", "Fango"],
    "森林":           ["森林", "森林", "Forest", "Forêt", "森", "숲", "Лес", "Las", "Bosque", "Floresta", "Wald", "Orman", "Foresta"],
    "火山":           ["火山", "火山", "Volcano", "Volcan", "火山", "화산", "Вулкан", "Wulkan", "Volcán", "Vulcão", "Vulkan", "Yanardağ", "Vulcano"],
    "梦幻之地":       ["梦幻之地", "夢幻之地", "Dreamland", "Pays des rêves", "夢の国", "꿈의 땅", "Страна грез", "Kraina snów", "Tierra de sueños", "Terra dos sonhos", "Traumland", "Rüya Diyarı", "Paese dei sogni"],
    "墓地":           ["墓地", "墓地", "Graveyard", "Cimetière", "墓地", "묘지", "Кладбище", "Cmentarz", "Cementerio", "Cemitério", "Friedhof", "Mezarlık", "Cimitero"],
    "黑暗之地":       ["黑暗之地", "黑暗之地", "Dark Place", "Lieu sombre", "暗黒の地", "어둠의 땅", "Темное место", "Mroczne miejsce", "Lugar oscuro", "Lugar escuro", "Dunkler Ort", "Karanlık Yer", "Luogo oscuro"],

    // === 设置页额外 ===
    "背景":           ["背景", "背景", "Background", "Arrière-plan", "背景", "배경", "Фон", "Tło", "Fondo", "Fundo", "Hintergrund", "Arka Plan", "Sfondo"],
    "无尽模式得分":   ["无尽模式得分", "無盡模式得分", "Endless Score", "Score infini", "エンドレススコア", "무한 모드 점수", "Очки бесконечного режима", "Wynik trybu nieskończonego", "Puntuación sin fin", "Pontuação infinita", "Endlos-Modus Punkte", "Sonsuz Mod Puanı", "Punteggio modalità infinita"],

    // === 波次显示 ===
    "第":             ["第", "第", "Wave ", "Vague ", "Wave ", "웨이브 ", "Волна ", "Fala ", "Oleada ", "Onda ", "Welle ", "Dalga ", "Ondata "],
    "波":             ["波", "波", "", "", "", "", "", "", "", "", "", "", ""],

    // === 结算页片段 ===
    "最高敌袭次数":   ["最高敌袭次数", "最高敵襲次數", "Highest Wave", "Vague la plus haute", "最高ウェーブ", "최고 웨이브", "Максимальная волна", "Najwyższa fala", "Oleada más alta", "Onda mais alta", "Höchste Welle", "En Yüksek Dalga", "Ondata più alta"],
    "最高难度":       ["最高难度", "最高難度", "Highest Difficulty", "Difficulté la plus haute", "最高難易度", "최고 난이도", "Максимальная сложность", "Najwyższy poziom trudności", "Dificultad más alta", "Dificuldade mais alta", "Höchste Schwierigkeit", "En Yüksek Zorluk", "Difficoltà più alta"],
    "得分(":          ["得分(", "得分(", "Score(", "Score(", "スコア(", "점수(", "Очки(", "Wynik(", "Puntuación(", "Pontuação(", "Punkte(", "Puan(", "Punteggio("],
    "): ":            ["): ", "): ", "): ", "): ", "): ", "): ", "): ", "): ", "): ", "): ", "): ", "): ", "): "],
    "  第":           ["  第", "  第", " Wave ", " Vague ", " Wave ", " 웨이브 ", " Волна ", " Fala ", " Oleada ", " Onda ", " Welle ", " Dalga ", " Ondata "],
    "波-危险":        ["波-危险", "波-危險", "-Danger", "-Danger", "-危険", "-위험", "-Опасность", "-Niebezpieczeństwo", "-Peligro", "-Perigo", "-Gefahr", "-Tehlike", "-Pericolo"],

    // === 商店片段 ===
    "刷新-":          ["刷新-", "刷新-", "Refresh-", "Actualiser-", "更新-", "새로고침-", "Обновить-", "Odśwież-", "Actualizar-", "Atualizar-", "Aktualisieren-", "Yenile-", "Aggiorna-"],
    "出发(第":        ["出发(第", "出發(第", "Go (Wave ", "Partir (Vague ", "出発(", "출발(웨이브 ", "Начать (Волна ", "Ruszaj (Fala ", "Ir (Oleada ", "Ir (Onda ", "Los (Welle ", "Başla (Dalga ", "Vai (Ondata "],
    "波)":            ["波)", "波)", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")"],

    // === 结算 ===
    "胜利":           ["胜利", "勝利", "Victory", "Victoire", "勝利", "승리", "Победа", "Zwycięstwo", "Victoria", "Vitória", "Sieg", "Zafer", "Vittoria"],
    "战败":           ["战败", "戰敗", "Defeat", "Défaite", "敗北", "패배", "Поражение", "Porażka", "Derrota", "Derrota", "Niederlage", "Yenilgi", "Sconfitta"],
    "settlement_victory":  ["胜利  第{0}波-危险{1}", "勝利  第{0}波-危險{1}", "Victory Wave {0}-Danger {1}", "Victoire Vague {0}-Danger {1}", "勝利 Wave {0}-危険{1}", "승리 웨이브 {0}-위험{1}", "Победа Волна {0}-Опасность{1}", "Zwycięstwo Fala {0}-Niebezpieczeństwo{1}", "Victoria Oleada {0}-Peligro{1}", "Vitória Onda {0}-Perigo{1}", "Sieg Welle {0}-Gefahr{1}", "Zafer Dalga {0}-Tehlike{1}", "Vittoria Ondata {0}-Pericolo{1}"],
    "settlement_defeat":   ["战败  第{0}波-危险{1}", "戰敗  第{0}波-危險{1}", "Defeat Wave {0}-Danger {1}", "Défaite Vague {0}-Danger {1}", "敗北 Wave {0}-危険{1}", "패배 웨이브 {0}-위험{1}", "Поражение Волна {0}-Опасность{1}", "Porażka Fala {0}-Niebezpieczeństwo{1}", "Derrota Oleada {0}-Peligro{1}", "Derrota Onda {0}-Perigo{1}", "Niederlage Welle {0}-Gefahr{1}", "Yenilgi Dalga {0}-Tehlike{1}", "Sconfitta Ondata {0}-Pericolo{1}"],
    "endless_score":       ["得分({0}): {1}", "得分({0}): {1}", "Score({0}): {1}", "Score({0}): {1}", "スコア({0}): {1}", "점수({0}): {1}", "Очки({0}): {1}", "Wynik({0}): {1}", "Puntuación({0}): {1}", "Pontuação({0}): {1}", "Punkte({0}): {1}", "Puan({0}): {1}", "Punteggio({0}): {1}"],
    "重试":           ["重试", "重試", "Retry", "Réessayer", "リトライ", "재시도", "Повторить", "Spróbuj ponownie", "Reintentar", "Tentar novamente", "Wiederholen", "Tekrar Dene", "Riprova"],
    "新游戏":         ["新游戏", "新遊戲", "New Game", "Nouvelle partie", "新規ゲーム", "새 게임", "Новая игра", "Nowa gra", "Nueva partida", "Novo jogo", "Neues Spiel", "Yeni Oyun", "Nuova partita"],

    // === 武器名 ===
    "长矛":           ["长矛", "長矛", "Spear", "Lance", "槍", "창", "Копьё", "Włócznia", "Lanza", "Lança", "Speer", "Mızrak", "Lancia"],
    "冲锋枪":         ["冲锋枪", "衝鋒槍", "SMG", "PM", "サブマシンガン", "기관단총", "ПП", "Pistolet maszynowy", "Subfusil", "Submetralhadora", "Maschinenpistole", "SMG", "Mitraglietta"],

    // === 武器类型 ===
    "原始":           ["原始", "原始", "Primitive", "Primitif", "原始", "원시", "Примитивное", "Prymitywna", "Primitiva", "Primitiva", "Primitiv", "İlkel", "Primitivo"],
    "枪械":           ["枪械", "槍械", "Firearm", "Arme à feu", "銃器", "총기", "Огнестрельное", "Broń palna", "Arma de fuego", "Arma de fogo", "Feuerwaffe", "Ateşli Silah", "Arma da fuoco"],

    // === 道具/角色名 ===
    "全能者":         ["全能者", "全能者", "Well-Rounded", "Polyvalent", "万能", "만능", "Разносторонний", "Wszechstronny", "Polivalente", "Versátil", "Allrounder", "Çok Yönlü", "Tuttofare"],
    "异变体":         ["异变体", "異變體", "Mutant", "Mutant", "ミュータント", "돌연변이", "Мутант", "Mutant", "Mutante", "Mutante", "Mutant", "Mutant", "Mutante"],
    "蝙蝠":           ["蝙蝠", "蝙蝠", "Bat", "Chauve-souris", "コウモリ", "박쥐", "Летучая мышь", "Nietoperz", "Murciélago", "Morcego", "Fledermaus", "Yarasa", "Pipistrello"],
    "刺猬":           ["刺猬", "刺蝟", "Hedgehog", "Hérisson", "ハリネズミ", "고슴도치", "Ёж", "Jeż", "Erizo", "Ouriço", "Igel", "Kirpi", "Riccio"],
    "头盔":           ["头盔", "頭盔", "Helmet", "Casque", "ヘルメット", "투구", "Шлем", "Hełm", "Casco", "Capacete", "Helm", "Kask", "Elmo"],
    "橡皮狂暴战士":   ["橡皮狂暴战士", "橡皮狂暴戰士", "Rubber Berserker", "Berserker en caoutchouc", "ラバーバーサーカー", "고무 광전사", "Резиновый берсерк", "Gumowy berserker", "Berserker de goma", "Berserker de borracha", "Gummi-Berserker", "Lastik Berserker", "Berserker di gomma"],
    "颅脑损伤":       ["颅脑损伤", "顱腦損傷", "Brain Injury", "Lésion cérébrale", "脳損傷", "뇌손상", "Травма мозга", "Uraz mózgu", "Lesión cerebral", "Lesão cerebral", "Hirnverletzung", "Beyin Hasarı", "Lesione cerebrale"],
    "咖啡":           ["咖啡", "咖啡", "Coffee", "Café", "コーヒー", "커피", "Кофе", "Kawa", "Café", "Café", "Kaffee", "Kahve", "Caffè"],
    "爪子树":         ["爪子树", "爪子树", "Claw Tree", "Arbre à griffes", "クローツリー", "발톱 나무", "Дерево когтей", "Drzewo pazurów", "Árbol de garras", "Árvore de garras", "Klauenbaum", "Pençe Ağacı", "Albero artiglio"],
    "沸水":           ["沸水", "沸水", "Boiling Water", "Eau bouillante", "熱湯", "끓는 물", "Кипяток", "Wrzątek", "Agua hirviendo", "Água fervente", "Kochendes Wasser", "Kaynar Su", "Acqua bollente"],
    "书":             ["书", "書", "Book", "Livre", "本", "책", "Книга", "Książka", "Libro", "Livro", "Buch", "Kitap", "Libro"],
    "破口":           ["破口", "破口", "Break Through", "Briser", "ブレイクスルー", "돌파", "Прорыв", "Przełamanie", "Ruptura", "Avanço", "Durchbruch", "Kırılma", "Sfondamento"],
    "蝴蝶":           ["蝴蝶", "蝴蝶", "Butterfly", "Papillon", "蝶", "나비", "Бабочка", "Motyl", "Mariposa", "Borboleta", "Schmetterling", "Kelebek", "Farfalla"],
    "有缺陷的类固醇":  ["有缺陷的类固醇", "有缺陷的類固醇", "Defective Steroids", "Stéroïdes défectueux", "欠陥ステロイド", "결함 있는 스테로이드", "Дефектные стероиды", "Wadliwe sterydy", "Esteroides defectuosos", "Esteroides defeituosos", "Defekte Steroide", "Kusurlu Steroidler", "Steroidi difettosi"],
    "牛皮胶布":       ["牛皮胶布", "牛皮膠布", "Duct Tape", "Ruban adhésif", "ダクトテープ", "덕트 테이프", "Изолента", "Taśma klejąca", "Cinta adhesiva", "Fita adesiva", "Klebeband", "Koli Bandı", "Nastro adesivo"],
    "蛋糕":           ["蛋糕", "蛋糕", "Cake", "Gâteau", "ケーキ", "케이크", "Торт", "Ciasto", "Pastel", "Bolo", "Kuchen", "Pasta", "Torta"],
    "眼镜":           ["眼镜", "眼鏡", "Glasses", "Lunettes", "眼鏡", "안경", "Очки", "Okulary", "Gafas", "Óculos", "Brille", "Gözlük", "Occhiali"],
    "山羊头骨":       ["山羊头骨", "山羊頭骨", "Goat Skull", "Crâne de chèvre", "ヤギの頭蓋骨", "염소 두개골", "Козий череп", "Czaszka kozy", "Cráneo de cabra", "Crânio de cabra", "Ziegenschädel", "Keçi Kafatası", "Teschio di capra"],
    "小圆帽":         ["小圆帽", "小圓帽", "Yarmulke", "Kippa", "ヤムルカ", "야물케", "Ермолка", "Jarmułka", "Kipá", "Solidéu", "Kippa", "Kipa", "Kippah"],
    "注射":           ["注射", "注射", "Injection", "Injection", "注射", "주사", "Инъекция", "Zastrzyk", "Inyección", "Injeção", "Injektion", "Enjeksiyon", "Iniezione"],
    "精神错乱":       ["精神错乱", "精神錯亂", "Insane", "Fou", "正気じゃない", "정신 이상", "Безумный", "Obłęd", "Insano", "Insano", "Wahnsinn", "Deli", "Folle"],
    "镜头":           ["镜头", "鏡頭", "Lens", "Lentille", "レンズ", "렌즈", "Линза", "Soczewka", "Lente", "Lente", "Linse", "Lens", "Lente"],
    "迷失之鸭":       ["迷失之鸭", "迷失之鴨", "Lost Duck", "Canard perdu", "迷子のアヒル", "길 잃은 오리", "Потерянная утка", "Zagubiona kaczka", "Pato perdido", "Pato perdido", "Verlorene Ente", "Kayıp Ördek", "Anatra smarrita"],
    "螺旋桨帽子":     ["螺旋桨帽子", "螺旋槳帽子", "Propeller Hat", "Chapeau à hélice", "プロペラ帽", "프로펠러 모자", "Шапка-пропеллер", "Czapka z śmigłem", "Sombrero de hélice", "Chapéu de hélice", "Propellerhut", "Pervaneli Şapka", "Cappello elica"],
    "恐怖洋葱":       ["恐怖洋葱", "恐怖洋蔥", "Terrifying Onion", "Oignon terrifiant", "恐怖のタマネギ", "무서운 양파", "Ужасный лук", "Przerażająca cebula", "Cebolla aterradora", "Cebola aterrorizante", "Schreckliche Zwiebel", "Korkunç Soğan", "Cipolla terrificante"],
    "有毒的烂泥":     ["有毒的烂泥", "有毒的爛泥", "Toxic Sludge", "Boue toxique", "毒ヘドロ", "유독성 진흙", "Токсичная жижа", "Toksyczne błoto", "Lodo tóxico", "Lama tóxica", "Giftiger Schlamm", "Zehirli Çamur", "Fango tossico"],
    "煤炭":           ["煤炭", "煤炭", "Coal", "Charbon", "石炭", "석탄", "Уголь", "Węgiel", "Carbón", "Carvão", "Kohle", "Kömür", "Carbone"],
    "肥料":           ["肥料", "肥料", "Fertilizer", "Engrais", "肥料", "비료", "Удобрение", "Nawóz", "Fertilizante", "Fertilizante", "Dünger", "Gübre", "Fertilizzante"],
    "酸液":           ["酸液", "酸液", "Acid Liquor", "Liqueur acide", "酸の酒", "산성 액체", "Кислотная жидкость", "Kwaśny likier", "Licor ácido", "Líquido ácido", "Säureflüssigkeit", "Asit Likörü", "Liquore acido"],
    "能量手镯":       ["能量手镯", "能量手鐲", "Energy Bracelet", "Bracelet énergétique", "エネルギーブレスレット", "에너지 팔찌", "Энергетический браслет", "Bransoletka energii", "Pulsera de energía", "Pulseira de energia", "Energiearmband", "Enerji Bilekliği", "Bracciale energetico"],
    "齿轮":           ["齿轮", "齒輪", "Gear", "Engrenage", "歯車", "기어", "Шестерня", "Koło zębate", "Engranaje", "Engrenagem", "Zahnrad", "Dişli", "Ingranaggio"],
    "独眼虫":         ["独眼虫", "獨眼蟲", "Cyclops Beetle", "Scarabée cyclope", "サイクロプスビートル", "외눈박이 딱정벌레", "Жук-циклоп", "Cyklop żuk", "Escarabajo cíclope", "Besouro ciclope", "Zyklopenkäfer", "Tepegöz Böceği", "Coleottero ciclope"],
    "燃料箱":         ["燃料箱", "燃料箱", "Fuel Tank", "Réservoir", "燃料タンク", "연료 탱크", "Топливный бак", "Zbiornik paliwa", "Tanque de combustible", "Tanque de combustível", "Treibstofftank", "Yakıt Tankı", "Serbatoio"],
    "筹码":           ["筹码", "籌碼", "Chip", "Jeton", "チップ", "칩", "Фишка", "Żeton", "Ficha", "Ficha", "Chip", "Fiş", "Gettoniera"],
    "营火":           ["营火", "營火", "Campfire", "Feu de camp", "焚き火", "캠프파이어", "Костёр", "Ognisko", "Hoguera", "Fogueira", "Lagerfeuer", "Kamp Ateşi", "Falò"],
    "黑带":           ["黑带", "黑帶", "Black Belt", "Ceinture noire", "黒帯", "검은 띠", "Чёрный пояс", "Czarny pas", "Cinturón negro", "Faixa preta", "Schwarzer Gürtel", "Siyah Kuşak", "Cintura nera"],
    "眼罩":           ["眼罩", "眼罩", "Patch", "Cache-œil", "眼帯", "안대", "Повязка на глаз", "Przepaska na oko", "Parche", "Tapa-olho", "Augenklappe", "Gözlük", "Benda"],
    "旗帜":           ["旗帜", "旗幟", "Flag", "Drapeau", "旗", "깃발", "Флаг", "Flaga", "Bandera", "Bandeira", "Flagge", "Bayrak", "Bandiera"],
    "皮制背心":       ["皮制背心", "皮製背心", "Leather Vest", "Gilet en cuir", "革のベスト", "가죽 조끼", "Кожаный жилет", "Skórzana kamizelka", "Chaleco de cuero", "Colete de couro", "Lederweste", "Deri Yelek", "Gilet di pelle"],
    "小肌肉男":       ["小肌肉男", "小肌肉男", "Small Muscle Man", "Petit musclé", "小さなマッスルマン", "작은 근육男", "Маленький качок", "Mały mięśniak", "Pequeño musculoso", "Forte pequeno", "Kleiner Muskelmann", "Küçük Kas Adam", "Piccolo muscoloso"],
    "精通":           ["精通", "精通", "Mastery", "Maîtrise", "熟練", "숙련", "Мастерство", "Mistrzostwo", "Maestría", "Maestria", "Meisterschaft", "Ustalık", "Maestria"],
    "奖牌":           ["奖牌", "獎牌", "Medal", "Médaille", "メダル", "메달", "Медаль", "Medal", "Medalla", "Medalha", "Medaille", "Madalya", "Medaglia"],
    "外星人宝宝":     ["外星人宝宝", "外星人寶寶", "Alien Baby", "Bébé alien", "エイリアンベビー", "외계인 아기", "Малыш-пришелец", "Dziecko kosmity", "Bebé alienígena", "Bebê alienígena", "Außerirdisches Baby", "Uzaylı Bebek", "Bebè alieno"],
    "外星人魔法":     ["外星人魔法", "外星人魔法", "Alien Magic", "Magie alien", "エイリアンマジック", "외계인 마법", "Магия пришельцев", "Magia kosmity", "Magia alienígena", "Magia alienígena", "Aliens-Magie", "Uzaylı Büyüsü", "Magia aliena"],
    "四叶草":         ["四叶草", "四葉草", "Clover", "Trèfle", "クローバー", "클로버", "Клевер", "Koniczyna", "Trébol", "Trevo", "Kleeblatt", "Yonca", "Trifoglio"],
    "合金":           ["合金", "合金", "Alloy", "Alliage", "合金", "합금", "Сплав", "Stop", "Aleación", "Liga", "Legierung", "Alaşım", "Lega"],
    "有毒补药":       ["有毒补药", "有毒補藥", "Toxic Tonics", "Toniques toxiques", "毒薬", "독성 강장제", "Токсичные тоники", "Toksyczne toniki", "Tónicos tóxicos", "Tônicos tóxicos", "Giftige Tonika", "Zehirli Tonikler", "Tonici tossici"],
    "休穆糖":         ["休穆糖", "休穆糖", "Shmoop", "Shmoop", "シュモープ", "슈무프", "Шмуп", "Shmoop", "Shmoop", "Shmoop", "Shmoop", "Şmoop", "Shmoop"],
    "工具箱":         ["工具箱", "工具箱", "Toolbox", "Boîte à outils", "工具箱", "공구 상자", "Ящик с инструментами", "Skrzynka narzędzi", "Caja de herramientas", "Caixa de ferramentas", "Werkzeugkiste", "Alet Kutusu", "Cassetta degli attrezzi"],
    "守卫头盔":       ["守卫头盔", "守衛頭盔", "Guard Helmet", "Casque de garde", "ガードヘルメット", "수호 투구", "Шлем стража", "Hełm strażnika", "Casco de guardia", "Capacete de guarda", "Wächterhelm", "Muhafız Kaskı", "Elmo da guardia"],
    "玻璃大炮":       ["玻璃大炮", "玻璃大炮", "Glass Cannon", "Canon de verre", "グラスキャノン", "유리 대포", "Стеклянная пушка", "Szklana armata", "Cañón de cristal", "Canhão de vidro", "Glaskanone", "Cam Topu", "Cannone di vetro"],
    "斗篷":           ["斗篷", "斗篷", "Cloak", "Cape", "マント", "망토", "Плащ", "Płaszcz", "Capa", "Capa", "Umhang", "Pelerin", "Mantello"],
    "外骨骼":         ["外骨骼", "外骨骼", "Exoskeleton", "Exosquelette", "エクソスケルトン", "외골격", "Экзоскелет", "Egzoszkielet", "Exoesqueleto", "Exoesqueleto", "Exoskelett", "Dış İskelet", "Esoscheletro"],
    "重子弹":         ["重子弹", "重子彈", "Heavy Bullets", "Balles lourdes", "ヘビーバレット", "중탄환", "Тяжёлые пули", "Ciężkie pociski", "Balas pesadas", "Balas pesadas", "Schwere Geschosse", "Ağır Mermiler", "Proiettili pesanti"],

    // === 升级选项名 ===
    "腿":             ["腿", "腿", "Leg", "Jambe", "脚", "다리", "Нога", "Noga", "Pierna", "Perna", "Bein", "Bacak", "Gamba"],
    "胸":             ["胸", "胸", "Chest", "Torse", "胸", "가슴", "Грудь", "Klatka piersiowa", "Pecho", "Peito", "Brust", "Göğüs", "Torace"],
    "头骨":           ["头骨", "頭骨", "Skull", "Crâne", "頭蓋骨", "두개골", "Череп", "Czaszka", "Cráneo", "Crânio", "Schädel", "Kafatası", "Teschio"],
    "肺":             ["肺", "肺", "Lung", "Poumon", "肺", "폐", "Лёгкие", "Płuco", "Pulmón", "Pulmão", "Lunge", "Akciğer", "Polmone"],
    "手指":           ["手指", "手指", "Finger", "Doigt", "指", "손가락", "Палец", "Palec", "Dedo", "Dedo", "Finger", "Parmak", "Dito"],
    "背":             ["背", "背", "Back", "Dos", "背中", "등", "Спина", "Plecy", "Espalda", "Costas", "Rücken", "Sırt", "Schiena"],
    "牙齿":           ["牙齿", "牙齒", "Teeth", "Dents", "歯", "이빨", "Зубы", "Zęby", "Dientes", "Dentes", "Zähne", "Dişler", "Denti"],
    "心脏":           ["心脏", "心臟", "Heart", "Cœur", "心臓", "심장", "Сердце", "Serce", "Corazón", "Coração", "Herz", "Kalp", "Cuore"],
    "脑":             ["脑", "腦", "Brain", "Cerveau", "脳", "뇌", "Мозг", "Mózg", "Cerebro", "Cérebro", "Gehirn", "Beyin", "Cervello"],
    "反应能力":       ["反应能力", "反應能力", "Reflexes", "Réflexes", "反射神経", "반사 신경", "Рефлексы", "Refleksy", "Reflejos", "Reflexos", "Reflexe", "Refleksler", "Riflessi"],
    "鼻":             ["鼻", "鼻", "Nose", "Nez", "鼻", "코", "Нос", "Nos", "Nariz", "Nariz", "Nase", "Burun", "Naso"],
    "手":             ["手", "手", "Hand", "Main", "手", "손", "Рука", "Dłoń", "Mano", "Mão", "Hand", "El", "Mano"],
    "肩":             ["肩", "肩", "Shoulder", "Épaule", "肩", "어깨", "Плечо", "Ramię", "Hombro", "Ombro", "Schulter", "Omuz", "Spalla"],
    "前臂":           ["前臂", "前臂", "Forearm", "Avant-bras", "前腕", "전완", "Предплечье", "Przedramię", "Antebrazo", "Antebraço", "Unterarm", "Önkol", "Avambraccio"],
    "三头肌":         ["三头肌", "三頭肌", "Triceps", "Triceps", "上腕三頭筋", "삼두근", "Трицепс", "Triceps", "Tríceps", "Tríceps", "Trizeps", "Triceps", "Tricipiti"],
    "眼睛":           ["眼睛", "眼睛", "Eyes", "Yeux", "目", "눈", "Глаза", "Oczy", "Ojos", "Olhos", "Augen", "Gözler", "Occhi"],

    // === 武器渲染标签 (DataLoader.renderWeaponTalentText) ===
    "概率":           ["概率", "概率", " Chance", " de chance", "確率", " 확률", " Шанс", " Szansy", " de probabilidad", " de chance", " Chance", " Şans", " di probabilità"],
    "伤害":           ["伤害", "傷害", "Damage", "Dégâts", "ダメージ", "피해", "Урон", "Obrażenia", "Daño", "Dano", "Schaden", "Hasar", "Danno"],
    "暴击":           ["暴击", "暴擊", "Crit", "Crit", "クリティカル", "치명타", "Крит", "Kryt", "Crítico", "Crítico", "Krit", "Kritik", "Critico"],
    "冷却":           ["冷却", "冷卻", "Cooldown", "Recharge", "クールダウン", "재사용 대기시간", "Перезарядка", "Odnowienie", "Enfriamiento", "Recarga", "Abklingzeit", "Bekleme Süresi", "Ricarica"],
    "近战":           ["近战", "近戰", "Melee", "Mêlée", "近接", "근접", "Ближний бой", "Walka wręcz", "Cuerpo a cuerpo", "Corpo a corpo", "Nahkampf", "Yakın Dövüş", "Mischia"],
    "远战":           ["远战", "遠戰", "Ranged", "À distance", "遠隔", "원거리", "Дальний бой", "Dystans", "A distancia", "À distância", "Fernkampf", "Menzilli", "A distanza"],
    "范围":           ["范围", "範圍", "Range", "Portée", "射程", "사거리", "Дальность", "Zasięg", "Alcance", "Alcance", "Reichweite", "Menzil", "Gittata"],

    // === talentText 属性别名（道具/升级描述中使用） ===
    "射程":           ["射程", "射程", "Range", "Portée", "射程", "사거리", "Дальность", "Zasięg", "Alcance", "Alcance", "Reichweite", "Menzil", "Gittata"],
    "工程":           ["工程", "工程", "Engineering", "Ingénierie", "工学", "공학", "Инженерия", "Inżynieria", "Ingeniería", "Engenharia", "Technik", "Mühendislik", "Ingegneria"],
    "攻击速度":       ["攻击速度", "攻擊速度", "Attack Speed", "Vitesse d'attaque", "攻撃速度", "공격 속도", "Скорость атаки", "Szybkość ataku", "Velocidad de ataque", "Velocidade de ataque", "Angriffsgeschwindigkeit", "Saldırı Hızı", "Velocità d'attacco"],
    "攻速":           ["攻速", "攻速", "Atk Spd", "Vit. d'attaque", "攻速", "공속", "Ск. атаки", "Szyb. ataku", "Vel. ataque", "Vel. ataque", "Angr.-Geschw.", "Sld. Hızı", "Vel. attacco"],
    "敌人移动速度":   ["敌人移动速度", "敵人移動速度", "Enemy Move Speed", "Vit. déplacement ennemi", "敵移動速度", "적 이동 속도", "Ск. передвижения врагов", "Prędkość ruchu wroga", "Vel. movimiento enemigo", "Vel. movimento inimigo", "Gegner-Bewegungsgeschw.", "Düşman Hareket Hızı", "Vel. movimento nemico"],
    "暴击率":         ["暴击率", "暴擊率", "Crit Chance", "Chance de critique", "クリティカル率", "치명타 확률", "Шанс крита", "Szansa krytyczna", "Prob. crítica", "Chance crítica", "Krit. Chance", "Kritik Şansı", "Prob. critico"],
    "最大生命":       ["最大生命", "最大生命", "Max HP", "PV max", "最大HP", "최대 HP", "Макс. здоровье", "Maks. HP", "Vida máxima", "Vida máxima", "Max. Leben", "Maks. Can", "PS max"],
    "生命偷取":       ["生命偷取", "生命偷取", "Life Steal", "Vol de vie", "ライフスティール", "생명력 흡수", "Вампиризм", "Kradzież życia", "Robo de vida", "Roubo de vida", "Lebensraub", "Can Çalma", "Furto di vita"],
    "生命恢复":       ["生命恢复", "生命恢復", "HP Recovery", "Récupération PV", "HP回復", "HP 회복", "Восстановление здоровья", "Regeneracja HP", "Recuperación de vida", "Recuperação de vida", "LP-Erholung", "Can İyileşmesi", "Recupero PS"],
    "生命窃取":       ["生命窃取", "生命竊取", "Life Steal", "Vol de vie", "ライフスティール", "생명력 흡수", "Вампиризм", "Kradzież życia", "Robo de vida", "Roubo de vida", "Lebensraub", "Can Çalma", "Furto di vita"],
    "经验值":         ["经验值", "經驗值", "XP", "XP", "経験値", "경험치", "Опыт", "Doświadczenie", "EXP", "EXP", "EP", "Tecrübe", "ESP"],
    "经验获取":       ["经验获取", "經驗獲取", "Experience Gain", "Gain d'expérience", "経験値獲得", "경험치 획득", "Получение опыта", "Zdobywanie doświadczenia", "Ganancia de experiencia", "Ganho de experiência", "Erfahrungsgewinn", "Deneyim Kazancı", "Guadagno esperienza"],
    "运气":           ["运气", "運氣", "Luck", "Chance", "運", "행운", "Удача", "Szczęście", "Suerte", "Sorte", "Glück", "Şans", "Fortuna"],
    "速度":           ["速度", "速度", "Speed", "Vitesse", "速度", "속도", "Скорость", "Prędkość", "Velocidad", "Velocidade", "Geschwindigkeit", "Hız", "Velocità"],
    "升级需要":       ["升级需要", "升級需要", "Upgrade Needs", "Amélioration nécessite", "アップグレード必要", "업그레이드 필요", "Требуется для улучшения", "Ulepszenie wymaga", "Mejora necesita", "Melhoria precisa", "Aufwertung benötigt", "Yükseltme Gereksinimi", "Potenziamento richiede"],

    // === 主要属性名 ===
    "最大生命值":     ["最大生命值", "最大生命值", "Max HP", "PV max", "最大HP", "최대 HP", "Макс. здоровье", "Maks. HP", "Vida máxima", "Vida máxima", "Max. Leben", "Maks. Can", "PS max"],
    "生命再生":       ["生命再生", "生命再生", "HP Regeneration", "Régénération PV", "HP再生", "HP 재생", "Регенерация здоровья", "Regeneracja HP", "Regeneración de vida", "Regeneração de vida", "LP-Regeneration", "Can Yenilenmesi", "Rigenerazione PS"],
    "%生命窃取":      ["%生命窃取", "%生命竊取", "% Life Steal", "% Vol de vie", "%ライフスティール", "% 생명력 흡수", "% вампиризм", "% Kradzież życia", "% Robo de vida", "% Roubo de vida", "% Lebensraub", "% Can Çalma", "% Furto di vita"],
    "%伤害":          ["%伤害", "%傷害", "% Damage", "% Dégâts", "%ダメージ", "% 피해", "% урон", "% Obrażenia", "% Daño", "% Dano", "% Schaden", "% Hasar", "% Danno"],
    "近战伤害":       ["近战伤害", "近戰傷害", "Melee Damage", "Dégâts mêlée", "近接ダメージ", "근접 피해", "Урон в ближнем бою", "Obrażenia w walce wręcz", "Daño cuerpo a cuerpo", "Dano corpo a corpo", "Nahkampfschaden", "Yakın Dövüş Hasarı", "Danno da mischia"],
    "远程伤害":       ["远程伤害", "遠程傷害", "Ranged Damage", "Dégâts à distance", "遠隔ダメージ", "원거리 피해", "Дальний урон", "Obrażenia dystansowe", "Daño a distancia", "Dano à distância", "Fernkampfschaden", "Menzilli Hasar", "Danno a distanza"],
    "元素伤害":       ["元素伤害", "元素傷害", "Elemental Damage", "Dégâts élémentaires", "属性ダメージ", "원소 피해", "Стихийный урон", "Obrażenia żywiołów", "Daño elemental", "Dano elemental", "Elementarschaden", "Element Hasarı", "Danno elementale"],
    "%攻击速度":      ["%攻击速度", "%攻擊速度", "% Attack Speed", "% Vitesse d'attaque", "%攻撃速度", "% 공격 속도", "% скорость атаки", "% Prędkość ataku", "% Velocidad de ataque", "% Velocidade de ataque", "% Angriffsgeschwindigkeit", "% Saldırı Hızı", "% Velocità d'attacco"],
    "%暴击率":        ["%暴击率", "%暴擊率", "% Crit Chance", "% Chance de critique", "%クリティカル率", "% 치명타 확률", "% шанс крита", "% Szansy na kryt", "% Prob. crítica", "% Chance crítica", "% Krit. Chance", "% Kritik Şansı", "% Prob. critico"],
    "工程学":         ["工程学", "工程學", "Engineering", "Ingénierie", "エンジニアリング", "공학", "Инженерия", "Inżynieria", "Ingeniería", "Engenharia", "Ingenieurskunst", "Mühendislik", "Ingegneria"],
    "护甲":           ["护甲", "護甲", "Armor", "Armure", "アーマー", "방어구", "Броня", "Pancerz", "Armadura", "Armadura", "Rüstung", "Zırh", "Armatura"],
    "%闪避":          ["%闪避", "%閃避", "% Dodge", "% Esquive", "%回避", "% 회피", "% уклонение", "% Uniku", "% Esquivar", "% Esquiva", "% Ausweichen", "% Kaçınma", "% Schivata"],
    "%速度":          ["%速度", "%速度", "% Speed", "% Vitesse", "%速度", "% 속도", "% скорость", "% Prędkość", "% Velocidad", "% Velocidade", "% Tempo", "% Hız", "% Velocità"],
    "幸运":           ["幸运", "幸運", "Luck", "Chance", "運", "행운", "Удача", "Szczęście", "Suerte", "Sorte", "Glück", "Şans", "Fortuna"],
    "收获":           ["收获", "收穫", "Harvesting", "Récolte", "収穫", "수확", "Сбор", "Zbiory", "Cosecha", "Colheita", "Ernte", "Hasat", "Raccolto"],

    // === 次要属性名 ===
    "消耗性治疗":     ["消耗性治疗", "消耗性治療", "Consumptive Therapy", "Soin consommable", "消費治療", "소모성 치료", "Потребляемая терапия", "Terapia konsumpcyjna", "Terapia consumible", "Terapia consumível", "Verbrauchstherapie", "Tüketim Tedavisi", "Terapia consumabile"],
    "%材料治疗":      ["%材料治疗", "%材料治療", "% Material Therapy", "% Soin matériel", "%素材治療", "% 재료 치료", "% материальная терапия", "% Terapia materiałowa", "% Terapia material", "% Terapia de material", "% Materialtherapie", "% Malzeme Tedavisi", "% Terapia materiale"],
    "获得%经验":      ["获得%经验", "獲得%經驗", "% Experience Gain", "% Gain d'expérience", "%経験値獲得", "% 경험치 획득", "% получение опыта", "% Zdobywania doświadczenia", "% Ganancia de experiencia", "% Ganho de experiência", "% Erfahrungsgewinn", "% Deneyim Kazancı", "% Guadagno esperienza"],
    "%拾取范围":      ["%拾取范围", "%拾取範圍", "% Pickup Range", "% Portée de ramassage", "%拾得範囲", "% 획득 범위", "% Радиус подбора", "% Zasięg podnoszenia", "% Alcance de recogida", "% Alcance de coleta", "% Aufhebreichweite", "% Toplama Menzili", "% Raggio raccolta"],
    "%道具价格":      ["%道具价格", "%道具價格", "% Item Price", "% Prix objet", "%アイテム価格", "% 아이템 가격", "% Цена предметов", "% Cena przedmiotów", "% Precio de objetos", "% Preço de itens", "% Gegenstandspreis", "% Eşya Fiyatı", "% Prezzo oggetti"],
    "%爆炸伤害":      ["%爆炸伤害", "%爆炸傷害", "% Explosion Damage", "% Dégâts d'explosion", "%爆発ダメージ", "% 폭발 피해", "% урон от взрыва", "% Obrażenia wybuchowe", "% Daño de explosión", "% Dano explosivo", "% Explosionsschaden", "% Patlama Hasarı", "% Danno esplosivo"],
    "%爆炸范围":      ["%爆炸范围", "%爆炸範圍", "% Explosion Range", "% Portée d'explosion", "%爆発範囲", "% 폭발 범위", "% Радиус взрыва", "% Zasięg wybuchu", "% Alcance de explosión", "% Alcance explosivo", "% Explosionsradius", "% Patlama Menzili", "% Raggio esplosivo"],
    "反弹":           ["反弹", "反彈", "Rebound", "Rebond", "跳ね返り", "반사", "Рикошет", "Odbicie", "Rebote", "Ricochete", "Abpraller", "Sekme", "Rimbalzo"],
    "贯通":           ["贯通", "貫通", "Penetrate", "Pénétration", "貫通", "관통", "Пробивание", "Przebicie", "Penetrar", "Penetrar", "Durchdringen", "Delme", "Penetrazione"],
    "%贯通伤害":      ["%贯通伤害", "%貫通傷害", "% Penetration Damage", "% Dégâts de pénétration", "%貫通ダメージ", "% 관통 피해", "% урон пробития", "% Obrażenia przebicia", "% Daño de penetración", "% Dano de penetração", "% Durchdringungsschaden", "% Delme Hasarı", "% Danno penetrazione"],
    "%对BOSS伤害":    ["%对BOSS伤害", "%對BOSS傷害", "% Damage to Boss", "% Dégâts au boss", "%ボスダメージ", "% 보스 피해", "% урон боссу", "% Obrażenia bossa", "% Daño a jefe", "% Dano ao chefe", "% Boss-Schaden", "% Patron Hasarı", "% Danno al boss"],
    "%燃烧速度":      ["%燃烧速度", "%燃燒速度", "% Burn Rate", "% Taux de brûlure", "%燃焼率", "% 화상 속도", "% скорость горения", "% Szybkość spalania", "% Tasa de quemadura", "% Taxa de queimadura", "% Brennrate", "% Yanma Oranı", "% Tasso di bruciatura"],
    "燃烧速度":       ["燃烧速度", "燃燒速度", "Burn Rate", "Taux de brûlure", "燃焼率", "화상 속도", "Скорость горения", "Szybkość spalania", "Tasa de quemadura", "Taxa de queimadura", "Brennrate", "Yanma Oranı", "Tasso di bruciatura"],
    "击退":           ["击退", "擊退", "Knockback", "Recul", "ノックバック", "넉백", "Отбрасывание", "Odrzut", "Retroceso", "Repulsão", "Rückstoß", "Geri Tepme", "Respingimento"],
    "%几率获得双倍材料": ["%几率获得双倍材料", "%機率獲得雙倍材料", "% Double Material Chance", "% Chance double matériau", "%素材2倍確率", "% 재료 2배 확률", "% шанс двойных материалов", "% Szansa podwójnych materiałów", "% Prob. material doble", "% Chance de material duplo", "% Doppelte Materialchance", "% Çift Malzeme Şansı", "% Prob. materiale doppio"],
    "箱子里的材料":   ["箱子里的材料", "箱子裡的材料", "Materials in Box", "Matériaux dans le coffre", "宝箱の素材", "상자 속 재료", "Материалы в ящике", "Materiały w skrzyni", "Materiales en caja", "Materiais na caixa", "Materialien in der Kiste", "Kutudaki Malzemeler", "Materiali nella cassa"],
    "免费刷新":       ["免费刷新", "免費刷新", "Free Refresh", "Actualisation gratuite", "無料更新", "무료 새로고침", "Бесплатное обновление", "Darmowe odświeżenie", "Actualización gratuita", "Atualização gratuita", "Kostenlose Aktualisierung", "Ücretsiz Yenileme", "Aggiornamento gratuito"],
    "树木":           ["树木", "樹木", "Trees", "Arbres", "木", "나무", "Деревья", "Drzewa", "Árboles", "Árvores", "Bäume", "Ağaçlar", "Alberi"],
    "%敌人":          ["%敌人", "%敵人", "% Enemies", "% Ennemis", "%敵", "% 적", "% врагов", "% Wrogów", "% Enemigos", "% Inimigos", "% Gegner", "% Düşman", "% Nemici"],
    "%敌人速度":      ["%敌人速度", "%敵人速度", "% Enemy Speed", "% Vitesse ennemie", "%敵速度", "% 적 속도", "% скорость врагов", "% Prędkość wrogów", "% Velocidad enemiga", "% Velocidade inimiga", "% Gegner-Geschwindigkeit", "% Düşman Hızı", "% Velocità nemica"],

    // === 属性面板附加 ===
    "目前等级":       ["目前等级", "目前等級", "Current Level", "Niveau actuel", "現在のレベル", "현재 레벨", "Текущий уровень", "Obecny poziom", "Nivel actual", "Nível atual", "Aktuelles Level", "Mevcut Seviye", "Livello attuale"],

    // === 战斗/商店等附加 ===
    "商店(":          ["商店(", "商店(", "Store (", "Magasin (", "ショップ(", "상점(", "Магазин (", "Sklep (", "Tienda (", "Loja (", "Laden (", "Dükkan (", "Negozio ("],
    "通过!":          ["通过!", "通過!", "Clear!", "Vague suivante!", "クリア!", "클리어!", "Пройти!", "Przebieg!", "¡Superado!", "Passou!", "Geschafft!", "Geçti!", "Superato!"],
    "闪避":           ["闪避", "閃避", "Dodge", "Esquive", "回避", "회피", "Уклонение", "Unik", "Evasión", "Esquiva", "Ausweichen", "Kaçınma", "Schivata"],
    "无修改":         ["无修改", "無修改", "Unmodified", "Non modifié", "無改変", "수정 없음", "Без изменений", "Bez modyfikacji", "Sin modificar", "Não modificado", "Unverändert", "Değişiklik Yok", "Non modificato"],
    "中文":           ["中文", "中文", "Chinese", "Chinois", "中国語", "중국어", "Китайский", "Chiński", "Chino", "Chinês", "Chinesisch", "Çince", "Cinese"],
    "繁体中文":       ["繁体中文", "繁體中文", "Traditional Chinese", "Chinois traditionnel", "繁体中国語", "번체 중국어", "Традиционный китайский", "Chiński tradycyjny", "Chino tradicional", "Chinês tradicional", "Traditionelles Chinesisch", "Geleneksel Çince", "Cinese tradizionale"],
}

/**
 * tr — 翻译函数
 * @param {string} text - 中文原文
 * @param {number} langIndex - 语言索引（默认从设置读取）
 * @returns {string} 翻译后的文本
 */
function tr(text, langIndex) {
    if (langIndex === undefined) {
        // 从缓存读取（由 Main.qml 的 Connections 保持最新）
        // 不再使用 Qt.createQmlObject() — 它在纯 JS 上下文中静默失败，永远回退中文
        langIndex = _currentLanguage
    }

    var entry = strings[text]
    if (!entry) return text  // 未找到翻译，返回原文

    // 如果该语言索引在范围内，返回对应翻译
    if (langIndex >= 0 && langIndex < entry.length) {
        return entry[langIndex]
    }

    // fallback: 英文（索引2）
    return entry[2] || text
}

/**
 * trFormat — 带占位符替换的翻译函数
 * @param {string} template - 含 {0} {1} 占位符的翻译 key
 * @param {number} langIndex - 语言索引
 * @param {Array} args - 替换值数组
 * @returns {string} 替换占位符后的翻译文本
 */
function trFormat(template, langIndex, args) {
    var translated = tr(template, langIndex)
    if (!args || args.length === 0) return translated
    return translated.replace(/\{(\d+)\}/g, function(match, index) {
        var i = parseInt(index, 10)
        return (i >= 0 && i < args.length) ? args[i] : match
    })
}

/**
 * addTranslation — 运行时添加新翻译（可用于动态内容）
 */
function addTranslation(chineseText, translations) {
    strings[chineseText] = translations
}

/**
 * translateRichText — 翻译 RichText HTML 中的中文属性名
 * 用于 talentText 等 HTML+中文混排的文本（如 "<font color='lime'>+2</font><font color='white'>生命窃取</font>"）
 * 将其中连续的中文字符段逐一查表翻译
 * @param {string} html - 包含中文的 RichText 字符串
 * @param {number} langIndex - 语言索引
 * @returns {string} 翻译后的 RichText 字符串
 */
function translateRichText(html, langIndex) {
    if (!html) return ""
    return html.replace(/[%\u4e00-\u9fff]+/g, function(match) {
        return tr(match, langIndex)
    })
}
