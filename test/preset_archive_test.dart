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
}
