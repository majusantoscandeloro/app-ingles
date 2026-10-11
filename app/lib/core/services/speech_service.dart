import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechAvailability { unknown, available, unavailable }

/// Speech-to-Text nativo. Responde apenas "o que foi reconhecido", sem avaliação fonética.
class SpeechService {
  final SpeechToText _stt = SpeechToText();
  SpeechAvailability _availability = SpeechAvailability.unknown;
  String? _localeId;

  final ValueNotifier<bool> isListening = ValueNotifier(false);
  final ValueNotifier<String?> lastError = ValueNotifier(null);

  Future<bool> ensureInitialized() async {
    if (_availability == SpeechAvailability.available) return true;
    try {
      final ok = await _stt.initialize(
        onStatus: (status) => isListening.value = status == SpeechToText.listeningStatus,
        onError: (SpeechRecognitionError e) {
          lastError.value = e.errorMsg;
          isListening.value = false;
        },
      );
      _availability = ok ? SpeechAvailability.available : SpeechAvailability.unavailable;
      if (ok) await _pickEnglishLocale();
      return ok;
    } catch (e) {
      debugPrint('STT init falhou: $e');
      _availability = SpeechAvailability.unavailable;
      return false;
    }
  }

  Future<void> _pickEnglishLocale() async {
    final locales = await _stt.locales();
    String? match(bool Function(String id) test) =>
        locales.map((l) => l.localeId).where(test).cast<String?>().firstWhere((_) => true, orElse: () => null);
    _localeId = match((id) => id.replaceAll('-', '_').toLowerCase() == 'en_us') ??
        match((id) => id.toLowerCase().startsWith('en')) ??
        'en_US';
  }

  Future<void> listen({required void Function(String words, bool isFinal) onResult}) async {
    if (!await ensureInitialized()) return;
    lastError.value = null;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
    isListening.value = true;
  }

  Future<void> stop() async {
    await _stt.stop();
    isListening.value = false;
  }

  Future<void> cancel() async {
    await _stt.cancel();
    isListening.value = false;
  }
}
