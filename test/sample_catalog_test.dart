import 'package:dsx_drum_kendang/audio/sample_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes twelve samples for each of six presets', () {
    expect(SampleCatalog.presets, hasLength(6));
    for (final preset in SampleCatalog.presets) {
      expect(preset.samples, hasLength(12));
    }
  });
}
