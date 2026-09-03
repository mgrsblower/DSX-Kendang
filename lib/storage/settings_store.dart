import 'package:shared_preferences/shared_preferences.dart';

import '../features/drum_pad/drum_pad_state.dart';

class SettingsStore {
  const SettingsStore(this._preferences);

  final SharedPreferences _preferences;

  Future<DrumPadState> load() async {
    final preset = _readInt('active_preset');
    final master = _readDouble('master_volume');
    final rawVolumes = _readStringList('pad_volumes');
    final volumes = rawVolumes?.map(double.tryParse).toList();
    final candidate = volumes;
    final hasValidVolumes = candidate != null &&
        candidate.length == DrumPadState.padCount &&
        candidate.every((value) => value?.isFinite == true);
    final state = DrumPadState(
      activePresetIndex: preset != null && preset >= 0 && preset < DrumPadState.presetCount
          ? preset
          : 0,
      masterVolume: master != null && master.isFinite ? master : 0.5,
      padVolumes: hasValidVolumes ? candidate.cast<double>() : null,
      leftHanded: _readBool('left_handed') ?? false,
    );
    return state;
  }

  int? _readInt(String key) {
    final value = _preferences.get(key);
    return value is int ? value : null;
  }

  double? _readDouble(String key) {
    final value = _preferences.get(key);
    return value is double ? value : null;
  }

  List<String>? _readStringList(String key) {
    final value = _preferences.get(key);
    return value is List<String> ? value : null;
  }

  bool? _readBool(String key) {
    final value = _preferences.get(key);
    return value is bool ? value : null;
  }

  Future<void> save(DrumPadState state) async {
    await _preferences.setInt('active_preset', state.activePresetIndex);
    await _preferences.setDouble('master_volume', state.masterVolume);
    await _preferences.setStringList(
      'pad_volumes',
      state.padVolumes.map((value) => value.toString()).toList(),
    );
    await _preferences.setBool('left_handed', state.leftHanded);
  }
}
