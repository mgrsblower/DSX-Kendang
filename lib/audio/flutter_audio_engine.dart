import 'package:audioplayers/audioplayers.dart';

import 'audio_engine.dart';
import 'sample_catalog.dart';

class FlutterAudioEngine implements AudioEngine {
  static const int _voiceCount = 16;
  final List<AudioPlayer> _players = [];
  final Map<String, Source> _sourceCache = {};
  int _nextPlayerIndex = 0;
  bool _disposed = false;
  bool _configured = false;

  void _configureGlobalAudio() {
    if (_configured) return;
    _configured = true;
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (_) {
      // ignore on environments where global context is unsupported
    }
  }

  AudioPlayer _getPlayer() {
    _configureGlobalAudio();
    if (_players.length < _voiceCount) {
      final player = AudioPlayer();
      player.setPlayerMode(PlayerMode.lowLatency);
      player.setReleaseMode(ReleaseMode.stop);
      _players.add(player);
      return player;
    }
    final player = _players[_nextPlayerIndex];
    _nextPlayerIndex = (_nextPlayerIndex + 1) % _players.length;
    return player;
  }

  Source _resolveSource(SampleRef sample) {
    return _sourceCache.putIfAbsent(sample.assetPath, () {
      if (sample.assetPath.startsWith('assets/')) {
        return AssetSource(sample.assetPath.replaceFirst('assets/', ''));
      }
      return DeviceFileSource(sample.assetPath);
    });
  }

  @override
  Future<void> preload(Preset preset) async {
    _ensureActive();
    _configureGlobalAudio();
    for (final sample in preset.samples) {
      _resolveSource(sample);
    }
    while (_players.length < _voiceCount) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      _players.add(player);
    }
  }

  @override
  Future<void> play(SampleRef sample, double volume) async {
    _ensureActive();
    final player = _getPlayer();
    final source = _resolveSource(sample);
    await player.setVolume(volume.clamp(0.0, 1.0));
    await player.play(source, mode: PlayerMode.lowLatency);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final player in _players) {
      await player.dispose();
    }
    _players.clear();
    _sourceCache.clear();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('Audio engine has been disposed');
    }
  }
}
