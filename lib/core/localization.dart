import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../providers/game_provider.dart';

enum AppLang { tr, en, de, ru }

class Loc {
  final String appName = 'Block Tower';
  final String play;
  final String settings;
  final String stats;
  final String score;
  final String level;
  final String best;
  final String newHighScore;
  final String gameOver;
  final String tapToStart;
  final String tapToDrop;
  final String paused;
  final String continueGame;
  final String restart;
  final String menu;
  final String sound;
  final String soundSubtitle;
  final String vibration;
  final String vibrationSubtitle;
  final String music;
  final String musicSubtitle;
  final String about;
  final String version;
  final String aboutDesc;
  final String language;
  final String perfect;
  final String good;
  final String miss;
  final String combo;
  final String maxCombo;
  final String perfectCount;
  final String resetStats;
  final String gamesPlayed;
  final String highestLevel;
  final String totalScore;
  final String averageScore;
  final String easy;
  final String medium;
  final String hard;
  final String insane;
  // Shop & Economy
  final String shop;
  final String coins;
  final String buy;
  final String equipped;
  final String equip;
  final String locked;
  final String notEnoughCoins;
  final String skinDefault;
  final String skinClassic;
  final String skinHologram;
  final String skinIce;
  final String coinsEarned;
  // Game Modes
  final String classicMode;
  final String timeRush;
  final String timeLeft;
  final String selectMode;
  final String skins;
  final String powerups;
  final String weatherEffects;
  final String weatherEffectsSubtitle;
  // Privacy Policy
  final String privacyPolicy;
  final String dataCollection;
  final String dataUsage;
  final String dataStorage;
  final String yourRights;
  final String privacyText1;
  final String privacyText2;
  final String privacyText3;
  final String privacyText4;
  final String contactUs;
  final String decline;
  final String accept;
  final String iAccept;

  const Loc({
    required this.play,
    required this.settings,
    required this.stats,
    required this.score,
    required this.level,
    required this.best,
    required this.newHighScore,
    required this.gameOver,
    required this.tapToStart,
    required this.tapToDrop,
    required this.paused,
    required this.continueGame,
    required this.restart,
    required this.menu,
    required this.sound,
    required this.soundSubtitle,
    required this.vibration,
    required this.vibrationSubtitle,
    required this.music,
    required this.musicSubtitle,
    required this.about,
    required this.version,
    required this.aboutDesc,
    required this.language,
    required this.perfect,
    required this.good,
    required this.miss,
    required this.combo,
    required this.maxCombo,
    required this.perfectCount,
    required this.resetStats,
    required this.gamesPlayed,
    required this.highestLevel,
    required this.totalScore,
    required this.averageScore,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.insane,
    required this.shop,
    required this.coins,
    required this.buy,
    required this.equipped,
    required this.equip,
    required this.locked,
    required this.notEnoughCoins,
    required this.skinDefault,
    required this.skinClassic,
    required this.skinHologram,
    required this.skinIce,
    required this.coinsEarned,
    required this.classicMode,
    required this.timeRush,
    required this.timeLeft,
    required this.selectMode,
    required this.skins,
    required this.powerups,
    required this.weatherEffects,
    required this.weatherEffectsSubtitle,
    required this.privacyPolicy,
    required this.dataCollection,
    required this.dataUsage,
    required this.dataStorage,
    required this.yourRights,
    required this.privacyText1,
    required this.privacyText2,
    required this.privacyText3,
    required this.privacyText4,
    required this.contactUs,
    required this.decline,
    required this.accept,
    required this.iAccept,
  });
}

