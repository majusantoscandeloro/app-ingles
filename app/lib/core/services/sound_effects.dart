import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect {
  correct('sounds/correct.wav'),
  wrong('sounds/wrong.wav'),
  almost('sounds/almost.wav'),
  win('sounds/win.wav'),
  perfect('sounds/perfect.wav'),
  lose('sounds/lose.wav');

  const SoundEffect(this.asset);
  final String asset;
}

/// Efeitos curtos de acerto, erro e fim de lição.
///
/// A sessão de áudio fica igual à do TTS (`playAndRecord` + mix), para o som
/// não derrubar a fala nem o microfone no meio da lição.
class SoundEffects {
  SoundEffects() {
    _ready = _prepare();
  }

  late final Future<void> _ready;
  final Map<SoundEffect, AudioPlayer> _players = {};

  Future<void> _prepare() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.allowBluetooth,
              AVAudioSessionOptions.allowBluetoothA2DP,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Contexto de áudio falhou: $e');
    }

    for (final effect in SoundEffect.values) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_volume(effect));
      await player.setSource(AssetSource(effect.asset));
      _players[effect] = player;
    }
  }

  double _volume(SoundEffect effect) => switch (effect) {
        SoundEffect.wrong || SoundEffect.lose => 0.7,
        SoundEffect.almost => 0.75,
        _ => 0.85,
      };

  Future<void> play(SoundEffect effect) async {
    try {
      await _ready;
      final player = _players[effect];
      if (player == null) return;
      await player.stop();
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      debugPrint('Efeito sonoro falhou: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _ready;
    } catch (_) {}
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
