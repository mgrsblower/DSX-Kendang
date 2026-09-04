import 'package:dsx_drum_kendang/audio/audio_engine.dart';
import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_page.dart';
import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renders twelve pads and plays the tapped sample', (
    tester,
  ) async {
    final engine = RecordingAudioEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(state: DrumPadState(), engine: engine),
      ),
    );

    expect(find.byType(DrumPadButton), findsAtLeastNWidgets(6));
    await tester.tap(find.byKey(const ValueKey('pad-0')));
    await tester.pump();

    expect(engine.playedVolumes, [0.5]);
    expect(find.byKey(const ValueKey('pad-11')), findsOneWidget);
  });

  testWidgets('changes the active preset', (tester) async {
    final state = DrumPadState();
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(state: state, engine: RecordingAudioEngine()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('preset-5')));
    await tester.pump();

    expect(state.activePresetIndex, 5);
    expect(find.byKey(const ValueKey('pad-11')), findsOneWidget);
  });

  testWidgets('renders the MGR instrument rail and live pad surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(
          state: DrumPadState(),
          engine: RecordingAudioEngine(),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('mgr-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('preset-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('preset-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('action-edit')), findsOneWidget);
    expect(find.byKey(const ValueKey('action-save')), findsOneWidget);
    expect(find.byKey(const ValueKey('action-load')), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-sound')), findsNothing);
    expect(find.byKey(const ValueKey('menu-main')), findsOneWidget);
    expect(find.byType(DrumPadButton), findsNWidgets(12));
  });

  testWidgets('selects a pad before choosing a built-in sound', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(
          state: DrumPadState(),
          engine: RecordingAudioEngine(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('action-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-sound')));
    await tester.pumpAndSettle();
    expect(find.text('Ketuk pad yang ingin diubah suaranya'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pad-0')));
    await tester.pumpAndSettle();
    expect(find.text('Pilih suara bawaan'), findsOneWidget);
    expect(find.text('IMPORT FILE'), findsNothing);
    expect(find.byKey(const ValueKey('preview-sound')), findsOneWidget);
    expect(find.text('Gunakan suara'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih suara bawaan'), findsNothing);
  });

  testWidgets('opens main menu as an in-place sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(
          state: DrumPadState(),
          engine: RecordingAudioEngine(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('menu-main')));
    await tester.pump();
    expect(find.text('Menu utama'), findsOneWidget);
    expect(find.text('Tambah musik'), findsOneWidget);
    expect(find.byKey(const ValueKey('main-menu-back')), findsOneWidget);
    expect(find.byKey(const ValueKey('menu-main')), findsNothing);
  });

  testWidgets('opens Tema & Background dialog with panels and global styles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(
          state: DrumPadState(),
          engine: RecordingAudioEngine(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('menu-main')));
    await tester.pump();
    await tester.tap(find.text('Tema & Background'));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan Tema & Latar'), findsOneWidget);
    expect(find.text('Latar Belakang (Panel)'), findsOneWidget);
    expect(find.text('Gaya Pad (Terapkan ke Semua)'), findsOneWidget);
  });

  testWidgets('activates tap-to-customize pad skin mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrumPadPage(
          state: DrumPadState(),
          engine: RecordingAudioEngine(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('menu-main')));
    await tester.pump();
    await tester.tap(find.text('Kustom gambar pad'));
    await tester.pumpAndSettle();

    // Banner is visible
    expect(find.text('Ketuk pad yang ingin diubah gambarnya'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Tap pad-0 to customize
    await tester.tap(find.byKey(const ValueKey('pad-0')));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Tampilan Pad 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('pad-thumb-Kayu')), findsOneWidget);

    // Select Kayu
    await tester.tap(find.byKey(const ValueKey('pad-thumb-Kayu')));
    await tester.pumpAndSettle();

    // Finish customization
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Ketuk pad yang ingin diubah gambarnya'), findsNothing);
  });
}
