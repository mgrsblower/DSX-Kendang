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
    await tester.tap(find.byKey(const ValueKey('pad-0')));
    await tester.pumpAndSettle();
    expect(find.text('Pilih suara bawaan'), findsOneWidget);
    expect(find.text('IMPORT FILE'), findsNothing);
    expect(find.byKey(const ValueKey('preview-sound')), findsOneWidget);
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

  testWidgets('lists the built-in skin pack themes', (tester) async {
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
    await tester.tap(find.text('Ganti tema'));
    await tester.pumpAndSettle();

    expect(find.text('Asli'), findsOneWidget);
    expect(find.text('Kayu'), findsOneWidget);
    expect(find.text('Batik HD'), findsOneWidget);
    expect(find.text('Batik Flat'), findsOneWidget);
    expect(find.text('Carbon Orange HD'), findsOneWidget);
    expect(find.text('Carbon Orange Flat'), findsOneWidget);
    expect(find.text('Crimson Stage HD'), findsOneWidget);
    expect(find.text('Crimson Stage Flat'), findsOneWidget);
    expect(find.text('Emerald Islamic HD'), findsOneWidget);
    expect(find.text('Emerald Islamic Flat'), findsOneWidget);
    expect(find.text('Leather Vintage HD'), findsOneWidget);
    expect(find.text('Leather Vintage Flat'), findsOneWidget);
    expect(find.text('Neon Cyber HD'), findsOneWidget);
    expect(find.text('Neon Cyber Flat'), findsOneWidget);
  });
}
