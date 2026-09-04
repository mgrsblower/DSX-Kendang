class SkinOption {
  final String id;
  final String label;
  final String padAsset;
  final String? panelAsset;

  const SkinOption({
    required this.id,
    required this.label,
    required this.padAsset,
    this.panelAsset,
  });
}

class SkinCatalog {
  static const List<SkinOption> packs = [
    SkinOption(
      id: 'default',
      label: 'Asli',
      padAsset: 'assets/ui/pad1.webp',
      panelAsset: null,
    ),
    SkinOption(
      id: 'kayu',
      label: 'Kayu',
      padAsset: 'assets/ui/pad_kayu.webp',
      panelAsset: 'assets/ui/panel_kayu.webp',
    ),
    SkinOption(
      id: 'metal',
      label: 'Metal',
      padAsset: 'assets/ui/pad_metal.webp',
      panelAsset: 'assets/ui/panel_metal.webp',
    ),
    SkinOption(
      id: 'grafiti',
      label: 'Grafiti',
      padAsset: 'assets/ui/pad1.webp',
      panelAsset: 'assets/ui/panel_grafiti.webp',
    ),
    SkinOption(
      id: 'karakter',
      label: 'Karakter',
      padAsset: 'assets/ui/pad_karakter.webp',
      panelAsset: null,
    ),
    SkinOption(
      id: 'batik_hd',
      label: 'Batik HD',
      padAsset: 'assets/ui/skins/pad_batik.webp',
      panelAsset: 'assets/ui/skins/panel_batik.webp',
    ),
    SkinOption(
      id: 'batik_flat',
      label: 'Batik Flat',
      padAsset: 'assets/ui/skins/pad_batik_flat.webp',
      panelAsset: 'assets/ui/skins/panel_batik_flat.webp',
    ),
    SkinOption(
      id: 'carbon_hd',
      label: 'Carbon HD',
      padAsset: 'assets/ui/skins/pad_carbon_orange.webp',
      panelAsset: 'assets/ui/skins/panel_carbon_orange.webp',
    ),
    SkinOption(
      id: 'carbon_flat',
      label: 'Carbon Flat',
      padAsset: 'assets/ui/skins/pad_carbon_orange_flat.webp',
      panelAsset: 'assets/ui/skins/panel_carbon_orange_flat.webp',
    ),
    SkinOption(
      id: 'crimson_hd',
      label: 'Crimson HD',
      padAsset: 'assets/ui/skins/pad_crimson_stage.webp',
      panelAsset: 'assets/ui/skins/panel_crimson_stage.webp',
    ),
    SkinOption(
      id: 'crimson_flat',
      label: 'Crimson Flat',
      padAsset: 'assets/ui/skins/pad_crimson_stage_flat.webp',
      panelAsset: 'assets/ui/skins/panel_crimson_stage_flat.webp',
    ),
    SkinOption(
      id: 'emerald_hd',
      label: 'Emerald HD',
      padAsset: 'assets/ui/skins/pad_emerald_islamic.webp',
      panelAsset: 'assets/ui/skins/panel_emerald_islamic.webp',
    ),
    SkinOption(
      id: 'emerald_flat',
      label: 'Emerald Flat',
      padAsset: 'assets/ui/skins/pad_emerald_islamic_flat.webp',
      panelAsset: 'assets/ui/skins/panel_emerald_islamic_flat.webp',
    ),
    SkinOption(
      id: 'leather_hd',
      label: 'Leather HD',
      padAsset: 'assets/ui/skins/pad_leather_vintage.webp',
      panelAsset: 'assets/ui/skins/panel_leather_vintage.webp',
    ),
    SkinOption(
      id: 'leather_flat',
      label: 'Leather Flat',
      padAsset: 'assets/ui/skins/pad_leather_vintage_flat.webp',
      panelAsset: 'assets/ui/skins/panel_leather_vintage_flat.webp',
    ),
    SkinOption(
      id: 'neon_hd',
      label: 'Neon HD',
      padAsset: 'assets/ui/skins/pad_neon_cyber.webp',
      panelAsset: 'assets/ui/skins/panel_neon_cyber.webp',
    ),
    SkinOption(
      id: 'neon_flat',
      label: 'Neon Flat',
      padAsset: 'assets/ui/skins/pad_neon_cyber_flat.webp',
      panelAsset: 'assets/ui/skins/panel_neon_cyber_flat.webp',
    ),
  ];

