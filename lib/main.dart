import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio/flutter_audio_engine.dart';
import 'features/drum_pad/drum_pad_page.dart';
import 'features/drum_pad/drum_pad_state.dart';
import 'storage/settings_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const DsxDrumKendangApp());
}

class DsxDrumKendangApp extends StatefulWidget {
  const DsxDrumKendangApp({super.key});

  @override
  State<DsxDrumKendangApp> createState() => _DsxDrumKendangAppState();
}

class _DsxDrumKendangAppState extends State<DsxDrumKendangApp> {
  final _state = DrumPadState();
  final _engine = FlutterAudioEngine();
  SettingsStore? _settingsStore;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final store = SettingsStore(preferences);
    final saved = await store.load();
    _state.selectPreset(saved.activePresetIndex);
    _state.setMasterVolume(saved.masterVolume);
    for (var index = 0; index < DrumPadState.padCount; index++) {
      _state.setPadVolume(index, saved.padVolumes[index]);
    }
    _state.leftHanded = saved.leftHanded;
    if (mounted) {
      setState(() => _settingsStore = store);
    }
  }

  Future<void> _saveSettings() async {
    final store = _settingsStore;
    if (store != null) await store.save(_state);
  }

  @override
  void dispose() {
    _saveSettings();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MGR Drum Kendang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      home: DrumPadPage(
        state: _state,
        engine: _engine,
        onStateChanged: _saveSettings,
      ),
    );
  }
}
