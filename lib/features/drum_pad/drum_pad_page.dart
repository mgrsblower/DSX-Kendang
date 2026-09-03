import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../audio/audio_engine.dart';
import '../../audio/sample_catalog.dart';
import '../../storage/preset_archive.dart';
import 'drum_pad_state.dart';

class DrumPadPage extends StatefulWidget {
  const DrumPadPage({
    super.key,
    required this.state,
    required this.engine,
    this.onStateChanged,
  });

  final DrumPadState state;
  final AudioEngine engine;
  final VoidCallback? onStateChanged;

  @override
  State<DrumPadPage> createState() => _DrumPadPageState();
}

class _DrumPadPageState extends State<DrumPadPage> {
  String? _error;
  bool _isSelectingBuiltinPad = false;
  bool _isSelectingImportPad = false;
  bool _mainMenuOpen = false;
  String _padSkin = 'default';
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<int, SampleRef> _customSamples = {};
  final PresetArchive _presetArchive = const PresetArchive();

  Preset get _preset => SampleCatalog.presets[widget.state.activePresetIndex];

  List<SampleRef> get _samples => List<SampleRef>.generate(
    DrumPadState.padCount,
    (index) => _customSamples[index] ?? _preset.samples[index],
  );

  String _padAsset(int index) {
    if (_padSkin == 'karakter') return 'assets/ui/pad_karakter.webp';
    if (_padSkin == 'kayu') return 'assets/ui/pad_kayu.webp';
    if (_padSkin == 'metal') return 'assets/ui/pad_metal.webp';
    return 'assets/ui/pad${index + 1}.webp';
  }

  String? _panelAsset() {
    switch (_padSkin) {
      case 'karakter':
      case 'grafiti':
        return 'assets/ui/panel_grafiti.webp';
      case 'kayu':
        return 'assets/ui/panel_kayu.webp';
      case 'metal':
        return 'assets/ui/panel_metal.webp';
      default:
        return null;
    }
  }

  Future<void> _play(int index) async {
    final volume = widget.state.masterVolume * widget.state.padVolumes[index];
    await _playSample(_samples[index], volume);
  }

