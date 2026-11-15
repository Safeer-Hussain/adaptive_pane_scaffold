import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdaptivePaneExampleApp renders and navigates',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AdaptivePaneExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Verify master and detail views render side-by-side on wide viewport
    expect(find.text('Record Item #1'), findsOneWidget);
    expect(find.text('Detailed Inspection #1'), findsOneWidget);

    // Tap theme toggle button
    final themeToggleFinder = find.byTooltip('Toggle theme mode');
    expect(themeToggleFinder, findsOneWidget);
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // Tap record #2
    final record2Finder = find.text('Record Item #2');
    expect(record2Finder, findsOneWidget);
    await tester.tap(record2Finder);
    await tester.pumpAndSettle();

    expect(find.text('Detailed Inspection #2'), findsOneWidget);
  });
}