const Map<AppLang, Loc> _translations = {
  AppLang.tr: Loc(
    play: 'Oyna',
    settings: 'Ayarlar',
    stats: 'İstatistikler',
    score: 'Skor',
    level: 'Seviye',
    best: 'En İyi',
    newHighScore: 'Yeni Rekor!',
    gameOver: 'Oyun Bitti',
    tapToStart: 'Başlamak için Dokun',
    tapToDrop: 'Bloğu doğru zamanda bırak!',
    paused: 'Duraklatıldı',
    continueGame: 'Devam Et',
    restart: 'Yeniden Başla',
    menu: 'Ana Menü',
    sound: 'Ses',
    soundSubtitle: 'Oyun içi ses efektleri',
    vibration: 'Titreşim',
    vibrationSubtitle: 'Dokunsal geri bildirim',
    music: 'Müzik',
    musicSubtitle: 'Arka plan müziği',
    about: 'Hakkında',
    version: 'Sürüm 1.0.0',
    aboutDesc: 'Blokları doğru zamanda bırakarak kuleyi yükselt. Mükemmel yerleştirmelerle combo yap ve en yüksek skoru elde et!',
    language: 'Dil / Language',
    perfect: 'MÜKEMMEL!',
    good: 'İyi',
    miss: 'KAÇTI!',
    combo: 'Kombo',
    maxCombo: 'Max Kombo',
    perfectCount: 'Mükemmel',
    resetStats: 'İstatistikleri Sıfırla',
    gamesPlayed: 'Oynanan Oyun',
    highestLevel: 'En Yüksek Seviye',
    totalScore: 'Toplam Skor',
    averageScore: 'Ortalama Skor',
    easy: 'Kolay',
    medium: 'Orta',
    hard: 'Zor',
    insane: 'İmkansız',
    shop: 'Dükkan',
    coins: 'Coin',
    buy: 'Satın Al',
    equipped: 'Donatıldı',
    equip: 'Donat',
    locked: 'Kilitli',
    notEnoughCoins: 'Yeterli coin yok!',
    skinDefault: 'Varsayılan',
    skinClassic: 'Klasik',
    skinHologram: 'Hologram',
    skinIce: 'Buz',
    coinsEarned: 'Kazanılan Coin',
    classicMode: 'Klasik Mod',
    timeRush: 'Zamana Karşı',
    timeLeft: 'Kalan Süre',
    selectMode: 'Mod Seç',
    skins: 'Görünümler',
    powerups: 'Yetenekler',
    weatherEffects: 'Görsel Efektler',
    weatherEffectsSubtitle: 'Hava durumu ve parçacık efektlerini aç/kapat',
    privacyPolicy: 'Gizlilik Politikası',
    dataCollection: 'Veri Toplama',
    dataUsage: 'Veri Kullanımı',
    dataStorage: 'Veri Saklama',
    yourRights: 'Haklarınız',
    privacyText1: 'Bu oyun, o deneyimini iyileştirmek için minimum düzeyde veri toplar. Toplanan veriler arasında oyun istatistikleri (skor, seviye, oynama süresi) ve cihaz bilgileri yer alır.',
    privacyText2: 'Toplanan veriler yalnızca oyun deneyimini geliştirmek, istatistikleri takip etmek ve size özel içerik sunmak için kullanılır. Veriler üçüncü taraflarla paylaşılmaz.',
    privacyText3: 'Tüm veriler yerel olarak cihazınızda saklanır ve istediğiniz zaman sıfırlanabilir. Sunucularımızda herhangi bir kişisel veri tutmuyoruz.',
    privacyText4: 'Verilerinizin silinmesini talep etme, veri dışa aktarma ve gizlilik tercihlerinizi güncelleme hakkına sahipsiniz. Bunun için bizimle iletişime geçebilirsiniz.',
    contactUs: 'İletişim',
    decline: 'Reddet',
    accept: 'Kabul Et',
    iAccept: 'Gizlilik politikasını okudum ve kabul ediyorum',
  ),
  AppLang.en: Loc(
    play: 'Play',
    settings: 'Settings',
    stats: 'Statistics',
    score: 'Score',
    level: 'Level',
    best: 'Best',
    newHighScore: 'New High Score!',
    gameOver: 'Game Over',
    tapToStart: 'Tap to Start',
    tapToDrop: 'Drop the block at the right time!',
    paused: 'Paused',
    continueGame: 'Continue',
    restart: 'Restart',
    menu: 'Main Menu',
    sound: 'Sound',
    soundSubtitle: 'In-game sound effects',
    vibration: 'Vibration',
    vibrationSubtitle: 'Haptic feedback',
    music: 'Music',
    musicSubtitle: 'Background music',
    about: 'About',
    version: 'Version 1.0.0',
    aboutDesc: 'Build the tower by dropping blocks at the perfect time. Make perfect placements to stack your combo and reach the highest score!',
    language: 'Language',
    perfect: 'PERFECT!',
    good: 'Good',
    miss: 'MISS!',
    combo: 'Combo',
    maxCombo: 'Max Combo',
    perfectCount: 'Perfects',
    resetStats: 'Reset Statistics',
    gamesPlayed: 'Games Played',
    highestLevel: 'Highest Level',
    totalScore: 'Total Score',
    averageScore: 'Average Score',
    easy: 'Easy',
    medium: 'Medium',
    hard: 'Hard',
    insane: 'Insane',
    shop: 'Shop',
    coins: 'Coins',
    buy: 'Buy',
    equipped: 'Equipped',
    equip: 'Equip',
    locked: 'Locked',
    notEnoughCoins: 'Not enough coins!',
    skinDefault: 'Default',
    skinClassic: 'Classic',
    skinHologram: 'Hologram',
    skinIce: 'Ice',
    coinsEarned: 'Coins Earned',
    classicMode: 'Classic Mode',
    timeRush: 'Time Rush',
    timeLeft: 'Time Left',
    selectMode: 'Select Mode',
    skins: 'Skins',
    powerups: 'Power-ups',
    weatherEffects: 'Weather Effects',
    weatherEffectsSubtitle: 'Toggle weather and particle effects',
    privacyPolicy: 'Privacy Policy',
    dataCollection: 'Data Collection',
    dataUsage: 'Data Usage',
    dataStorage: 'Data Storage',
    yourRights: 'Your Rights',
    privacyText1: 'This game collects minimal data to improve your gaming experience. Collected data includes game statistics (score, level, playtime) and device information.',
    privacyText2: 'The collected data is used solely to improve the game experience, track statistics, and provide personalized content. Data is not shared with third parties.',
    privacyText3: 'All data is stored locally on your device and can be reset at any time. We do not store any personal data on our servers.',
    privacyText4: 'You have the right to request deletion of your data, export data, and update your privacy preferences. Contact us for these requests.',
    contactUs: 'Contact Us',
    decline: 'Decline',
    accept: 'Accept',
    iAccept: 'I have read and accept the privacy policy',
  ),
  AppLang.de: Loc(
    play: 'Spielen',
    settings: 'Einstellungen',
    stats: 'Statistiken',
    score: 'Punktzahl',
    level: 'Level',
    best: 'Beste',
    newHighScore: 'Neuer Rekord!',
    gameOver: 'Spiel Vorbei',
    tapToStart: 'Tippen zum Starten',
    tapToDrop: 'Lass den Block zur richtigen Zeit fallen!',
    paused: 'Pausiert',
    continueGame: 'Weiter',
    restart: 'Neustart',
    menu: 'Hauptmenü',
    sound: 'Ton',
    soundSubtitle: 'Soundeffekte im Spiel',
    vibration: 'Vibration',
    vibrationSubtitle: 'Haptisches Feedback',
    music: 'Musik',
    musicSubtitle: 'Hintergrundmusik',
    about: 'Über',
    version: 'Version 1.0.0',
    aboutDesc: 'Bauen Sie den Turm, indem Sie Blöcke zur perfekten Zeit fallen lassen. Machen Sie perfekte Platzierungen für Combos und erreichen Sie die höchste Punktzahl!',
    language: 'Sprache',
    perfect: 'PERFEKT!',
    good: 'Gut',
    miss: 'VERFEHLT!',
    combo: 'Kombo',
    maxCombo: 'Max Kombo',
    perfectCount: 'Perfekt',
    resetStats: 'Statistiken zurücksetzen',
    gamesPlayed: 'Gespielte Spiele',
    highestLevel: 'Höchstes Level',
    totalScore: 'Gesamtpunktzahl',
    averageScore: 'Durchschnitt',
    easy: 'Leicht',
    medium: 'Mittel',
    hard: 'Schwer',
    insane: 'Wahnsinn',
    shop: 'Laden',
    coins: 'Münzen',
    buy: 'Kaufen',
    equipped: 'Ausgerüstet',
    equip: 'Ausrüsten',
    locked: 'Gesperrt',
    notEnoughCoins: 'Nicht genug Münzen!',
    skinDefault: 'Standard',
    skinClassic: 'Klassisch',
    skinHologram: 'Hologramm',
    skinIce: 'Eis',
    coinsEarned: 'Verdiente Münzen',
    classicMode: 'Klassischer Modus',
    timeRush: 'Zeitrennen',
    timeLeft: 'Verbleibende Zeit',
    selectMode: 'Modus wählen',
    skins: 'Skins',
    powerups: 'Power-ups',
    weatherEffects: 'Wettereffekte',
    weatherEffectsSubtitle: 'Wetter- und Partikeleffekte umschalten',
    privacyPolicy: 'Datenschutzrichtlinie',
    dataCollection: 'Datenerhebung',
    dataUsage: 'Datennutzung',
    dataStorage: 'Datenspeicherung',
    yourRights: 'Ihre Rechte',
    privacyText1: 'Dieses Spiel sammelt minimale Daten, um Ihr Spielerlebnis zu verbessern. Gesammelte Daten umfassen Spielstatistiken (Punktzahl, Level, Spielzeit) und Geräteinformationen.',
    privacyText2: 'Die gesammelten Daten werden ausschließlich zur Verbesserung des Spielerlebnisses, zur Verfolgung von Statistiken und zur Bereitstellung personalisierter Inhalte verwendet. Daten werden nicht an Dritte weitergegeben.',
    privacyText3: 'Alle Daten werden lokal auf Ihrem Gerät gespeichert und können jederzeit zurückgesetzt werden. Wir speichern keine persönlichen Daten auf unseren Servern.',
    privacyText4: 'Sie haben das Recht, die Löschung Ihrer Daten zu beantragen, Daten zu exportieren und Ihre Datenschutzeinstellungen zu aktualisieren. Kontaktieren Sie uns für diese Anfragen.',
    contactUs: 'Kontakt',
    decline: 'Ablehnen',
    accept: 'Akzeptieren',
    iAccept: 'Ich habe die Datenschutzrichtlinie gelesen und akzeptiere sie',
  ),
  AppLang.ru: Loc(
    play: 'Играть',
    settings: 'Настройки',
    stats: 'Статистика',
    score: 'Счет',
    level: 'Уровень',
    best: 'Лучший',
    newHighScore: 'Новый рекорд!',
    gameOver: 'Игра окончена',
    tapToStart: 'Нажмите, чтобы начать',
    tapToDrop: 'Бросайте блок в нужный момент!',
    paused: 'Пауза',
    continueGame: 'Продолжить',
    restart: 'Заново',
    menu: 'Главное меню',
    sound: 'Звук',
    soundSubtitle: 'Звуковые эффекты в игре',
    vibration: 'Вибрация',
    vibrationSubtitle: 'Тактильная отдача',
    music: 'Музыка',
    musicSubtitle: 'Фоновая музыка',
    about: 'Об игре',
    version: 'Версия 1.0.0',
    aboutDesc: 'Стройте башню, бросая блоки в идеальное время. Делайте идеальные броски, собирайте комбо и побивайте рекорды!',
    language: 'Язык',
    perfect: 'ИДЕАЛЬНО!',
    good: 'Хорошо',
    miss: 'ПРОМАХ!',
    combo: 'Комбо',
    maxCombo: 'Макс Комбо',
    perfectCount: 'Идеально',
    resetStats: 'Сбросить статистику',
    gamesPlayed: 'Игры сыграны',
    highestLevel: 'Высший уровень',
    totalScore: 'Общий счет',
    averageScore: 'Средний счет',
    easy: 'Легкий',
    medium: 'Средний',
    hard: 'Тяжелый',
    insane: 'Безумный',
    shop: 'Магазин',
    coins: 'Монеты',
    buy: 'Купить',
    equipped: 'Надето',
    equip: 'Надеть',
    locked: 'Заблокирован',
    notEnoughCoins: 'Недостаточно монет!',
    skinDefault: 'Стандартный',
    skinClassic: 'Классический',
    skinHologram: 'Голограмма',
    skinIce: 'Лёд',
    coinsEarned: 'Заработано монет',
    classicMode: 'Классический режим',
    timeRush: 'На время',
    timeLeft: 'Осталось',
    selectMode: 'Выбор режима',
    skins: 'Облики',
    powerups: 'Улучшения',
    weatherEffects: 'Эффекты погоды',
    weatherEffectsSubtitle: 'Вкл/выкл эффекты погоды и частиц',
    privacyPolicy: 'Политика конфиденциальности',
    dataCollection: 'Сбор данных',
    dataUsage: 'Использование данных',
    dataStorage: 'Хранение данных',
    yourRights: 'Ваши права',
    privacyText1: 'Эта игра собирает минимальные данные для улучшения вашего игрового опыта. Собранные данные включают статистику игры (очки, уровень, время игры) и информацию об устройстве.',
    privacyText2: 'Собранные данные используются исключительно для улучшения игрового опыта, отслеживания статистики и предоставления персонализированного контента. Данные не передаются третьим лицам.',
    privacyText3: 'Все данные хранятся локально на вашем устройстве и могут быть сброшены в любое время. Мы не храним личные данные на наших серверах.',
    privacyText4: 'Вы имеете право запросить удаление ваших данных, экспортировать данные и обновить настройки конфиденциальности. Свяжитесь с нами для этих запросов.',
    contactUs: 'Связаться',
    decline: 'Отклонить',
    accept: 'Принять',
    iAccept: 'Я прочитал и принимаю политику конфиденциальности',
  ),
};

class LocalizationNotifier extends StateNotifier<AppLang> {
  final StorageService _storageService;
  
  LocalizationNotifier(this._storageService) : super(AppLang.tr) {
    _loadLanguage();
  }
  
  void _loadLanguage() {
    final l = _storageService.getString('app_lang');
    if (l != null) {
      if (l == 'en') {
        state = AppLang.en;
      } else if (l == 'de') {
        state = AppLang.de;
      } else if (l == 'ru') {
        state = AppLang.ru;
      } else {
        state = AppLang.tr;
      }
    }
  }

  void setLanguage(AppLang lang) {
    state = lang;
    _storageService.setString('app_lang', lang.name);
  }
}


final localizationNotifierProvider = StateNotifierProvider<LocalizationNotifier, AppLang>((ref) {
  return LocalizationNotifier(ref.read(storageServiceProvider));
});

final locProvider = Provider<Loc>((ref) {
  final lang = ref.watch(localizationNotifierProvider);
  return _translations[lang] ?? _translations[AppLang.en]!;
});
