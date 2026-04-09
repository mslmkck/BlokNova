import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.duckOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  // WAV oluşturucu (Bellekte ses verisi üretir)
  Uint8List _generateWav(double frequency, double duration, {double volume = 0.5, bool isNoise = false, bool isHarmonic = false}) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * duration).toInt();
    final data = Float32List(numSamples);
    final random = Random();

    for (int i = 0; i < numSamples; i++) {
      if (isNoise) {
        data[i] = (random.nextDouble() * 2 - 1) * volume;
      } else {
        // Main frequency
        double sample = sin(2 * pi * frequency * i / sampleRate);
        
        // Add Overtones for a more "Piano-like" rich sound
        if (isHarmonic) {
          sample += 0.5 * sin(2 * pi * (frequency * 2) * i / sampleRate);
          sample += 0.25 * sin(2 * pi * (frequency * 3) * i / sampleRate);
          sample /= 1.75; // Normalize
        }
        
        data[i] = sample * volume;
      }
      
      // Exponential Decay Envelope (Piano-like release)
      final t = i / numSamples;
      final envelope = exp(-t * 5.0); // Quick fade
      data[i] *= envelope;
    }

    // Convert Float32 to 16-bit PCM WAV
    final headerSize = 44;
    final byteData = ByteData(headerSize + numSamples * 2);
    
    // WAV Header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    byteData.setUint32(4, 36 + numSamples * 2, Endian.little);
    byteData.setUint8(8, 0x57); // W
    byteData.setUint8(9, 0x41); // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E
    
    // fmt subchunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6d); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // 
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, 1, Endian.little); // Mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);
    
    // data subchunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    byteData.setUint32(40, numSamples * 2, Endian.little);
    
    for (int i = 0; i < numSamples; i++) {
      final sample = (data[i] * 32767).toInt().clamp(-32768, 32767);
      byteData.setInt16(44 + i * 2, sample, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> _playGeneratedSfx(Uint8List bytes, {double volume = 0.5}) async {
    if (!_soundEnabled) return;
    try {
      // Windows platformu için çalmadan önce durdurup sıfırlamak stabiliteyi artırır
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(BytesSource(bytes));
    } catch (_) {
      // MediaEngine Shutdown gibi platform hatalarını sessizce yoksay
    }
  }

  // 12-Tone Scale (C4 to B4)
  static const List<double> _scale = [
    261.63, // C4
    277.18, // C#4
    293.66, // D4
    311.13, // D#4
    329.63, // E4
    349.23, // F4
    369.99, // F#4
    392.00, // G4
    415.30, // G#4
    440.00, // A4
    466.16, // A#4
    493.88, // B4
    523.25, // C5
  ];

  Future<void> playNote(int index, {bool isPerfect = false}) async {
    final noteIndex = index % _scale.length;
    final baseFreq = _scale[noteIndex];
    
    // Oktav atlama (Kule yükseldikçe daha ince notalar)
    final octave = (index / _scale.length).floor();
    final freq = baseFreq * pow(2, octave.clamp(0, 2));

    final bytes = _generateWav(
      freq, 
      isPerfect ? 0.4 : 0.2, 
      volume: isPerfect ? 0.6 : 0.4,
      isHarmonic: true
    );
    await _playGeneratedSfx(bytes);
  }

  Future<void> playPlace() async {
    // Handled by playNote now
  }

  Future<void> playPerfect(int combo) async {
    await playNote(combo, isPerfect: true);
  }

  Future<void> playGood() async {
    // Handled by playNote now
  }

  Future<void> playMiss() async {
    final bytes = _generateWav(100, 0.4, volume: 0.6, isNoise: true);
    await _playGeneratedSfx(bytes);
  }

  Future<void> playGameOver() async {
    // Daha dramatik ve "profesyonel" bir oyun bitti sesi (descending deep thud)
    final bytes = _generateWav(60, 1.2, volume: 0.8, isHarmonic: true); 
    await _playGeneratedSfx(bytes, volume: 1.0);
  }

  Future<void> playClick() async {
    final bytes = _generateWav(800, 0.05, volume: 0.2);
    await _playGeneratedSfx(bytes);
  }

  Future<void> playCombo(int combo) async {
    // Per combo special tings? 
    await playNote(combo, isPerfect: true);
  }

  Future<void> startMusic() async {
    if (!_musicEnabled) return;
    try {
       // Bazı cihazlarda AssetSource asenkron olarak takılabiliyor, yüklenmesini bekleyelim
       await _musicPlayer.setSourceAsset('audio/music.wav');
       await _musicPlayer.resume();
       await _musicPlayer.setVolume(0.3);
    } catch (_) {
      // Fallback: Daha gelişmiş bir sentetik ambiyans
      _playSyntheticAmbience();
    }
  }

  void _playSyntheticAmbience() async {
    final bytes = _generateWav(110, 2.0, volume: 0.1, isHarmonic: true);
    await _musicPlayer.play(BytesSource(bytes), volume: 0.1);
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _sfxPlayer.dispose();
      await _musicPlayer.dispose();
    } catch (_) {}
  }
}
