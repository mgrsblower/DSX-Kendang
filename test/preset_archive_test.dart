import 'dart:io';

import 'package:dsx_drum_kendang/storage/preset_archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips original DSX pad entry naming', () async {
    final directory = await Directory.systemTemp.createTemp('mgr-preset-test-');
    try {
      final file = File('${directory.path}${Platform.pathSeparator}set3.dsx');
      final source = <int>[0x52, 0x49, 0x46, 0x46, ...List<int>.filled(20, 7)];
      await const PresetArchive().save(file, 3, {2: source, 11: source});

      final loaded = await const PresetArchive().read(file);
      expect(loaded.keys, containsAll(<int>[1, 10]));
      expect(loaded[1], source);
      expect(loaded[10], source);
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('detects audio extensions from magic bytes correctly', () {
    expect(PresetArchive.detectAudioExtension([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0]), 'wav');
    expect(PresetArchive.detectAudioExtension([0x4F, 0x67, 0x67, 0x53, 0, 0, 0, 0]), 'ogg');
    expect(PresetArchive.detectAudioExtension([0x49, 0x44, 0x33, 0, 0, 0, 0, 0]), 'mp3');
    expect(PresetArchive.detectAudioExtension([0xFF, 0xFB, 0, 0, 0, 0, 0, 0]), 'mp3');
    expect(PresetArchive.detectAudioExtension([0, 0, 0, 0x20, 0x66, 0x74, 0x79, 0x70]), 'm4a');
    expect(PresetArchive.detectAudioExtension([0x01, 0x02, 0x03]), 'wav');
  });

  test('parses diverse naming schemes found in user-shared DSX files', () {
    final filenames = [
      'set1_pad_1.dat',
      'set2_pad3.wav',
      'pad_5.mp3',
      'pad7.ogg',
      'p9.aac',
      '12.wav',
      'set4_p2.m4a',
    ];
    final archive = const PresetArchive();
    final parsedPads = <int>[];
    for (final name in filenames) {
      for (final regex in [
        RegExp(r'(?:set\d+_)?(?:pad_?|p)(\d+)\.(?:dat|wav|mp3|ogg|m4a|aac)$', caseSensitive: false),
        RegExp(r'^(\d{1,2})\.(?:dat|wav|mp3|ogg|m4a|aac)$', caseSensitive: false),
      ]) {
        final match = regex.firstMatch(name);
        if (match != null) {
          final padNumber = int.tryParse(match.group(1)!);
          if (padNumber != null && padNumber >= 1 && padNumber <= 12) {
            parsedPads.add(padNumber - 1);
            break;
          }
        }
      }
    }
    expect(parsedPads, equals([0, 2, 4, 6, 8, 11, 1]));
  });
}
