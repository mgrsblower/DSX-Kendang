import 'package:flutter/material.dart';

import 'skin_catalog.dart';

class ThemeAndBackgroundResult {
  final String? selectedPanel;
  final String selectedGlobalPad;
  final bool resetCustomPads;

  const ThemeAndBackgroundResult({
    required this.selectedPanel,
    required this.selectedGlobalPad,
    this.resetCustomPads = false,
  });
}

class SkinThumbnailCard extends StatelessWidget {
  const SkinThumbnailCard({
    super.key,
    required this.label,
    this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFF08A00) : const Color(0xFF4A4A4A),
            width: selected ? 2.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: assetPath != null
                    ? Image.asset(
                        assetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black45,
                          child: const Icon(Icons.image, size: 24),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF111111),
                        child: const Center(
                          child: Icon(Icons.piano, color: Colors.white70, size: 24),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? const Color(0xFFF08A00) : const Color(0xFFF4F4F0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeAndBackgroundDialog extends StatefulWidget {
  const ThemeAndBackgroundDialog({
    super.key,
    required this.activePanel,
    required this.activeGlobalPad,
  });

  final String? activePanel;
  final String activeGlobalPad;

  @override
  State<ThemeAndBackgroundDialog> createState() => _ThemeAndBackgroundDialogState();
}

class _ThemeAndBackgroundDialogState extends State<ThemeAndBackgroundDialog> {
  late String? _selectedPanel = widget.activePanel;
  late String _selectedGlobalPad = widget.activeGlobalPad;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 580,
        height: 520,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFFF08A00)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pengaturan Tema & Latar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF4F4F0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const Divider(color: Color(0xFF4A4A4A)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latar Belakang (Panel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF08A00),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: SkinCatalog.panels.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final panel = SkinCatalog.panels[index];
                          final isSelected = _selectedPanel == panel.value;
                          return SkinThumbnailCard(
                            key: ValueKey('panel-thumb-${panel.key}'),
                            label: panel.key,
                            assetPath: panel.value,
                            selected: isSelected,
                            onTap: () => setState(() => _selectedPanel = panel.value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Gaya Pad (Terapkan ke Semua)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF08A00),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: SkinCatalog.packs.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final pack = SkinCatalog.packs[index];
                          final isSelected = _selectedGlobalPad == pack.id;
                          return SkinThumbnailCard(
                            key: ValueKey('pack-thumb-${pack.id}'),
                            label: pack.label,
                            assetPath: pack.padAsset,
                            selected: isSelected,
                            onTap: () => setState(() => _selectedGlobalPad = pack.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPanel = null;
                      _selectedGlobalPad = 'default';
                    });
                  },
                  child: const Text('Reset ke Asli'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08A00),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      ThemeAndBackgroundResult(
                        selectedPanel: _selectedPanel,
                        selectedGlobalPad: _selectedGlobalPad,
                        resetCustomPads: true,
                      ),
                    );
                  },
                  child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PadSkinPickerDialog extends StatelessWidget {
  const PadSkinPickerDialog({
    super.key,
    required this.targetPad,
    this.currentAsset,
  });

  final int targetPad;
  final String? currentAsset;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 520,
        height: 480,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: Color(0xFFF08A00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih Tampilan Pad ${targetPad + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF4F4F0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const Divider(color: Color(0xFF4A4A4A)),
            Expanded(
              child: GridView.builder(
                itemCount: SkinCatalog.padOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final option = SkinCatalog.padOptions[index];
                  final isSelected = currentAsset == option.value;
                  return SkinThumbnailCard(
                    key: ValueKey('pad-thumb-${option.key}'),
                    label: option.key,
                    assetPath: option.value,
                    selected: isSelected,
                    onTap: () => Navigator.pop(context, option.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset ke Tema Aktif'),
                  onPressed: () => Navigator.pop(context, 'RESET'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
