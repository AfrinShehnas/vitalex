import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool isSpeaking = false;

  // Safety: Max 5000 chars to prevent freeze
  static const int _maxCharLimit = 5000;

  Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      isSpeaking = false;
    });

    _flutterTts.setErrorHandler((error) {
      print('TTS Error: $error');
      isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      isSpeaking = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop any current speech first
    await stop();

    // Truncate long text
    String safeText = text;
    if (text.length > _maxCharLimit) {
      safeText = text.substring(0, _maxCharLimit);
    }

    isSpeaking = true;

    try {
      await _flutterTts.speak(safeText);
    } catch (e) {
      print('TTS Speak Error: $e');
      isSpeaking = false;
    }
  }

  Future<void> stop() async {
    try {
      isSpeaking = false;
      await _flutterTts.stop();
    } catch (e) {
      print('TTS Stop Error: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS Dispose Error: $e');
    }
  }
}