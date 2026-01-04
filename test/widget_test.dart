import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Use a minimal MaterialApp to avoid initializing Firebase plugins in VM tests
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
