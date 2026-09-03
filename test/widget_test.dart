import 'package:dsx_drum_kendang/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts the MGR drum app', (tester) async {
    await tester.pumpWidget(const DsxDrumKendangApp());

    expect(find.byKey(const ValueKey('mgr-logo')), findsOneWidget);
  });
}
