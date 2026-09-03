import 'package:flutter/material.dart';

import '../../audio/audio_engine.dart';
import '../../audio/sample_catalog.dart';
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

  Preset get _preset => SampleCatalog.presets[widget.state.activePresetIndex];

  Future<void> _play(int index) async {
    final volume = widget.state.masterVolume * widget.state.padVolumes[index];
    try {
      await widget.engine.play(_preset.samples[index], volume);
      if (mounted) setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = 'Audio gagal dimainkan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final indices = widget.state.orderedPadIndices();
    return Scaffold(
      appBar: AppBar(title: const Text('DSX Drum Kendang')),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: List.generate(
                  SampleCatalog.presets.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('preset-$index'),
                      label: Text(SampleCatalog.presets[index].name),
                      selected: widget.state.activePresetIndex == index,
                      onSelected: (_) {
                        setState(() => widget.state.selectPreset(index));
                        widget.onStateChanged?.call();
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_error != null)
              MaterialBanner(
                content: Text(_error!),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _error = null),
                    child: const Text('TUTUP'),
                  ),
                ],
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: indices.length,
                itemBuilder: (context, position) {
                  final index = indices[position];
                  return DrumPadButton(
                    key: ValueKey('pad-$index'),
                    label: _preset.samples[index].name,
                    onPressed: () => _play(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  const Text('Master'),
                  Expanded(
                    child: Slider(
                      value: widget.state.masterVolume,
                      onChanged: (value) =>
                          setState(() => widget.state.setMasterVolume(value)),
                      onChangeEnd: (_) => widget.onStateChanged?.call(),
                    ),
                  ),
                  Switch(
                    key: const ValueKey('left-handed'),
                    value: widget.state.leftHanded,
                    onChanged: (value) {
                      setState(() => widget.state.leftHanded = value);
                      widget.onStateChanged?.call();
                    },
                  ),
                  const Text('Kidal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrumPadButton extends StatelessWidget {
  const DrumPadButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.all(8),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
