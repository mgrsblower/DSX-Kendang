import 'package:audioplayers/audioplayers.dart';

import 'audio_engine.dart';
import 'sample_catalog.dart';

class FlutterAudioEngine implements AudioEngine {
  final List<AudioPlayer> _players = [];
  bool _disposed = false;

  @override
  Future<void> preload(Preset preset) async {
    _ensureActive();
  }

  @override
  Future<void> play(SampleRef sample, double volume) async {
    _ensureActive();
    final player = AudioPlayer();
    _players.add(player);
    player.onPlayerComplete.first.then((_) async {
      _players.remove(player);
      await player.dispose();
    });
    await player.setVolume(volume.clamp(0, 1).toDouble());
    await player.play(AssetSource(sample.assetPath.replaceFirst('assets/', '')));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final player in List<AudioPlayer>.from(_players)) {
      await player.dispose();
    }
    _players.clear();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('Audio engine has been disposed');
    }
  }
}
