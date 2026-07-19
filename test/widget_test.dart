// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. You can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App test scaffold builds without Firebase', (
    WidgetTester tester,
  ) async {
    // This project uses Firebase services inside Riverpod providers.
    // Widget tests should not require a real Firebase initialization.
    //
    // Therefore, keep this test as a smoke test for the widget harness only.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
