# Block Tower - 3D Physics Blok Yerleştirme Oyunu

![Flutter](https://img.shields.io/badge/Flutter-3.11-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%26%20iOS-orange)

## 📱 Oyun Hakkında

**Block Tower**, fizik tabanlı bir blok istifleme oyunudur. Oyuncu, hareket eden blokları doğru zamanda bırakarak kuleyi yukarı doğru inşa eder. Her 3 blokta bir seviye artar ve oyun zorlaşır.

### 🎮 Nasıl Oynanır

1. **Başlat**: Ana menüden "Play" butonuna tıkla
2. **Oyna**: Blok yatay olarak hareket ederken ekrana dokunarak bırak
3. **Yerleştir**: Bloku platformun veya üstteki blokların üzerine denk getirmeye çalış
4. **Skor Kazan**:
   - **Mükemmel** (%95+ örtüşme): Tam puan + combo bonusu
   - **İyi** (%70-95 örtüşme): Tam puan
   - **Normal** (<%70 örtüşme): Yarım puan
   - **Kaçırırsan**: Oyun biter
5. **Seviye Atla**: Her 3 blok yerleştirdiğinde seviye artar
6. **Combo**: Ardışık mükemmel yerleştirmeler bonus puan kazandırır

---

## 🛠️ Kullanılan Teknolojiler

### Flutter Paketleri

| Paket | Versiyon | Kullanım Amacı |
|-------|----------|----------------|
| `flame` | ^1.18.0 | 2D oyun motoru |
| `flutter_riverpod` | ^2.5.1 | State management |
| `shared_preferences` | ^2.2.3 | Yerel veri saklama |
| `audioplayers` | ^6.0.0 | Ses efektleri |
| `vibration` | ^2.0.0 | Dokunsal geri bildirim |
| `flutter_animate` | ^4.5.0 | UI animasyonları |
| `google_fonts` | ^6.2.1 | Poppins fontu |

### Proje Yapısı

```
blok/
├── lib/
│   ├── main.dart                 # Uygulama giriş noktası
│   ├── app.dart                  # MaterialApp widget
│   ├── core/
│   │   ├── constants.dart        # Renkler, stringler, boyutlar
│   │   └── theme.dart           # Tema yapılandırması
│   ├── game/
│   │   ├── tower_game.dart      # Ana oyun mantığı
│   │   └── levels/
│   │       └── level_config.dart # 55 seviye yapılandırması
│   ├── data/
│   │   └── models/
│   │       └── player_stats.dart # İstatistik modeli
│   ├── services/
│   │   ├── storage_service.dart # Veri saklama
│   │   ├── audio_service.dart   # Ses yönetimi
│   │   └── haptic_service.dart  # Titreşim
│   ├── providers/
│   │   └── game_provider.dart   # Riverpod state
│   └── ui/
│       ├── screens/
│       │   ├── menu_screen.dart   # Ana menü
│       │   ├── game_screen.dart   # Oyun ekranı
│       │   ├── stats_screen.dart  # İstatistikler
│       │   └── settings_screen.dart # Ayarlar
│       └── widgets/
│           ├── score_display.dart   # Skor göstergesi
│           ├── combo_indicator.dart # Combo göstergesi
│           └── game_over_dialog.dart # Game over dialog
├── assets/
│   └── audio/                    # Ses dosyaları (eklenmeli)
├── android/                     # Android platformu
├── ios/                          # iOS platformu
├── pubspec.yaml                  # Proje yapılandırması
└── README.md                    # Bu dosya
```

---

## 🎯 Oyun Özellikleri

### ✅ Tamamlanan Özellikler

- [x] 55 zorluk seviyesi (Kolay → İmkansız)
- [x] Fizik tabanlı blok hareketi
- [x] Skor sistemi (base + combo bonusu)
- [x] Mükemmel/İyi/Normal yerleştirme algılama
- [x] Seviye atlama sistemi (her 3 blokta)
- [x] Kule yükseldikçe kamera hareketi
- [x] Oyun istatistikleri (high score, oyun sayısı, etc.)
- [x] Ana menü + UI
- [x] Ayarlar ekranı (ses, titreşim, müzik)
- [x] İstatistikler ekranı
- [x] Game over dialog
- [x] Animasyonlar
- [x] Dark theme UI

### ❌ Eksik Özellikler

- [ ] **Ses dosyaları** - `assets/audio/` klasörü boş
  - `place.mp3` - Blok yerleştirme sesi
  - `perfect.mp3` - Mükemmel yerleştirme sesi
  - `good.mp3` - İyi yerleştirme sesi
  - `miss.mp3` - Kaçırma sesi
  - `gameover.mp3` - Oyun bitişi sesi
  - `combo.mp3` - Combo sesi
  - `click.mp3` - Buton tıklama sesi
  - `music.mp3` - Arka plan müziği

- [ ] **Platform yeniden boyutlandırma** - Blok kısmi örtüşmede platform kırpılmıyor

- [ ] **Particle efektleri** - Yerleştirme efektleri yok

- [ ] **Reklamlar** - Monetization eklenmemiş

- [ ] **i18n** - Çoklu dil desteği yok

- [ ] **3D efekti** - Şu an 2D, perspective efekti eklenebilir

---

## 🎨 Tasarım

### Renk Paleti

```dart
primary: #6366F1      // Indigo
secondary: #8B5CF6    // Purple
accent: #EC4899       // Pink
background: #0F172A  // Dark blue
surface: #1E293B     // Slate
success: #22C55E     // Green
warning: #FBBF24     // Amber
error: #EF4444       // Red
```

### Font

- **Poppins** (Google Fonts)
  - Bold: Başlıklar, skor
  - Regular: Gövde metinleri

### Seviye Zorlukları

| Seviye | Block Genişliği | Hız | Yerçekimi |
|--------|-----------------|-----|-----------|
| 1-10   | 120 → 60 px     | 150-285 | 500-800 |
| 11-25  | 60 → 30 px      | 300-600 | 800-1400 |
| 26-40  | 30 → 15 px      | 600-1050 | 1400-2200 |
| 41-55  | 15 → 8 px       | 1050-2000 | 2200-5000 |

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler

- Flutter SDK 3.11+
- Dart SDK 3.11+
- Android SDK / Xcode (iOS için)

### Adımlar

1. **Bağımlılıkları yükle**:
   ```bash
   cd blok
   flutter pub get
   ```

2. **Ses dosyaları ekle** (opsiyonel):
   - `assets/audio/` klasörüne .mp3 dosyaları ekle

3. **Çalıştır**:
   ```bash
   flutter run
   ```

4. **APK oluştur**:
   ```bash
   flutter build apk --debug    # Debug APK
   flutter build apk --release  # Release APK
   ```

### APK Konumu

```
blok/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔧 Gelecek Geliştirmeler

1. **Ses sistemi** - Ses dosyaları eklenecek
2. **Particle efektleri** - Yerleştirme animasyonları
3. **Platform kırpma** - Kısmi örtüşmede blok kırpma
4. **Power-ups** - Bonus özellikler
5. **Leaderboard** - Global skor tablosu
6. **Themes** - Tema seçimi
7. **Hikaye modu** - Seviye bazlı missions

---

## 📄 Lisans

MIT License - Copyright (c) 2026

---

## 📞 İletişim

Herhangi bir sorunuz veya öneriniz için issue oluşturabilirsiniz.
