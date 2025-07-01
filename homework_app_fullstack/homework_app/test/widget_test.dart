import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homework_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeworkApp());

    // Verify that our counter starts at 0.
    expect(find.text('Hi there! Welcome back'), findsOneWidget);
    expect(find.text('Parent Mode'), findsOneWidget);
    expect(find.text('Learner Mode'), findsOneWidget);
  });
}
