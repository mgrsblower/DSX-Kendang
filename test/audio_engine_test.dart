import 'package:dsx_drum_kendang/audio/audio_engine.dart';
import 'package:dsx_drum_kendang/audio/sample_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records preload and overlapping play requests', () async {
    final engine = RecordingAudioEngine();
    final sample = SampleCatalog.presets.first.samples.first;

    await engine.preload(SampleCatalog.presets.first);
    await Future.wait([
      engine.play(sample, 0.25),
      engine.play(sample, 0.75),
    ]);

    expect(engine.preloadedPreset, SampleCatalog.presets.first);
    expect(engine.playedVolumes, [0.25, 0.75]);
  });

  test('dispose prevents later playback', () async {
    final engine = RecordingAudioEngine();
    await engine.dispose();

    expect(() => engine.play(SampleCatalog.presets.first.samples.first, 1),
        throwsStateError);
  });
}
