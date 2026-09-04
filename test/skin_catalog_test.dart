import 'package:dsx_drum_kendang/features/drum_pad/skin_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SkinCatalog exposes all panels and pad options', () {
    expect(SkinCatalog.panels.length, greaterThanOrEqualTo(39));
    expect(SkinCatalog.padOptions.length, greaterThanOrEqualTo(44));
    expect(SkinCatalog.packs.length, greaterThanOrEqualTo(39));
  });

  test('SkinCatalog resolves dual-size pad skins correctly for small and large pads', () {
    // Pads 1, 2, 3 (indices 0, 1, 2) and 10, 11, 12 (indices 9, 10, 11) should use pad_kecil
    expect(SkinCatalog.isSmallPad(0), isTrue);
    expect(SkinCatalog.isSmallPad(1), isTrue);
    expect(SkinCatalog.isSmallPad(2), isTrue);
    expect(SkinCatalog.isSmallPad(3), isFalse);
    expect(SkinCatalog.isSmallPad(8), isFalse);
    expect(SkinCatalog.isSmallPad(9), isTrue);
    expect(SkinCatalog.isSmallPad(11), isTrue);

    // Gold theme resolution
    expect(SkinCatalog.resolvePad(0, {}, 'gold'), 'assets/ui/skins/pad_kecil_gold.webp');
    expect(SkinCatalog.resolvePad(2, {}, 'gold'), 'assets/ui/skins/pad_kecil_gold.webp');
    expect(SkinCatalog.resolvePad(3, {}, 'gold'), 'assets/ui/skins/pad_gold.webp');
    expect(SkinCatalog.resolvePad(8, {}, 'gold'), 'assets/ui/skins/pad_gold.webp');
    expect(SkinCatalog.resolvePad(9, {}, 'gold'), 'assets/ui/skins/pad_kecil_gold.webp');
    expect(SkinCatalog.resolvePad(11, {}, 'gold'), 'assets/ui/skins/pad_kecil_gold.webp');
    expect(SkinCatalog.resolvePanel(null, 'gold'), 'assets/ui/skins/panel_gold.webp');

    // Blue theme resolution
    expect(SkinCatalog.resolvePad(0, {}, 'blue'), 'assets/ui/skins/pad_kecil_blue.webp');
    expect(SkinCatalog.resolvePad(5, {}, 'blue'), 'assets/ui/skins/pad_blue.webp');
    expect(SkinCatalog.resolvePad(10, {}, 'blue'), 'assets/ui/skins/pad_kecil_blue.webp');
    expect(SkinCatalog.resolvePanel(null, 'blue'), 'assets/ui/skins/panel_blue.webp');
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
    expect(
      SkinCatalog.resolvePanel(null, 'naruto'),
      'assets/ui/skins/panel_naruto.webp',
    );
    expect(
      SkinCatalog.resolvePad(0, {}, 'one_piece'),
      'assets/ui/skins/pad_one_piece.webp',
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
