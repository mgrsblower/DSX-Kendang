import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_state.dart';
import 'package:dsx_drum_kendang/storage/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves and loads MVP settings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SettingsStore(preferences);
    final state = DrumPadState()..leftHanded = true;
    state.selectPreset(4);
    state.setMasterVolume(0.8);
    state.setPadVolume(2, 0.3);

    await store.save(state);
    final loaded = await store.load();

    expect(loaded.activePresetIndex, 4);
    expect(loaded.masterVolume, closeTo(0.8, 0.001));
    expect(loaded.padVolumes[2], closeTo(0.3, 0.001));
    expect(loaded.leftHanded, isTrue);
  });

  test('uses safe defaults for invalid settings', () async {
    SharedPreferences.setMockInitialValues({
      'active_preset': 99,
      'master_volume': -4,
      'pad_volumes': ['bad'],
      'left_handed': 'bad',
    });
    final preferences = await SharedPreferences.getInstance();

    final loaded = await SettingsStore(preferences).load();

    expect(loaded.activePresetIndex, 0);
    expect(loaded.masterVolume, 0.5);
    expect(loaded.padVolumes, everyElement(1));
    expect(loaded.leftHanded, isFalse);
  });
}
