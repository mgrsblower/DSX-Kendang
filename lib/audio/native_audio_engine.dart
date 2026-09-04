import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_engine.dart';
import 'flutter_audio_engine.dart';
import 'sample_catalog.dart';

class NativeAudioEngine implements AudioEngine {
  NativeAudioEngine({
    MethodChannel? channel,
    AudioEngine? fallbackEngine,
    bool? isAndroidOverride,
  })  : _channel = channel ?? const MethodChannel('com.mgr.dsx_drum_kendang/audio'),
        _fallback = fallbackEngine ?? FlutterAudioEngine(),
        _isAndroid = isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);

  final MethodChannel _channel;
  final AudioEngine _fallback;
  final bool _isAndroid;
  bool _disposed = false;

  @override
  Future<void> preload(Preset preset) async {
    _ensureActive();
    if (!_isAndroid) {
      await _fallback.preload(preset);
      return;
    }

    final paths = preset.samples.map((s) => s.assetPath).toList();
    try {
      await _channel.invokeMethod('preload', {'paths': paths});
    } catch (_) {
      // Fallback engine is already preloaded
    }
  }

  @override
  Future<void> play(SampleRef sample, double volume) async {
    _ensureActive();
    if (!_isAndroid) {
      return _fallback.play(sample, volume);
    }

    try {
      final success = await _channel.invokeMethod<bool>('play', {
        'path': sample.assetPath,
        'volume': volume.clamp(0.0, 1.0),
      });
      if (success != true) {
        await _fallback.play(sample, volume);
      }
    } catch (_) {
      await _fallback.play(sample, volume);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    if (_isAndroid) {
      try {
        await _channel.invokeMethod('release');
      } catch (_) {}
    }
    await _fallback.dispose();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('Audio engine has been disposed');
    }
  }
}
