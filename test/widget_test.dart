import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:navigation_assistant/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NavigationAssistantApp());

    // Verify that the app starts with HomeScreen
    expect(find.text('Навигационный помощник'), findsOneWidget);
    expect(find.text('Запустить навигационную помощь'), findsOneWidget);
  });

  testWidgets('Navigation to camera screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Tap the camera button and trigger a frame
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();

    // Verify that we navigated to camera screen
    expect(find.text('Навигационный помощник - Камера'), findsOneWidget);
    expect(find.text('Режим компьютерного зрения'), findsOneWidget);
  });

  testWidgets('Camera screen initial state', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Камера готова к работе'), findsOneWidget);
    expect(find.text('Активировать камеру'), findsOneWidget);
  });

  testWidgets('Camera activation works', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();

    // Tap activate camera button
    await tester.tap(find.text('Активировать камеру'));
    await tester.pump();

    // Should show loading
    expect(find.text('Активация камеры...'), findsOneWidget);

    // Wait for loading to complete
    await tester.pump(const Duration(seconds: 3));

    // Should show active camera state
    expect(find.text('КАМЕРА АКТИВНА'), findsOneWidget);
    expect(find.text('Выключить'), findsOneWidget);
  });

  testWidgets('Object detection simulation', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen and activate camera
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Активировать камеру'));
    await tester.pump(const Duration(seconds: 3));

    // Tap scan button
    await tester.tap(find.text('Сканировать'));
    await tester.pump();

    // Should show snackbar with detection results
    expect(find.text('Обнаружено 4 объекта вокруг'), findsOneWidget);
  });

  testWidgets('Danger detection simulation', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen and activate camera
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Активировать камеру'));
    await tester.pump(const Duration(seconds: 3));

    // Tap dangers button
    await tester.tap(find.text('Опасности'));
    await tester.pump();

    // Should show dialog with dangers
    expect(find.text('Обнаружены препятствия'), findsOneWidget);
  });

  testWidgets('Back navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();

    // Go back using app bar back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Should be back on home screen
    expect(find.text('Навигационный помощник'), findsOneWidget);
    expect(find.text('Запустить навигационную помощь'), findsOneWidget);
  });

  testWidgets('Camera deactivation works', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationAssistantApp());

    // Navigate to camera screen and activate camera
    await tester.tap(find.text('Запустить навигационную помощь'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Активировать камеру'));
    await tester.pump(const Duration(seconds: 3));

    // Deactivate camera
    await tester.tap(find.text('Выключить'));
    await tester.pump();

    // Should return to initial camera state
    expect(find.text('Камера готова к работе'), findsOneWidget);
    expect(find.text('Активировать камеру'), findsOneWidget);
  });
}