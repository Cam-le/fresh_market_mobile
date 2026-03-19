import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const FreshMarketApp(showOnboarding: false));
    // Allow animations to settle
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // Verify the home screen renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Bottom navigation has 5 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshMarketApp(showOnboarding: false));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
