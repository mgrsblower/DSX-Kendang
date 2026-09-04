import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../audio/audio_engine.dart';
import '../../audio/sample_catalog.dart';
import '../../storage/preset_archive.dart';
import '../../storage/settings_store.dart';
import 'drum_pad_state.dart';
import 'skin_catalog.dart';
import 'skin_picker_dialogs.dart';

class DrumPadPage extends StatefulWidget {
  const DrumPadPage({
    super.key,
    required this.state,
    required this.engine,
    this.onStateChanged,
    this.settingsStore,
    this.initialSkinSettings,
  });

  final DrumPadState state;
  final AudioEngine engine;
  final VoidCallback? onStateChanged;
  final SettingsStore? settingsStore;
  final SavedSkinSettings? initialSkinSettings;

  @override
  State<DrumPadPage> createState() => _DrumPadPageState();
}

class _DrumPadPageState extends State<DrumPadPage> {
  String? _error;
  bool _isSelectingBuiltinPad = false;
  bool _isSelectingImportPad = false;
  bool _isCustomizingPadSkin = false;
  bool _mainMenuOpen = false;
  String? _activePanelAsset;
  String _activeGlobalPadSkin = 'default';
  final Map<int, String> _customPadAssets = {};
  double _panelOpacity = 0.5;
  double _padOpacity = 0.12;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<int, SampleRef> _customSamples = {};
  final PresetArchive _presetArchive = const PresetArchive();

