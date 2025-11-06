// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chat_offline/main.dart';

void main() {
  testWidgets('LanChat app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LanChatApp());

    // The onboarding screen should be shown first (check for a unique text or widget)
    expect(find.text('Offline LAN Chat'), findsOneWidget);
    // Optionally, check for the 'Get Started' button
    expect(find.text('Get Started'), findsOneWidget);
  });
}
