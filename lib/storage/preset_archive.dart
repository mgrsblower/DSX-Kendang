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
      final ext = detectAudioExtension(entry.value);
      archive.addFile(
        ArchiveFile.bytes('set${setNumber}_pad_${entry.key}.$ext', entry.value),
      );
    }
    return ZipEncoder().encode(archive);
  }

  Future<Map<int, List<int>>> read(File source) async {
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    final pads = <int, List<int>>{};
    for (final entry in archive.files) {
      if (!entry.isFile) continue;

      // Match patterns like:
      // set1_pad_1.dat, set1_pad1.wav, pad_1.dat, pad1.wav, p1.wav, etc.
      final match = RegExp(
        r'(?:set\d+_)?(?:pad_?|p)(\d+)\.(?:dat|wav|mp3|ogg|m4a|aac)$',
        caseSensitive: false,
      ).firstMatch(entry.name);

      if (match != null) {
        final pad = int.tryParse(match.group(1)!);
        final bytes = entry.readBytes();
        if (pad != null &&
            pad >= 1 &&
            pad <= 12 &&
            bytes != null &&
            bytes.length >= 12) {
          pads[pad - 1] = bytes;
          continue;
        }
      }

      // Match simple numeric naming like: "1.wav", "01.dat", "2.mp3"
      final simpleMatch = RegExp(
        r'^(\d{1,2})\.(?:dat|wav|mp3|ogg|m4a|aac)$',
        caseSensitive: false,
      ).firstMatch(entry.name);

      if (simpleMatch != null) {
        final pad = int.tryParse(simpleMatch.group(1)!);
        final bytes = entry.readBytes();
        if (pad != null &&
            pad >= 1 &&
            pad <= 12 &&
            bytes != null &&
            bytes.length >= 12) {
          pads[pad - 1] = bytes;
        }
      }
    }
    return pads;
  }

  /// Detects real audio container from byte magic numbers
  static String detectAudioExtension(List<int> bytes) {
    if (bytes.length >= 4) {
      // RIFF....WAVE -> .wav
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        return 'wav';
      }
      // OggS -> .ogg
      if (bytes[0] == 0x4F &&
          bytes[1] == 0x67 &&
          bytes[2] == 0x67 &&
          bytes[3] == 0x53) {
        return 'ogg';
      }
      // ID3 -> .mp3
      if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
        return 'mp3';
      }
      // MP3 sync word (0xFF 0xFB, 0xFF 0xF3, etc.)
      if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
        return 'mp3';
      }
    }
    if (bytes.length >= 8) {
      // ftyp -> .m4a
      if (bytes[4] == 0x66 &&
          bytes[5] == 0x74 &&
          bytes[6] == 0x79 &&
          bytes[7] == 0x70) {
        return 'm4a';
      }
    }
    // Default to wav
    return 'wav';
  }
}
