import 'package:dsx_drum_kendang/audio/audio_engine.dart';
import 'package:dsx_drum_kendang/audio/native_audio_engine.dart';
import 'package:dsx_drum_kendang/audio/sample_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeAudioEngine', () {
    const channelName = 'com.mgr.dsx_drum_kendang/audio_test';
    const channel = MethodChannel(channelName);
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        calls.add(methodCall);
        if (methodCall.method == 'play') {
          return true;
        }
        return true;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('preloads and plays via native channel when on Android', () async {
      final mockFallback = RecordingAudioEngine();
      final engine = NativeAudioEngine(
        channel: channel,
        fallbackEngine: mockFallback,
        isAndroidOverride: true,
      );

      final preset = SampleCatalog.presets.first;
      await engine.preload(preset);

      expect(mockFallback.preloadedPreset, preset);
      expect(calls.length, 1);
      expect(calls.first.method, 'preload');
      final preloadedPaths = (calls.first.arguments as Map)['paths'] as List;
      expect(preloadedPaths, hasLength(preset.samples.length));

      await engine.play(preset.samples.first, 0.85);

      expect(calls.length, 2);
      expect(calls[1].method, 'play');
      final playArgs = calls[1].arguments as Map;
      expect(playArgs['path'], preset.samples.first.assetPath);
      expect(playArgs['volume'], 0.85);
      // Fallback was not needed because native returned true
      expect(mockFallback.playedVolumes, isEmpty);

      await engine.dispose();
      expect(calls.last.method, 'release');
    });

    test('falls back to fallbackEngine when native play returns false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        calls.add(methodCall);
        if (methodCall.method == 'play') {
          return false;
        }
        return true;
      });

      final mockFallback = RecordingAudioEngine();
      final engine = NativeAudioEngine(
        channel: channel,
        fallbackEngine: mockFallback,
        isAndroidOverride: true,
      );

      final sample = SampleCatalog.presets.first.samples.first;
      await engine.play(sample, 0.75);

      expect(calls.length, 1);
      expect(calls.first.method, 'play');
      expect(mockFallback.playedVolumes, [0.75]);
    });

    test('delegates directly to fallback when not on Android', () async {
      final mockFallback = RecordingAudioEngine();
      final engine = NativeAudioEngine(
        channel: channel,
        fallbackEngine: mockFallback,
        isAndroidOverride: false,
      );

      final preset = SampleCatalog.presets.first;
      await engine.preload(preset);
      await engine.play(preset.samples.first, 0.9);

      expect(calls, isEmpty);
      expect(mockFallback.preloadedPreset, preset);
      expect(mockFallback.playedVolumes, [0.9]);
    });

    test('throws StateError when used after dispose', () async {
      final engine = NativeAudioEngine(
        channel: channel,
        fallbackEngine: RecordingAudioEngine(),
        isAndroidOverride: false,
      );
      await engine.dispose();

      expect(
        () => engine.play(SampleCatalog.presets.first.samples.first, 1.0),
        throwsA(isA<StateError>()),
      );
    });
  });
}
