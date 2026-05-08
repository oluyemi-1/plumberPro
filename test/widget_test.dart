import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plumbing_and_heating/main.dart';

void main() {
  testWidgets('App boots into the splash screen', (tester) async {
    await tester.pumpWidget(const PlumberProApp());
    await tester.pump();
    // The branded splash shows the wordmark before routing to onboarding.
    expect(find.text('Plumber Pro'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    // Drain any pending timers so the test finishes cleanly without
    // chasing the delayed navigation.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
