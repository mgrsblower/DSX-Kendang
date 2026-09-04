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

  test('saves and loads skin settings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SettingsStore(preferences);

    final skinSettings = const SavedSkinSettings(
      activePanelAsset: 'assets/ui/panel_kayu.webp',
      globalPadSkin: 'batik_hd',
      customPadAssets: {
        0: 'assets/ui/pad_metal.webp',
        5: 'assets/ui/pad_karakter.webp',
      },
      panelOpacity: 0.8,
      padOpacity: 0.25,
    );

    await store.saveSkinSettings(skinSettings);
    final loaded = await store.loadSkinSettings();

    expect(loaded.activePanelAsset, 'assets/ui/panel_kayu.webp');
    expect(loaded.globalPadSkin, 'batik_hd');
    expect(loaded.customPadAssets[0], 'assets/ui/pad_metal.webp');
    expect(loaded.customPadAssets[5], 'assets/ui/pad_karakter.webp');
    expect(loaded.panelOpacity, closeTo(0.8, 0.001));
    expect(loaded.padOpacity, closeTo(0.25, 0.001));
  });

  test('skin settings loads safe default when empty or corrupt', () async {
    SharedPreferences.setMockInitialValues({
      'custom_pad_assets': 'invalid-json',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SettingsStore(preferences);

    final loaded = await store.loadSkinSettings();
    expect(loaded.activePanelAsset, isNull);
    expect(loaded.globalPadSkin, 'default');
    expect(loaded.customPadAssets, isEmpty);
  });
}
