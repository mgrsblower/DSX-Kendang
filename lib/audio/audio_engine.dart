import 'sample_catalog.dart';

abstract interface class AudioEngine {
  Future<void> preload(Preset preset);

  Future<void> play(SampleRef sample, double volume);

  Future<void> dispose();
}

class RecordingAudioEngine implements AudioEngine {
  Preset? preloadedPreset;
  final List<double> playedVolumes = [];
  bool _disposed = false;

  @override
  Future<void> preload(Preset preset) async {
    _ensureActive();
    preloadedPreset = preset;
  }

  @override
  Future<void> play(SampleRef sample, double volume) async {
    _ensureActive();
    playedVolumes.add(volume);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('Audio engine has been disposed');
    }
  }
}
