import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with twelve pads and preset one', () {
    final state = DrumPadState();

    expect(state.activePresetIndex, 0);
    expect(state.padVolumes, hasLength(12));
    expect(state.orderedPadIndices(), List<int>.generate(12, (i) => i));
  });

  test('selects one of six presets and rejects invalid indices', () {
    final state = DrumPadState();

    state.selectPreset(5);
    expect(state.activePresetIndex, 5);
    expect(() => state.selectPreset(6), throwsRangeError);
    expect(() => state.selectPreset(-1), throwsRangeError);
  });

  test('clamps master and pad volume to the supported range', () {
    final state = DrumPadState();

    state.setMasterVolume(2);
    state.setPadVolume(0, -1);

    expect(state.masterVolume, 1);
    expect(state.padVolumes[0], 0);
  });

  test('reverses pad order in left-handed mode', () {
    final state = DrumPadState()..leftHanded = true;

    expect(state.orderedPadIndices(), List<int>.generate(12, (i) => 11 - i));
  });
}
