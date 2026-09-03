import 'package:dsx_drum_kendang/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts the DSX drum app', (tester) async {
    await tester.pumpWidget(const DsxDrumKendangApp());

    expect(find.text('DSX Drum Kendang'), findsOneWidget);
  });
}
