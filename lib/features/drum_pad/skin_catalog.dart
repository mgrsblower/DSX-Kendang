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
    SkinOption(
      id: 'material_design',
      label: 'Material Design',
      padAsset: 'assets/ui/skins/pad_material_design.webp',
      panelAsset: 'assets/ui/skins/panel_material_design.webp',
    ),
    SkinOption(
      id: 'neumorphism',
      label: 'Neumorphism',
      padAsset: 'assets/ui/skins/pad_neumorphism.webp',
      panelAsset: 'assets/ui/skins/panel_neumorphism.webp',
    ),
    SkinOption(
      id: 'glassmorphism',
      label: 'Glassmorphism',
      padAsset: 'assets/ui/skins/pad_glassmorphism.webp',
      panelAsset: 'assets/ui/skins/panel_glassmorphism.webp',
    ),
    SkinOption(
      id: 'neo_brutalism',
      label: 'Neo Brutalism',
      padAsset: 'assets/ui/skins/pad_neo_brutalism.webp',
      panelAsset: 'assets/ui/skins/panel_neo_brutalism.webp',
    ),
    SkinOption(
      id: 'retro_vintage',
      label: 'Retro Vintage',
      padAsset: 'assets/ui/skins/pad_retro_vintage.webp',
      panelAsset: 'assets/ui/skins/panel_retro_vintage.webp',
    ),
    SkinOption(
      id: 'y2k',
      label: 'Y2K',
      padAsset: 'assets/ui/skins/pad_y2k.webp',
      panelAsset: 'assets/ui/skins/panel_y2k.webp',
    ),
    SkinOption(
      id: 'cyberpunk',
      label: 'Cyberpunk',
      padAsset: 'assets/ui/skins/pad_cyberpunk.webp',
      panelAsset: 'assets/ui/skins/panel_cyberpunk.webp',
    ),
    SkinOption(
      id: 'futuristic',
      label: 'Futuristic',
      padAsset: 'assets/ui/skins/pad_futuristic.webp',
      panelAsset: 'assets/ui/skins/panel_futuristic.webp',
    ),
    SkinOption(
      id: 'luxury_premium',
      label: 'Luxury Premium',
      padAsset: 'assets/ui/skins/pad_luxury_premium.webp',
      panelAsset: 'assets/ui/skins/panel_luxury_premium.webp',
    ),
    SkinOption(
      id: 'gradient',
      label: 'Gradient',
      padAsset: 'assets/ui/skins/pad_gradient.webp',
      panelAsset: 'assets/ui/skins/panel_gradient.webp',
    ),
    SkinOption(
      id: 'pixel_art',
      label: 'Pixel Art',
      padAsset: 'assets/ui/skins/pad_pixel_art.webp',
      panelAsset: 'assets/ui/skins/panel_pixel_art.webp',
    ),
    SkinOption(
      id: 'anime_manga',
      label: 'Anime Manga',
      padAsset: 'assets/ui/skins/pad_anime_manga.webp',
      panelAsset: 'assets/ui/skins/panel_anime_manga.webp',
    ),
    SkinOption(
      id: 'memphis',
      label: 'Memphis',
      padAsset: 'assets/ui/skins/pad_memphis.webp',
      panelAsset: 'assets/ui/skins/panel_memphis.webp',
    ),
    SkinOption(
      id: 'abstract',
      label: 'Abstract',
      padAsset: 'assets/ui/skins/pad_abstract.webp',
      panelAsset: 'assets/ui/skins/panel_abstract.webp',
    ),
    SkinOption(
      id: 'naruto',
      label: 'Naruto',
      padAsset: 'assets/ui/skins/pad_naruto.webp',
      panelAsset: 'assets/ui/skins/panel_naruto.webp',
    ),
    SkinOption(
      id: 'one_piece',
      label: 'One Piece',
      padAsset: 'assets/ui/skins/pad_one_piece.webp',
      panelAsset: 'assets/ui/skins/panel_one_piece.webp',
    ),
    SkinOption(
      id: 'tsubasa',
      label: 'Captain Tsubasa',
      padAsset: 'assets/ui/skins/pad_tsubasa.webp',
      panelAsset: 'assets/ui/skins/panel_tsubasa.webp',
    ),
    SkinOption(
      id: 'rimuru',
      label: 'Rimuru Tempest',
      padAsset: 'assets/ui/skins/pad_rimuru.webp',
      panelAsset: 'assets/ui/skins/panel_rimuru.webp',
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
    MapEntry('Material Design', 'assets/ui/skins/panel_material_design.webp'),
    MapEntry('Neumorphism', 'assets/ui/skins/panel_neumorphism.webp'),
    MapEntry('Glassmorphism', 'assets/ui/skins/panel_glassmorphism.webp'),
    MapEntry('Neo Brutalism', 'assets/ui/skins/panel_neo_brutalism.webp'),
    MapEntry('Retro Vintage', 'assets/ui/skins/panel_retro_vintage.webp'),
    MapEntry('Y2K', 'assets/ui/skins/panel_y2k.webp'),
    MapEntry('Cyberpunk', 'assets/ui/skins/panel_cyberpunk.webp'),
    MapEntry('Futuristic', 'assets/ui/skins/panel_futuristic.webp'),
    MapEntry('Luxury Premium', 'assets/ui/skins/panel_luxury_premium.webp'),
    MapEntry('Gradient', 'assets/ui/skins/panel_gradient.webp'),
    MapEntry('Pixel Art', 'assets/ui/skins/panel_pixel_art.webp'),
    MapEntry('Anime Manga', 'assets/ui/skins/panel_anime_manga.webp'),
    MapEntry('Memphis', 'assets/ui/skins/panel_memphis.webp'),
    MapEntry('Abstract', 'assets/ui/skins/panel_abstract.webp'),
    MapEntry('Naruto', 'assets/ui/skins/panel_naruto.webp'),
    MapEntry('One Piece', 'assets/ui/skins/panel_one_piece.webp'),
    MapEntry('Captain Tsubasa', 'assets/ui/skins/panel_tsubasa.webp'),
    MapEntry('Rimuru Tempest', 'assets/ui/skins/panel_rimuru.webp'),
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
    MapEntry('Material Design', 'assets/ui/skins/pad_material_design.webp'),
    MapEntry('Neumorphism', 'assets/ui/skins/pad_neumorphism.webp'),
    MapEntry('Glassmorphism', 'assets/ui/skins/pad_glassmorphism.webp'),
    MapEntry('Neo Brutalism', 'assets/ui/skins/pad_neo_brutalism.webp'),
    MapEntry('Retro Vintage', 'assets/ui/skins/pad_retro_vintage.webp'),
    MapEntry('Y2K', 'assets/ui/skins/pad_y2k.webp'),
    MapEntry('Cyberpunk', 'assets/ui/skins/pad_cyberpunk.webp'),
    MapEntry('Futuristic', 'assets/ui/skins/pad_futuristic.webp'),
    MapEntry('Luxury Premium', 'assets/ui/skins/pad_luxury_premium.webp'),
    MapEntry('Gradient', 'assets/ui/skins/pad_gradient.webp'),
    MapEntry('Pixel Art', 'assets/ui/skins/pad_pixel_art.webp'),
    MapEntry('Anime Manga', 'assets/ui/skins/pad_anime_manga.webp'),
    MapEntry('Memphis', 'assets/ui/skins/pad_memphis.webp'),
    MapEntry('Abstract', 'assets/ui/skins/pad_abstract.webp'),
    MapEntry('Naruto', 'assets/ui/skins/pad_naruto.webp'),
    MapEntry('One Piece', 'assets/ui/skins/pad_one_piece.webp'),
    MapEntry('Captain Tsubasa', 'assets/ui/skins/pad_tsubasa.webp'),
    MapEntry('Rimuru Tempest', 'assets/ui/skins/pad_rimuru.webp'),
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