  static const List<MapEntry<String, String?>> panels = [
    MapEntry('Asli (Hardware)', null),
    MapEntry('Kayu', 'assets/ui/panel_kayu.webp'),
    MapEntry('Metal', 'assets/ui/panel_metal.webp'),
    MapEntry('Grafiti', 'assets/ui/panel_grafiti.webp'),
    MapEntry('Batik HD', 'assets/ui/skins/panel_batik.webp'),
    MapEntry('Batik Flat', 'assets/ui/skins/panel_batik_flat.webp'),
    MapEntry('Carbon HD', 'assets/ui/skins/panel_carbon_orange.webp'),
    MapEntry('Carbon Flat', 'assets/ui/skins/panel_carbon_orange_flat.webp'),
    MapEntry('Crimson HD', 'assets/ui/skins/panel_crimson_stage.webp'),
    MapEntry('Crimson Flat', 'assets/ui/skins/panel_crimson_stage_flat.webp'),
    MapEntry('Emerald HD', 'assets/ui/skins/panel_emerald_islamic.webp'),
    MapEntry('Emerald Flat', 'assets/ui/skins/panel_emerald_islamic_flat.webp'),
    MapEntry('Leather HD', 'assets/ui/skins/panel_leather_vintage.webp'),
    MapEntry('Leather Flat', 'assets/ui/skins/panel_leather_vintage_flat.webp'),
    MapEntry('Neon HD', 'assets/ui/skins/panel_neon_cyber.webp'),
    MapEntry('Neon Flat', 'assets/ui/skins/panel_neon_cyber_flat.webp'),
  ];

  static const List<MapEntry<String, String>> padOptions = [
    MapEntry('Asli (Pad 1-12)', 'assets/ui/pad1.webp'),
    MapEntry('Kayu', 'assets/ui/pad_kayu.webp'),
    MapEntry('Metal', 'assets/ui/pad_metal.webp'),
    MapEntry('Karakter', 'assets/ui/pad_karakter.webp'),
    MapEntry('Batik HD', 'assets/ui/skins/pad_batik.webp'),
    MapEntry('Batik Flat', 'assets/ui/skins/pad_batik_flat.webp'),
    MapEntry('Carbon HD', 'assets/ui/skins/pad_carbon_orange.webp'),
    MapEntry('Carbon Flat', 'assets/ui/skins/pad_carbon_orange_flat.webp'),
    MapEntry('Crimson HD', 'assets/ui/skins/pad_crimson_stage.webp'),
    MapEntry('Crimson Flat', 'assets/ui/skins/pad_crimson_stage_flat.webp'),
    MapEntry('Emerald HD', 'assets/ui/skins/pad_emerald_islamic.webp'),
    MapEntry('Emerald Flat', 'assets/ui/skins/pad_emerald_islamic_flat.webp'),
    MapEntry('Leather HD', 'assets/ui/skins/pad_leather_vintage.webp'),
    MapEntry('Leather Flat', 'assets/ui/skins/pad_leather_vintage_flat.webp'),
    MapEntry('Neon HD', 'assets/ui/skins/pad_neon_cyber.webp'),
    MapEntry('Neon Flat', 'assets/ui/skins/pad_neon_cyber_flat.webp'),
  ];

  static String? resolvePanel(String? customPanel, String globalPackId) {
    if (customPanel != null) return customPanel;
    for (final pack in packs) {
      if (pack.id == globalPackId) return pack.panelAsset;
    }
    return null;
  }

  static String resolvePad(
    int index,
    Map<int, String> customPads,
    String globalPackId,
  ) {
    if (customPads.containsKey(index)) {
      final custom = customPads[index]!;
      if (custom == 'assets/ui/pad1.webp') {
        return 'assets/ui/pad${index + 1}.webp';
      }
      return custom;
    }

    for (final pack in packs) {
      if (pack.id == globalPackId) {
        if (pack.id == 'default' || pack.id == 'grafiti') {
          return 'assets/ui/pad${index + 1}.webp';
        }
        return pack.padAsset;
      }
    }
    return 'assets/ui/pad${index + 1}.webp';
  }
}
