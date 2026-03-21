import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshMarketApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Bottom navigation has 5 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshMarketApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
