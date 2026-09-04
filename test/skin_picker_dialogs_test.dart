import 'package:dsx_drum_kendang/features/drum_pad/skin_picker_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PadSkinPickerDialog renders thumbnail options and returns selected asset', (
    tester,
  ) async {
    String? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedResult = await showDialog<String>(
                  context: context,
                  builder: (context) => const PadSkinPickerDialog(targetPad: 2),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Tampilan Pad 3'), findsOneWidget);
    expect(find.text('Kayu'), findsWidgets);
    expect(find.text('Batik HD'), findsWidgets);

    // Tap on 'Kayu' pad option
    await tester.tap(find.byKey(const ValueKey('pad-thumb-Kayu')));
    await tester.pumpAndSettle();

    expect(selectedResult, 'assets/ui/pad_kayu.webp');
  });

  testWidgets('PadSkinPickerDialog allows resetting pad to default', (
    tester,
  ) async {
    String? selectedResult = 'initial';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedResult = await showDialog<String>(
                  context: context,
                  builder: (context) => const PadSkinPickerDialog(targetPad: 0),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset ke Tema Aktif'));
    await tester.pumpAndSettle();

    expect(selectedResult, 'RESET');
  });

  testWidgets('ThemeAndBackgroundDialog renders panels and global pad styles', (
    tester,
  ) async {
    ThemeAndBackgroundResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<ThemeAndBackgroundResult>(
                  context: context,
                  builder: (context) => const ThemeAndBackgroundDialog(
                    activePanel: null,
                    activeGlobalPad: 'default',
                  ),
                );
              },
              child: const Text('Buka Tema'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Tema'));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan Tema & Latar'), findsOneWidget);
    expect(find.text('Latar Belakang (Panel)'), findsOneWidget);
    expect(find.text('Gaya Pad (Terapkan ke Semua)'), findsOneWidget);
    expect(find.text('Opasitas Latar Belakang'), findsOneWidget);
    expect(find.text('Lapisan Gelap Pad (Tint)'), findsOneWidget);

    // Tap on Kayu panel
    await tester.tap(find.byKey(const ValueKey('panel-thumb-Kayu')));
    await tester.pumpAndSettle();

    // Tap apply
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(result?.selectedPanel, 'assets/ui/panel_kayu.webp');
    expect(result?.panelOpacity, 0.5);
    expect(result?.padOpacity, 0.12);
  });
}
