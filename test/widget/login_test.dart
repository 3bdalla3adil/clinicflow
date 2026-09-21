import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clinicflow/features/auth/login_page.dart';

void main() {
  testWidgets('login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Assert something the LoginPage actually renders.
    // Change 'ClinicFlow' below if your page uses a different title.
    expect(find.text('ClinicFlow'), findsOneWidget);
  });
}
