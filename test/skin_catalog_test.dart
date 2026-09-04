import 'package:dsx_drum_kendang/features/drum_pad/skin_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SkinCatalog exposes all panels and pad options', () {
    expect(SkinCatalog.panels.length, greaterThanOrEqualTo(30));
    expect(SkinCatalog.padOptions.length, greaterThanOrEqualTo(30));
    expect(SkinCatalog.packs.length, greaterThanOrEqualTo(30));
  });

  test('SkinCatalog resolves new 14 themes correctly', () {
    expect(
      SkinCatalog.resolvePanel(null, 'cyberpunk'),
      'assets/ui/skins/panel_cyberpunk.webp',
    );
    expect(
      SkinCatalog.resolvePad(0, {}, 'material_design'),
      'assets/ui/skins/pad_material_design.webp',
    );
  });

  test('SkinCatalog resolves default and custom pad assets properly', () {
    expect(SkinCatalog.resolvePad(0, {}, 'default'), 'assets/ui/pad1.webp');
    expect(
      SkinCatalog.resolvePad(0, {0: 'assets/ui/pad_kayu.webp'}, 'default'),
      'assets/ui/pad_kayu.webp',
    );
    expect(SkinCatalog.resolvePad(1, {}, 'kayu'), 'assets/ui/pad_kayu.webp');
  });

  test('SkinCatalog resolves panel asset correctly', () {
    expect(SkinCatalog.resolvePanel(null, 'default'), isNull);
    expect(
      SkinCatalog.resolvePanel('assets/ui/panel_kayu.webp', 'default'),
      'assets/ui/panel_kayu.webp',
    );
    expect(SkinCatalog.resolvePanel(null, 'kayu'), 'assets/ui/panel_kayu.webp');
  });
}
