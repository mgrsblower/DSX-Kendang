import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/drum_pad/drum_pad_state.dart';

class SavedSkinSettings {
  final String? activePanelAsset;
  final String globalPadSkin;
  final Map<int, String> customPadAssets;
  final double panelOpacity;
  final double padOpacity;

  const SavedSkinSettings({
    this.activePanelAsset,
    required this.globalPadSkin,
    required this.customPadAssets,
    this.panelOpacity = 0.5,
    this.padOpacity = 0.12,
  });
}

class SettingsStore {
  const SettingsStore(this._preferences);

  final SharedPreferences _preferences;

  Future<DrumPadState> load() async {
    final preset = _readInt('active_preset');
    final master = _readDouble('master_volume');
    final rawVolumes = _readStringList('pad_volumes');
    final volumes = rawVolumes?.map(double.tryParse).toList();
    final candidate = volumes;
    final hasValidVolumes =
        candidate != null &&
        candidate.length == DrumPadState.padCount &&
        candidate.every((value) => value?.isFinite == true);
    final state = DrumPadState(
      activePresetIndex:
          preset != null && preset >= 0 && preset < DrumPadState.presetCount
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

  String? _readString(String key) {
    final value = _preferences.get(key);
    return value is String ? value : null;
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

  Future<void> saveSkinSettings(SavedSkinSettings settings) async {
    if (settings.activePanelAsset != null) {
      await _preferences.setString(
        'active_panel_asset',
        settings.activePanelAsset!,
      );
    } else {
      await _preferences.remove('active_panel_asset');
    }

    await _preferences.setString(
      'global_pad_skin',
      settings.globalPadSkin,
    );

    await _preferences.setDouble('panel_opacity', settings.panelOpacity);
    await _preferences.setDouble('pad_opacity', settings.padOpacity);

    final map = settings.customPadAssets.map(
      (k, v) => MapEntry(k.toString(), v),
    );
    await _preferences.setString('custom_pad_assets', jsonEncode(map));
  }

  Future<SavedSkinSettings> loadSkinSettings() async {
    final panel = _readString('active_panel_asset');
    final globalPad = _readString('global_pad_skin') ?? 'default';
    final customRaw = _readString('custom_pad_assets');
    final panelOpacity = _readDouble('panel_opacity') ?? 0.5;
    final padOpacity = _readDouble('pad_opacity') ?? 0.12;

    final customPads = <int, String>{};
    if (customRaw != null) {
      try {
        final decoded = jsonDecode(customRaw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final key = int.tryParse(entry.key.toString());
            final val = entry.value?.toString();
            if (key != null && val != null && key >= 0 && key < DrumPadState.padCount) {
              customPads[key] = val;
            }
          }
        }
      } catch (_) {
        // ignore invalid json and return empty custom pads
      }
    }

    return SavedSkinSettings(
      activePanelAsset: panel,
      globalPadSkin: globalPad,
      customPadAssets: customPads,
      panelOpacity: panelOpacity,
      padOpacity: padOpacity,
    );
  }
}
