import 'package:dsx_drum_kendang/audio/sample_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes twelve samples for each of six presets', () {
    expect(SampleCatalog.presets, hasLength(6));
    for (final preset in SampleCatalog.presets) {
      expect(preset.samples, hasLength(12));
    }
  });

  test('exposes 99+ authentic DSX sound collection', () {
    expect(SampleCatalog.allBuiltinSounds.length, greaterThanOrEqualTo(99));
    expect(
      SampleCatalog.allBuiltinSounds.any((s) => s.name.contains('Tarik Cak')),
      isTrue,
    );
    expect(
      SampleCatalog.allBuiltinSounds.any((s) => s.name.contains('Jaranan')),
      isTrue,
    );
    expect(
      SampleCatalog.allBuiltinSounds.any((s) => s.name.contains('Langgam Jawa')),
      isTrue,
    );
  });
}
