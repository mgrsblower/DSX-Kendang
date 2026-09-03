import 'package:dsx_drum_kendang/audio/audio_engine.dart';
import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_page.dart';
import 'package:dsx_drum_kendang/features/drum_pad/drum_pad_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renders twelve pads and plays the tapped sample', (tester) async {
    final engine = RecordingAudioEngine();
    await tester.pumpWidget(MaterialApp(
      home: DrumPadPage(state: DrumPadState(), engine: engine),
    ));

    expect(find.byType(DrumPadButton), findsAtLeastNWidgets(6));
    await tester.tap(find.byKey(const ValueKey('pad-0')));
    await tester.pump();

    expect(engine.playedVolumes, [0.5]);
    await tester.drag(find.byType(GridView), const Offset(0, -600));
    await tester.pump();
    expect(find.byKey(const ValueKey('pad-11')), findsOneWidget);
  });

  testWidgets('changes preset and reverses pad order', (tester) async {
    final state = DrumPadState();
    await tester.pumpWidget(MaterialApp(
      home: DrumPadPage(state: state, engine: RecordingAudioEngine()),
    ));

    await tester.tap(find.byKey(const ValueKey('preset-5')));
    await tester.tap(find.byKey(const ValueKey('left-handed')));
    await tester.pump();

    expect(state.activePresetIndex, 5);
    expect(state.leftHanded, isTrue);
    expect(find.byKey(const ValueKey('pad-11')), findsOneWidget);
  });
}
