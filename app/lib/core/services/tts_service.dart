import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech nativo do dispositivo (custo zero).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _init;

  static const _normalRate = 0.45;
  static const _slowRate = 0.25;

  Future<void> _ensureInit() => _init ??= _configure();

  Future<void> _configure() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      if (!kIsWeb && Platform.isIOS) {
        await _tts.setSharedInstance(true);
        // playAndRecord + defaultToSpeaker evita áudio baixo após usar o microfone.
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playAndRecord,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }
    } catch (e) {
      debugPrint('TTS init falhou: $e');
    }
  }

  Future<void> speak(String text, {bool slow = false}) async {
    if (text.trim().isEmpty) return;
    await _ensureInit();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(slow ? _slowRate : _normalRate);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak falhou: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