  Future<void> _playSample(SampleRef sample, double volume) async {
    try {
      await widget.engine.play(sample, volume);
      if (mounted) setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = 'Audio gagal dimainkan: $error');
    }
  }

  void _selectPreset(int index) {
    setState(() => widget.state.selectPreset(index));
    widget.onStateChanged?.call();
  }

  Future<void> _showEditMenu() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _MGRColors.surface2,
        title: const Text('EDIT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('edit-sound'),
              leading: const Icon(Icons.tune),
              title: const Text('Edit sound'),
              subtitle: const Text('Ganti sound dari bawaan APK'),
              onTap: () {
                Navigator.pop(context);
                _startBuiltinSoundEdit();
              },
            ),
            ListTile(
              key: const ValueKey('import-sound'),
              leading: const Icon(Icons.library_music),
              title: const Text('Import sound'),
              subtitle: const Text('Import file ke satu pad'),
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
          title: const Text('Edit volume pad'),
          content: SizedBox(
            width: 420,
            child: ListView.builder(
              shrinkWrap: true,
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.onStateChanged?.call();
                Navigator.pop(context);
              },
              child: const Text('SELESAI'),
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
    final files = await FilePicker.pickFiles(type: FileType.audio);
    final file = files.isEmpty ? null : files.single;
    if (!mounted || file?.path == null) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(DeviceFileSource(file!.path!));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Music diputar: ${file.name}')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Music gagal diputar: $error');
    }
  }

  Future<void> _showSkinPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: _MGRColors.surface2,
        title: const Text('GANTI TEMA / SKIN'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'default'),
            child: const Text('SKIN ORIGINAL'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'karakter'),
            child: const Text('SKIN KARAKTER'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'kayu'),
            child: const Text('SKIN KAYU'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'metal'),
            child: const Text('SKIN METAL'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'grafiti'),
            child: const Text('SKIN GRAFITI'),
          ),
        ],
      ),
    );
    if (mounted && selected != null) setState(() => _padSkin = selected);
  }

  Future<void> _showStudioRecord() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _MGRColors.surface2,
        title: const Text('STUDIO RECORD'),
        content: const Text(
          'Panel rekaman siap ditambahkan. Mesin pad tetap aktif saat panel ini dibuka.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
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
    var source = _preset.samples[targetPad];
    final sources = [
      for (final preset in SampleCatalog.presets) ...preset.samples,
    ];
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _MGRColors.surface2,
          title: Text('SUARA PAD ${targetPad + 1}'),
          content: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SampleRef>(
                  initialValue: source,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih suara dari project',
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
              IconButton(
                key: const ValueKey('preview-sound'),
                tooltip: 'Preview sound',
                onPressed: () => _playSample(
                  source,
                  widget.state.masterVolume *
                      widget.state.padVolumes[targetPad],
                ),
                icon: const Icon(Icons.play_arrow),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                setState(() => _customSamples[targetPad] = source);
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Suara pad ${targetPad + 1} diganti')),
                );
              },
              child: const Text('GUNAKAN SUARA'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomSound(int targetPad) async {
    final files = await FilePicker.pickFiles(type: FileType.audio);
    final file = files.isEmpty ? null : files.single;
    if (!mounted || file?.path == null) return;
    setState(
      () => _customSamples[targetPad] = SampleRef(
        name: file!.name,
        assetPath: file.path!,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sample diimpor ke pad ${targetPad + 1}')),
    );
  }

  Future<void> _savePresetFile() async {
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
      ).showSnackBar(const SnackBar(content: Text('Preset berhasil disimpan')));
    }
  }

  Future<void> _loadPresetFile() async {
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
      final output = File(
        '${customDirectory.path}${Platform.pathSeparator}set${widget.state.activePresetIndex + 1}_pad_${entry.key + 1}.dat',
      );
      await output.writeAsBytes(entry.value, flush: true);
      _customSamples[entry.key] = SampleRef(
        name: 'CUSTOM ${entry.key + 1}',
        assetPath: output.path,
      );
    }
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pads.length} suara berhasil di-load')),
      );
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
              onStudioRecord: _showStudioRecord,
              onSkin: _showSkinPicker,
              onSave: _savePresetFile,
              onLoad: _loadPresetFile,
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
    return Column(
      children: [
        if (_error != null)
          MaterialBanner(
            backgroundColor: Colors.red.shade900,
            content: Text(_error!),
            actions: [
              TextButton(
                onPressed: () => setState(() => _error = null),
                child: const Text('TUTUP'),
              ),
            ],
          ),
        Expanded(child: _buildPadRows(indices)),
      ],
    );
  }

  Widget _buildPadRows(List<int> indices) {
    final rowWeights = [1, 2, 2, 1];
    final panelAsset = _panelAsset();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (panelAsset != null)
          Opacity(
            opacity: .18,
            child: Image.asset(panelAsset, fit: BoxFit.cover),
          ),
        Container(
          key: const ValueKey('pad-surface'),
          padding: const EdgeInsets.all(12),
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
                          assetPath: _padAsset(index),
                          onPressed: () {
                            if (_isSelectingBuiltinPad) {
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
    required this.onStudioRecord,
    required this.onSkin,
  });

  final DrumPadState state;
  final String? musicName;
  final VoidCallback onClose;
  final VoidCallback onVolume;
  final VoidCallback onToggleLeft;
  final VoidCallback onAddMusic;
  final VoidCallback onStudioRecord;
  final VoidCallback onSkin;

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
                      'MAIN MENU',
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
              _MenuAction(label: 'SETTING VOLUME PAD', onPressed: onVolume),
              _MenuAction(
                label: 'MODE LEFT (KIDAL): ${state.leftHanded ? 'ON' : 'OFF'}',
                onPressed: onToggleLeft,
              ),
              _MenuAction(label: 'ADD MUSIC', onPressed: onAddMusic),
              _MenuAction(label: 'STUDIO RECORD', onPressed: onStudioRecord),
              _MenuAction(label: 'GANTI TEMA (SKIN)', onPressed: onSkin),
              if (musicName != null)
                Text('Music: $musicName', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 20),
              _MenuAction(
                label: 'KEMBALI KE PAD',
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
    required this.onStudioRecord,
    required this.onSkin,
    required this.onSave,
    required this.onLoad,
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
  final VoidCallback onStudioRecord;
  final VoidCallback onSkin;
  final VoidCallback onSave;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    if (mainMenuOpen) {
      return _MainMenuSidebar(
        state: state,
        musicName: null,
        onClose: onCloseMainMenu,
        onVolume: onVolume,
        onToggleLeft: onToggleLeft,
        onAddMusic: onAddMusic,
        onStudioRecord: onStudioRecord,
        onSkin: onSkin,
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: _MGRColors.surface2,
        border: Border(right: BorderSide(color: _MGRColors.accent)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Image.asset(
              'assets/ui/logodsx.webp',
              key: const ValueKey('mgr-logo'),
              height: 56,
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
                label: index == 5 ? 'DRUM' : 'SET ${index + 1}',
                selected: state.activePresetIndex == index,
                onPressed: () => onPresetSelected(index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ActionGrid(onEdit: onEdit, onSave: onSave, onLoad: onLoad),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              key: const ValueKey('menu-main'),
              onPressed: onMainMenu,
              style: OutlinedButton.styleFrom(foregroundColor: _MGRColors.ink),
              child: const FittedBox(child: Text('MENU UTAMA')),
            ),
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
              label: 'EDIT',
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
                    label: 'SAVE',
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
                    label: 'LOAD',
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
    this.assetPath,
  });

  final String label;
  final VoidCallback onPressed;
  final String? assetPath;

  @override
  State<DrumPadButton> createState() => _DrumPadButtonState();
}

class _DrumPadButtonState extends State<DrumPadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Pad ${widget.label}',
    child: Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .94 : 1,
        duration: const Duration(milliseconds: 75),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: _MGRColors.surface3,
            foregroundColor: _MGRColors.ink,
            elevation: 5,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: _MGRColors.accent, width: .7),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.assetPath != null)
                  Image.asset(widget.assetPath!, fit: BoxFit.cover),
                Container(color: Colors.black26),
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