  String? _currentMusicName;
  bool _isMusicPlaying = false;
  Duration _musicPosition = Duration.zero;
  Duration _musicDuration = Duration.zero;
  double _musicVolume = 0.5;
  bool _isMusicMuted = false;
  double _preMuteVolume = 0.5;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.initialSkinSettings != null) {
      _activePanelAsset = widget.initialSkinSettings!.activePanelAsset;
      _activeGlobalPadSkin = widget.initialSkinSettings!.globalPadSkin;
      _customPadAssets.addAll(widget.initialSkinSettings!.customPadAssets);
      _panelOpacity = widget.initialSkinSettings!.panelOpacity;
      _padOpacity = widget.initialSkinSettings!.padOpacity;
    }
    if (widget.settingsStore != null) {
      _musicVolume = widget.settingsStore!.loadMusicVolume();
      _customSamples.addAll(widget.settingsStore!.loadCustomSamples());
    }
    _playerStateSubscription = _musicPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isMusicPlaying = state == PlayerState.playing;
        });
      }
    });
    _durationSubscription = _musicPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _musicDuration = d;
        });
      }
    });
    _positionSubscription = _musicPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _musicPosition = p;
        });
      }
    });
    widget.engine.preload(_preset);
  }

  Preset get _preset => SampleCatalog.presets[widget.state.activePresetIndex];

  List<SampleRef> get _samples => List<SampleRef>.generate(
    DrumPadState.padCount,
    (index) => _customSamples[index] ?? _preset.samples[index],
  );

  String _padAsset(int index) =>
      SkinCatalog.resolvePad(index, _customPadAssets, _activeGlobalPadSkin);

  String? _panelAsset() =>
      SkinCatalog.resolvePanel(_activePanelAsset, _activeGlobalPadSkin);

  Future<void> _saveSkinSettings() async {
    final store = widget.settingsStore;
    if (store != null) {
      await store.saveSkinSettings(
        SavedSkinSettings(
          activePanelAsset: _activePanelAsset,
          globalPadSkin: _activeGlobalPadSkin,
          customPadAssets: _customPadAssets,
          panelOpacity: _panelOpacity,
          padOpacity: _padOpacity,
        ),
      );
    }
  }

  Future<void> _saveCustomSamples() async {
    final store = widget.settingsStore;
    if (store != null) {
      await store.saveCustomSamples(_customSamples);
    }
  }

  void _play(int index) {
    final volume = widget.state.masterVolume * widget.state.padVolumes[index];
    _playSample(_samples[index], volume);
  }

  Future<void> _playSample(SampleRef sample, double volume) async {
    try {
      await widget.engine.play(sample, volume);
      if (_error != null && mounted) {
        setState(() => _error = null);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Suara tidak dapat diputar. Coba lagi.');
      }
    }
  }

  void _selectPreset(int index) {
    setState(() => widget.state.selectPreset(index));
    widget.onStateChanged?.call();
    widget.engine.preload(_preset);
  }

  void _showError(String message) {
    if (mounted) setState(() => _error = message);
  }

  Future<void> _showEditMenu() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _MGRColors.surface2,
        title: const Text('Ubah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('edit-sound'),
              leading: const Icon(Icons.tune),
              title: const Text('Ubah suara'),
              subtitle: const Text('Pilih suara bawaan untuk pad'),
              onTap: () {
                Navigator.pop(context);
                _startBuiltinSoundEdit();
              },
            ),
            ListTile(
              key: const ValueKey('import-sound'),
              leading: const Icon(Icons.library_music),
              title: const Text('Impor suara'),
              subtitle: const Text('Gunakan file suara untuk satu pad'),
              onTap: () {
                Navigator.pop(context);
                _showImportSoundDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVolumeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _MGRColors.surface2,
          title: const Text('Pengaturan Volume'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Volume Musik Pengiring',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        '${(_musicVolume * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _isMusicMuted ? 0.0 : _musicVolume,
                    activeColor: Colors.tealAccent,
                    onChanged: (value) {
                      setDialogState(() {
                        _musicVolume = value;
                        _isMusicMuted = value == 0.0;
                      });
                      _setMusicVolume(value);
                    },
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  const Text(
                    'Volume Pad Per Unit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: DrumPadState.padCount,
                    itemBuilder: (context, index) => Row(
                      children: [
                        SizedBox(width: 42, child: Text('P${index + 1}')),
                        Expanded(
                          child: Slider(
                            value: widget.state.padVolumes[index],
                            onChanged: (value) {
                              setDialogState(
                                () => widget.state.setPadVolume(index, value),
                              );
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.onStateChanged?.call();
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImportSoundDialog() async {
    if (mounted) setState(() => _isSelectingImportPad = true);
  }

  void _startBuiltinSoundEdit() {
    if (mounted) setState(() => _isSelectingBuiltinPad = true);
  }

  Future<void> _showAddMusic() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.audio);
      final file = files.isEmpty ? null : files.single;
      if (!mounted || file?.path == null) return;
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_isMusicMuted ? 0.0 : _musicVolume);
      await _musicPlayer.play(DeviceFileSource(file!.path!));
      if (mounted) {
        setState(() {
          _currentMusicName = file.name;
          _isMusicPlaying = true;
          _musicPosition = Duration.zero;
          _musicDuration = Duration.zero;
          if (_mainMenuOpen) {
            _mainMenuOpen = false;
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Musik diputar: ${file.name}')));
      }
    } catch (_) {
      _showError('Musik tidak dapat diputar. Coba lagi.');
    }
  }

  Future<void> _toggleMusicPlayPause() async {
    try {
      if (_isMusicPlaying) {
        await _musicPlayer.pause();
      } else {
        await _musicPlayer.resume();
      }
    } catch (_) {}
  }

  Future<void> _seekMusicRelative(int seconds) async {
    try {
      var target = _musicPosition + Duration(seconds: seconds);
      if (target < Duration.zero) target = Duration.zero;
      if (_musicDuration > Duration.zero && target > _musicDuration) {
        target = _musicDuration;
      }
      await _musicPlayer.seek(target);
    } catch (_) {}
  }

  Future<void> _seekMusicTo(Duration position) async {
    try {
      await _musicPlayer.seek(position);
    } catch (_) {}
  }

  Future<void> _stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _currentMusicName = null;
        _isMusicPlaying = false;
        _musicPosition = Duration.zero;
        _musicDuration = Duration.zero;
      });
    }
  }

  Future<void> _setMusicVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    setState(() {
      _musicVolume = clamped;
      _isMusicMuted = clamped == 0.0;
    });
    try {
      await _musicPlayer.setVolume(clamped);
    } catch (_) {}
    await widget.settingsStore?.saveMusicVolume(clamped);
  }

  Future<void> _toggleMusicMute() async {
    if (_isMusicMuted) {
      final restore = _preMuteVolume > 0.0 ? _preMuteVolume : 0.5;
      await _setMusicVolume(restore);
    } else {
      _preMuteVolume = _musicVolume > 0.0 ? _musicVolume : 0.5;
      await _setMusicVolume(0.0);
    }
  }

  Future<void> _showThemeAndBackground() async {
    final result = await showDialog<ThemeAndBackgroundResult>(
      context: context,
      builder: (context) => ThemeAndBackgroundDialog(
        activePanel: _activePanelAsset,
        activeGlobalPad: _activeGlobalPadSkin,
        initialPanelOpacity: _panelOpacity,
        initialPadOpacity: _padOpacity,
      ),
    );
    if (mounted && result != null) {
      setState(() {
        _activePanelAsset = result.selectedPanel;
        _activeGlobalPadSkin = result.selectedGlobalPad;
        _panelOpacity = result.panelOpacity;
        _padOpacity = result.padOpacity;
        if (result.resetCustomPads) {
          _customPadAssets.clear();
        }
      });
      await _saveSkinSettings();
    }
  }

  void _startPadSkinCustomization() {
    if (mounted) {
      setState(() {
        _mainMenuOpen = false;
        _isCustomizingPadSkin = true;
      });
    }
  }

  Future<void> _showPadSkinPicker(int targetPad) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => PadSkinPickerDialog(
        targetPad: targetPad,
        currentAsset: _customPadAssets[targetPad],
      ),
    );
    if (mounted && selected != null) {
      setState(() {
        if (selected == 'RESET') {
          _customPadAssets.remove(targetPad);
        } else {
          _customPadAssets[targetPad] = selected;
        }
      });
      await _saveSkinSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tampilan pad ${targetPad + 1} diperbarui')),
      );
    }
  }

  Future<void> _showStudioRecord() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _MGRColors.surface2,
        title: const Text('Studio rekaman'),
        content: const Text(
          'Fitur rekaman belum tersedia. Tutup panel ini untuk kembali bermain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showMainMenu() {
    if (mounted) setState(() => _mainMenuOpen = true);
  }

  void _closeMainMenu() {
    if (mounted) setState(() => _mainMenuOpen = false);
  }

  Future<void> _showSoundSourceDialog(int targetPad) async {
    var source = _customSamples[targetPad] ?? _preset.samples[targetPad];
    final sources = SampleCatalog.allBuiltinSounds;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _MGRColors.surface2,
          title: Text('Ubah Suara Pad ${targetPad + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suara saat ini: ${_samples[targetPad].name}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SampleRef>(
                      initialValue: source,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pilih suara bawaan',
                      ),
                      items: sources
                          .map(
                            (sample) => DropdownMenuItem(
                              value: sample,
                              child: Text(sample.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        final selected = value ?? source;
                        setDialogState(() => source = selected);
                        _playSample(
                          selected,
                          widget.state.masterVolume *
                              widget.state.padVolumes[targetPad],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const ValueKey('preview-sound'),
                    tooltip: 'Dengarkan suara',
                    onPressed: () => _playSample(
                      source,
                      widget.state.masterVolume *
                          widget.state.padVolumes[targetPad],
                    ),
                    icon: const Icon(Icons.play_arrow, color: _MGRColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Tekan "Gunakan suara" untuk konfirmasi perubahan suara pad ini.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            if (_customSamples.containsKey(targetPad))
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                onPressed: () {
                  setState(() => _customSamples.remove(targetPad));
                  _saveCustomSamples();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Suara Pad ${targetPad + 1} dikembalikan ke default'),
                    ),
                  );
                },
                child: const Text('Reset Asli'),
              ),
            FilledButton(
              onPressed: () {
                setState(() => _customSamples[targetPad] = source);
                _saveCustomSamples();
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Suara Pad ${targetPad + 1} diperbarui ke ${source.name}'),
                  ),
                );
              },
              child: const Text('Gunakan suara'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomSound(int targetPad) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.audio);
      final file = files.isEmpty ? null : files.single;
      if (!mounted || file?.path == null) return;

      final sampleCandidate = SampleRef(
        name: file!.name,
        assetPath: file.path!,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _MGRColors.surface2,
          title: Text('Konfirmasi Impor Suara Pad ${targetPad + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suara saat ini: ${_samples[targetPad].name}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _MGRColors.accent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audio_file, color: _MGRColors.accent, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Builder(
                            builder: (context) {
                              try {
                                final bytes = File(file.path!).lengthSync();
                                return Text(
                                  '${(bytes / 1024).toStringAsFixed(1)} KB',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                );
                              } catch (_) {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dengarkan file audio',
                      icon: const Icon(Icons.play_circle_filled, color: _MGRColors.accent, size: 30),
                      onPressed: () => _playSample(
                        sampleCandidate,
                        widget.state.masterVolume * widget.state.padVolumes[targetPad],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin menerapkan file audio ini pada pad tersebut?',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Terapkan Suara'),
            ),
          ],
        ),
      );

      if (mounted && confirmed == true) {
        setState(() => _customSamples[targetPad] = sampleCandidate);
        await _saveCustomSamples();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suara "${file.name}" berhasil dipasang pada Pad ${targetPad + 1}')),
        );
      }
    } catch (_) {
      _showError('Suara tidak dapat diimpor. Coba lagi.');
    }
  }

  Future<void> _savePresetFile() async {
    try {
      final pads = <int, List<int>>{};
      for (var index = 0; index < _samples.length; index++) {
        pads[index + 1] = await _sampleBytes(_samples[index]);
      }
      final uri = await FilePicker.saveFile(
        fileName: 'MGR_Set${widget.state.activePresetIndex + 1}.dsx',
        bytes: Uint8List.fromList(
          _presetArchive.encode(widget.state.activePresetIndex + 1, pads),
        ),
        type: FileType.custom,
        allowedExtensions: ['dsx'],
      );
      if (mounted && uri != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Set suara disimpan')));
      }
    } catch (_) {
      _showError('Set suara tidak dapat disimpan. Coba lagi.');
    }
  }

  Future<void> _loadPresetFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dsx', 'zip'],
      );
      final path = files.isEmpty ? null : files.single.path;
      if (!mounted || path == null) return;
      final pads = await _presetArchive.read(File(path));
      final directory = await getApplicationDocumentsDirectory();
      final customDirectory = Directory(
        '${directory.path}${Platform.pathSeparator}audio_kustom',
      );
      await customDirectory.create(recursive: true);
      for (final entry in pads.entries) {
        final ext = PresetArchive.detectAudioExtension(entry.value);
        final output = File(
          '${customDirectory.path}${Platform.pathSeparator}set${widget.state.activePresetIndex + 1}_pad_${entry.key + 1}.$ext',
        );
        await output.writeAsBytes(entry.value, flush: true);
        _customSamples[entry.key] = SampleRef(
          name: 'Kustom ${entry.key + 1}',
          assetPath: output.path,
        );
      }
      await _saveCustomSamples();
      widget.engine.preload(_preset);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${pads.length} suara dimuat')));
      }
    } catch (_) {
      _showError('Set suara tidak dapat dimuat. Coba lagi.');
    }
  }

  Future<List<int>> _sampleBytes(SampleRef sample) async {
    if (!sample.assetPath.startsWith('assets/')) {
      return File(sample.assetPath).readAsBytes();
    }
    final data = await rootBundle.load(sample.assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _musicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MGRColors.surface0,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth >= 700;
            final sidebar = _InstrumentSidebar(
              state: widget.state,
              onPresetSelected: _selectPreset,
              onEdit: _showEditMenu,
              onMainMenu: _showMainMenu,
              mainMenuOpen: _mainMenuOpen,
              onCloseMainMenu: _closeMainMenu,
              onVolume: _showVolumeDialog,
              onToggleLeft: () {
                setState(
                  () => widget.state.leftHanded = !widget.state.leftHanded,
                );
                widget.onStateChanged?.call();
              },
              onAddMusic: _showAddMusic,
              onStopMusic: _stopMusic,
              onStudioRecord: _showStudioRecord,
              onSkin: _showThemeAndBackground,
              onCustomPadSkin: _startPadSkinCustomization,
              onSave: _savePresetFile,
              onLoad: _loadPresetFile,
              musicName: _currentMusicName,
              isMusicPlaying: _isMusicPlaying,
              musicPosition: _musicPosition,
              musicDuration: _musicDuration,
              musicVolume: _musicVolume,
              isMusicMuted: _isMusicMuted,
              onMusicPlayPause: _toggleMusicPlayPause,
              onMusicSeekRelative: _seekMusicRelative,
              onMusicSeekTo: _seekMusicTo,
              onMusicStop: _stopMusic,
              onMusicVolumeChanged: _setMusicVolume,
              onMusicToggleMute: _toggleMusicMute,
            );
            if (landscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * (_mainMenuOpen ? .28 : .185),
                    child: sidebar,
                  ),
                  Expanded(child: _buildInstrumentSurface()),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: 270,
                    child: sidebar,
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    height: 650,
                    child: _buildInstrumentSurface(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstrumentSurface() {
    final indices = widget.state.orderedPadIndices();
    final isSelectingPad = _isSelectingBuiltinPad ||
        _isSelectingImportPad ||
        _isCustomizingPadSkin;

    return Column(
      children: [
        if (_isCustomizingPadSkin)
          Container(
            color: _MGRColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ketuk pad yang ingin diubah gambarnya',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    minimumSize: const Size(60, 32),
                  ),
                  onPressed: () => setState(() => _isCustomizingPadSkin = false),
                  child: const Text('Selesai'),
                ),
              ],
            ),
          ),
        if (_isSelectingBuiltinPad)
          Container(
            color: const Color(0xFFFF9800),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.tune, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ketuk pad yang ingin diubah suaranya',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    minimumSize: const Size(60, 32),
                  ),
                  onPressed: () => setState(() => _isSelectingBuiltinPad = false),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        if (_isSelectingImportPad)
          Container(
            color: const Color(0xFF00ACC1),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.library_music, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ketuk pad yang ingin diimpor suaranya',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    minimumSize: const Size(60, 32),
                  ),
                  onPressed: () => setState(() => _isSelectingImportPad = false),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        if (_error != null)
          MaterialBanner(
            backgroundColor: Colors.red.shade900,
            content: Text(_error!),
            actions: [
              TextButton(
                onPressed: () => setState(() => _error = null),
                child: const Text('Tutup'),
              ),
            ],
          ),
        Expanded(child: _buildPadRows(indices, isSelectingPad)),
      ],
    );
  }

  Widget _buildPadRows(List<int> indices, bool isSelectingPad) {
    final rowWeights = [1, 2, 2, 1];
    final panelAsset = _panelAsset();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (panelAsset != null)
          Opacity(
            opacity: _panelOpacity,
            child: Image.asset(panelAsset, fit: BoxFit.cover),
          ),
        Container(
          key: const ValueKey('pad-surface'),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: List.generate(4, (row) {
              return Expanded(
                flex: rowWeights[row],
                child: Row(
                  children: List.generate(3, (column) {
                    final index = indices[row * 3 + column];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: column == 2 ? 0 : 8,
                          bottom: row == 3 ? 0 : 8,
                        ),
                        child: DrumPadButton(
                          key: ValueKey('pad-$index'),
                          label: _samples[index].name,
                          padNumber: index + 1,
                          assetPath: _padAsset(index),
                          overlayOpacity: _padOpacity,
                          isSelecting: isSelectingPad,
                          onPressed: () {
                            if (_isCustomizingPadSkin) {
                              _showPadSkinPicker(index);
                            } else if (_isSelectingBuiltinPad) {
                              setState(() => _isSelectingBuiltinPad = false);
                              _showSoundSourceDialog(index);
                            } else if (_isSelectingImportPad) {
                              setState(() => _isSelectingImportPad = false);
                              _pickCustomSound(index);
                            } else {
                              _play(index);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MainMenuSidebar extends StatelessWidget {
  const _MainMenuSidebar({
    required this.state,
    required this.musicName,
    required this.onClose,
    required this.onVolume,
    required this.onToggleLeft,
    required this.onAddMusic,
    required this.onStopMusic,
    required this.onStudioRecord,
    required this.onSkin,
    required this.onCustomPadSkin,
  });

  final DrumPadState state;
  final String? musicName;
  final VoidCallback onClose;
  final VoidCallback onVolume;
  final VoidCallback onToggleLeft;
  final VoidCallback onAddMusic;
  final VoidCallback onStopMusic;
  final VoidCallback onStudioRecord;
  final VoidCallback onSkin;
  final VoidCallback onCustomPadSkin;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    color: _MGRColors.surface2,
    child: LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('main-menu-back'),
                    onPressed: onClose,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Menu utama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              _MenuAction(label: 'Atur volume pad & musik', onPressed: onVolume),
              _MenuAction(
                label:
                    'Tangan kiri: ${state.leftHanded ? 'Aktif' : 'Nonaktif'}',
                onPressed: onToggleLeft,
              ),
              _MenuAction(
                label: musicName != null ? 'Ganti musik' : 'Tambah musik',
                onPressed: onAddMusic,
              ),
              if (musicName != null)
                _MenuAction(
                  label: 'Stop musik',
                  color: Colors.redAccent,
                  onPressed: onStopMusic,
                ),
              _MenuAction(label: 'Studio rekaman', onPressed: onStudioRecord),
              _MenuAction(label: 'Tema & Background', onPressed: onSkin),
              _MenuAction(label: 'Kustom gambar pad', onPressed: onCustomPadSkin),
              if (musicName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    'Musik aktif: $musicName',
                    style: const TextStyle(fontSize: 12, color: Colors.tealAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              _MenuAction(
                label: 'Kembali ke pad',
                color: Colors.purple,
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _InstrumentSidebar extends StatelessWidget {
  const _InstrumentSidebar({
    required this.state,
    required this.onPresetSelected,
    required this.onEdit,
    required this.onMainMenu,
    required this.mainMenuOpen,
    required this.onCloseMainMenu,
    required this.onVolume,
    required this.onToggleLeft,
    required this.onAddMusic,
    required this.onStopMusic,
    required this.onStudioRecord,
    required this.onSkin,
    required this.onCustomPadSkin,
    required this.onSave,
    required this.onLoad,
    required this.musicName,
    required this.isMusicPlaying,
    required this.musicPosition,
    required this.musicDuration,
    required this.musicVolume,
    required this.isMusicMuted,
    required this.onMusicPlayPause,
    required this.onMusicSeekRelative,
    required this.onMusicSeekTo,
    required this.onMusicStop,
    required this.onMusicVolumeChanged,
    required this.onMusicToggleMute,
  });

  final DrumPadState state;
  final ValueChanged<int> onPresetSelected;
  final VoidCallback onEdit;
  final VoidCallback onMainMenu;
  final bool mainMenuOpen;
  final VoidCallback onCloseMainMenu;
  final VoidCallback onVolume;
  final VoidCallback onToggleLeft;
  final VoidCallback onAddMusic;
  final VoidCallback onStopMusic;
  final VoidCallback onStudioRecord;
  final VoidCallback onSkin;
  final VoidCallback onCustomPadSkin;
  final VoidCallback onSave;
  final VoidCallback onLoad;

  final String? musicName;
  final bool isMusicPlaying;
  final Duration musicPosition;
  final Duration musicDuration;
  final double musicVolume;
  final bool isMusicMuted;
  final VoidCallback onMusicPlayPause;
  final ValueChanged<int> onMusicSeekRelative;
  final ValueChanged<Duration> onMusicSeekTo;
  final VoidCallback onMusicStop;
  final ValueChanged<double> onMusicVolumeChanged;
  final VoidCallback onMusicToggleMute;

  @override
  Widget build(BuildContext context) {
    if (mainMenuOpen) {
      return _MainMenuSidebar(
        state: state,
        musicName: musicName,
        onClose: onCloseMainMenu,
        onVolume: onVolume,
        onToggleLeft: onToggleLeft,
        onAddMusic: onAddMusic,
        onStopMusic: onStopMusic,
        onStudioRecord: onStudioRecord,
        onSkin: onSkin,
        onCustomPadSkin: onCustomPadSkin,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: _MGRColors.surface2,
        border: Border(right: BorderSide(color: _MGRColors.accent)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Image.asset(
                'assets/ui/logodsx.webp',
                key: const ValueKey('mgr-logo'),
                height: 48,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.65,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: List.generate(
                SampleCatalog.presets.length,
                (index) => _RailButton(
                  key: ValueKey('preset-$index'),
                  label: index == 5 ? 'Drum' : 'Set ${index + 1}',
                  selected: state.activePresetIndex == index,
                  onPressed: () => onPresetSelected(index),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ActionGrid(onEdit: onEdit, onSave: onSave, onLoad: onLoad),
            if (musicName != null) ...[
              _MusicPlayerSidebarCard(
                musicName: musicName!,
                isPlaying: isMusicPlaying,
                position: musicPosition,
                duration: musicDuration,
                volume: musicVolume,
                isMuted: isMusicMuted,
                onPlayPause: onMusicPlayPause,
                onSeekRelative: onMusicSeekRelative,
                onSeekTo: onMusicSeekTo,
                onStop: onMusicStop,
                onVolumeChanged: onMusicVolumeChanged,
                onToggleMute: onMusicToggleMute,
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                key: const ValueKey('menu-main'),
                onPressed: onMainMenu,
                style: OutlinedButton.styleFrom(foregroundColor: _MGRColors.ink),
                child: const FittedBox(child: Text('Menu utama')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicPlayerSidebarCard extends StatelessWidget {
  const _MusicPlayerSidebarCard({
    required this.musicName,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.volume,
    required this.isMuted,
    required this.onPlayPause,
    required this.onSeekRelative,
    required this.onSeekTo,
    required this.onStop,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final String musicName;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isMuted;
  final VoidCallback onPlayPause;
  final ValueChanged<int> onSeekRelative;
  final ValueChanged<Duration> onSeekTo;
  final VoidCallback onStop;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final h = d.inHours.toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final posSec = position.inSeconds.toDouble();
    final durSec = duration.inSeconds.toDouble();
    final maxSec = durSec > 0 ? durSec : 1.0;
    final clampedPos = posSec.clamp(0.0, maxSec);

    return Container(
      key: const ValueKey('music-player-card'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Judul musik & Tombol Tutup/Stop
          Row(
            children: [
              const Icon(Icons.music_note, size: 15, color: Colors.tealAccent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  musicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                key: const ValueKey('music-close-btn'),
                onTap: onStop,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 16, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Waktu & Progress Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
              Text(
                _format(duration),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              activeTrackColor: Colors.tealAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.tealAccent,
            ),
            child: Slider(
              value: clampedPos,
              max: maxSec,
              onChanged: durSec > 0
                  ? (val) => onSeekTo(Duration(seconds: val.toInt()))
                  : null,
            ),
          ),

          // Tombol Kontrol: Mundur 10s, Play/Pause, Maju 10s, Stop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mundur 10s
              InkWell(
                key: const ValueKey('music-seek-back'),
                onTap: () => onSeekRelative(-10),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.replay_10, size: 20, color: Colors.white70),
                ),
              ),
              // Play / Pause
              InkWell(
                key: const ValueKey('music-play-pause'),
                onTap: onPlayPause,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.tealAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Maju 10s
              InkWell(
                key: const ValueKey('music-seek-forward'),
                onTap: () => onSeekRelative(10),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.forward_10, size: 20, color: Colors.white70),
                ),
              ),
              // Stop
              InkWell(
                key: const ValueKey('music-stop'),
                onTap: onStop,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.stop, size: 20, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Volume Bar
          Row(
            children: [
              InkWell(
                key: const ValueKey('music-volume-mute-toggle'),
                onTap: onToggleMute,
                child: Icon(
                  isMuted
                      ? Icons.volume_off
                      : (volume < 0.4 ? Icons.volume_down : Icons.volume_up),
                  size: 16,
                  color: isMuted ? Colors.redAccent : Colors.tealAccent,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                    activeTrackColor: Colors.amberAccent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.amberAccent,
                  ),
                  child: Slider(
                    key: const ValueKey('music-volume-slider'),
                    value: (isMuted ? 0.0 : volume).clamp(0.0, 1.0),
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
              Text(
                '${((isMuted ? 0.0 : volume) * 100).toInt()}%',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.onEdit,
    required this.onSave,
    required this.onLoad,
  });

  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final setButtonHeight = (constraints.maxWidth - 4) / 2 / 1.65;
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: setButtonHeight,
            child: _ActionButton(
              key: const ValueKey('action-edit'),
              label: 'Ubah',
              color: Colors.lightBlue,
              onPressed: onEdit,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: setButtonHeight,
                  child: _ActionButton(
                    key: const ValueKey('action-save'),
                    label: 'Simpan',
                    color: _MGRColors.success,
                    onPressed: onSave,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: setButtonHeight,
                  child: _ActionButton(
                    key: const ValueKey('action-load'),
                    label: 'Muat',
                    color: _MGRColors.surface3,
                    onPressed: onLoad,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.zero,
      foregroundColor: Colors.black,
      backgroundColor: selected ? _MGRColors.accent : _MGRColors.ink,
      side: BorderSide(color: selected ? _MGRColors.accent : Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    child: FittedBox(
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7),
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.black,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    child: FittedBox(
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    ),
  );
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.label,
    required this.onPressed,
    this.color = _MGRColors.surface3,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

class DrumPadButton extends StatefulWidget {
  const DrumPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padNumber,
    this.assetPath,
    this.overlayOpacity = 0.12,
    this.isSelecting = false,
  });

  final String label;
  final VoidCallback onPressed;
  final int? padNumber;
  final String? assetPath;
  final double overlayOpacity;
  final bool isSelecting;

  @override
  State<DrumPadButton> createState() => _DrumPadButtonState();
}

class _DrumPadButtonState extends State<DrumPadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Pad ${widget.padNumber ?? ''} ${widget.label}',
    child: Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        widget.onPressed();
        setState(() => _pressed = true);
      },
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .94 : 1,
        duration: const Duration(milliseconds: 30),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: _MGRColors.surface3,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.isSelecting
                    ? Colors.amberAccent.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.6),
                blurRadius: widget.isSelecting ? 8 : 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: widget.isSelecting ? Colors.amberAccent : _MGRColors.accent,
              width: widget.isSelecting ? 2.0 : .7,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.assetPath != null)
                  Image.asset(widget.assetPath!, fit: BoxFit.cover),
                Container(color: Color.fromRGBO(0, 0, 0, widget.overlayOpacity)),
                if (_pressed)
                  Container(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                if (widget.isSelecting && widget.padNumber != null)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amberAccent, width: 1),
                      ),
                      child: Text(
                        'P${widget.padNumber}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

abstract final class _MGRColors {
  static const surface0 = Color(0xFF111111);
  static const surface2 = Color(0xFF252525);
  static const surface3 = Color(0xFF4A4A4A);
  static const ink = Color(0xFFF4F4F0);
  static const accent = Color(0xFFF08A00);
  static const success = Color(0xFF00D978);
}
