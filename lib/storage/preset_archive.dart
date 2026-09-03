import 'dart:io';

import 'package:archive/archive.dart';

class PresetArchive {
  const PresetArchive();

  Future<void> save(
    File destination,
    int setNumber,
    Map<int, List<int>> pads,
  ) async {
    await destination.writeAsBytes(encode(setNumber, pads));
  }

  List<int> encode(int setNumber, Map<int, List<int>> pads) {
    final archive = Archive()
      ..addFile(
        ArchiveFile.string('info.txt', 'MGR Drum Kendang Set $setNumber'),
      );
    for (final entry in pads.entries) {
      archive.addFile(
        ArchiveFile.bytes('set${setNumber}_pad_${entry.key}.dat', entry.value),
      );
    }
    return ZipEncoder().encode(archive);
  }

  Future<Map<int, List<int>>> read(File source) async {
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    final pads = <int, List<int>>{};
    for (final entry in archive.files) {
      final match = RegExp(
        r'(?:set\d+_)?pad_(\d+)\.dat$',
        caseSensitive: false,
      ).firstMatch(entry.name);
      if (match == null || !entry.isFile) continue;
      final pad = int.tryParse(match.group(1)!);
      final bytes = entry.readBytes();
      if (pad != null &&
          pad >= 1 &&
          pad <= 12 &&
          bytes != null &&
          bytes.length >= 12) {
        pads[pad - 1] = bytes;
      }
    }
    return pads;
  }
}
