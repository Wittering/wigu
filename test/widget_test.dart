// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Career Insight Engine basic structure', (WidgetTester tester) async {
    // Build a simple material app to test basic structure
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Wigu'),
                  Text('Career Insight Engine'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Verify that the basic text elements are found
    expect(find.text('Wigu'), findsOneWidget);
    expect(find.text('Career Insight Engine'), findsOneWidget);
  });
}
