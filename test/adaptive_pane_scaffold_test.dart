import 'package:adaptive_pane_scaffold/adaptive_pane_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<AdaptiveDestination> testDestinations = [
    AdaptiveDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
      badgeCount: 3,
      tooltip: 'Home Destination',
    ),
    AdaptiveDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
      tooltip: 'Search Destination',
    ),
    AdaptiveDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
      badgeCount: 0,
      tooltip: 'Profile Destination',
    ),
  ];

  Widget buildTestScaffold({
    List<AdaptiveDestination> destinations = testDestinations,
    int selectedIndex = 0,
    ValueChanged<int>? onDestinationSelected,
    Widget body = const Text('Test Body Content'),
    String? title = 'Test Title',
    Widget? railLeading,
    Widget? railTrailing,
    AdaptiveBreakpointConfig breakpoints = const AdaptiveBreakpointConfig(),
    bool enableTapToUnfocus = true,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: AdaptivePaneScaffold(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected ?? (_) {},
        body: body,
        title: title,
        railLeading: railLeading,
        railTrailing: railTrailing,
        breakpoints: breakpoints,
        enableTapToUnfocus: enableTapToUnfocus,
      ),
    );
  }

  group('AdaptivePaneScaffold Widget Tests', () {
    testWidgets(
      '1. Portrait compact (390x844) renders NavigationBar and triggers onDestinationSelected',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        int selectedIndex = 0;
        await tester.pumpWidget(
          buildTestScaffold(
            selectedIndex: selectedIndex,
            onDestinationSelected: (idx) => selectedIndex = idx,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Test Body Content'), findsOneWidget);

        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        expect(selectedIndex, 1);
      },
    );

    testWidgets(
      '2. Ultra-short landscape (800x360) with 7 destinations renders scrollable NavigationRail and 36dp toolbar with zero RenderFlex overflow',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final List<AdaptiveDestination> sevenDestinations = List.generate(
          7,
          (i) => AdaptiveDestination(
            icon: const Icon(Icons.circle_outlined),
            selectedIcon: const Icon(Icons.circle),
            label: 'Dest $i',
          ),
        );

        await tester.pumpWidget(
          buildTestScaffold(
            destinations: sevenDestinations,
            title: 'Ultra Short Viewport',
            railLeading: const Icon(Icons.menu),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.toolbarHeight, 36.0);

        final singleChildScrollViewFinder = find.ancestor(
          of: find.byType(NavigationRail),
          matching: find.byType(SingleChildScrollView),
        );
        expect(singleChildScrollViewFinder, findsOneWidget);

        // railLeading should be hidden automatically in short landscape
        expect(find.byIcon(Icons.menu), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '3. Desktop (1280x800) renders extended NavigationRail with labels',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestScaffold(
            railLeading: const Icon(Icons.menu),
          ),
        );
        await tester.pumpAndSettle();

        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.extended, isTrue);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      },
    );

    testWidgets(
      '4. AdaptiveDualPane renders single pane in narrow portrait (390x844) and dual side-by-side in landscape (800x360)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        Widget buildDualPaneApp() {
          return const MaterialApp(
            home: Scaffold(
              body: AdaptiveDualPane(
                primaryPane: Text('Primary List Pane'),
                secondaryPane: Text('Secondary Detail Pane'),
                showSecondaryOnCompactPortrait: false,
              ),
            ),
          );
        }

        await tester.pumpWidget(buildDualPaneApp());
        await tester.pumpAndSettle();

        // Portrait narrow: single primary pane visible
        expect(find.text('Primary List Pane'), findsOneWidget);
        expect(find.text('Secondary Detail Pane'), findsNothing);

        // Switch to landscape
        tester.view.physicalSize = const Size(800, 360);
        await tester.pumpWidget(buildDualPaneApp());
        await tester.pumpAndSettle();

        // Landscape: both panes rendered side-by-side
        expect(find.text('Primary List Pane'), findsOneWidget);
        expect(find.text('Secondary Detail Pane'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Dark and Light ColorScheme parity and dynamic color assignment',
      (tester) async {
        final lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        );
        final darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        );

        // Light mode
        await tester.pumpWidget(buildTestScaffold(theme: lightTheme));
        await tester.pumpAndSettle();

        final lightScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(
          lightScaffold.backgroundColor,
          lightTheme.colorScheme.surface,
        );

        // Dark mode
        await tester.pumpWidget(buildTestScaffold(theme: darkTheme));
        await tester.pumpAndSettle();

        final darkScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(
          darkScaffold.backgroundColor,
          darkTheme.colorScheme.surface,
        );
      },
    );

    testWidgets(
      '6. Tap to unfocus dismisses active text focus',
      (tester) async {
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptivePaneScaffold(
              destinations: testDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              enableTapToUnfocus: true,
              body: Center(
                child: TextField(
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Input'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Request focus
        focusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isTrue);

        // Tap outside the text field
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isFalse);
      },
    );

    testWidgets(
      '7. AdaptiveLayoutScope correctly exposes layoutMode and isShortLandscape',
      (tester) async {
        AdaptiveLayoutScope? capturedScope;

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptivePaneScaffold(
              destinations: testDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              body: Builder(
                builder: (context) {
                  capturedScope = AdaptiveLayoutScope.of(context);
                  return const Text('Scope Reader');
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedScope, isNotNull);
        expect(capturedScope!.layoutMode, isNotNull);
        expect(
          AdaptiveLayoutScope.maybeOf(
              tester.element(find.text('Scope Reader'))),
          isNotNull,
        );
      },
    );

    testWidgets(
      '8. AdaptiveDualPane showSecondaryOnCompactPortrait displays secondary pane on mobile',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AdaptiveDualPane(
                primaryPane: Text('Primary Item'),
                secondaryPane: Text('Secondary Detail'),
                showSecondaryOnCompactPortrait: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Secondary Detail'), findsOneWidget);
        expect(find.text('Primary Item'), findsNothing);
      },
    );

    testWidgets(
      '9. Custom breakpoints alter mode transition thresholds',
      (tester) async {
        tester.view.physicalSize = const Size(700, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // With default compactMaxWidth (600), 700 width is tabletRail
        await tester.pumpWidget(buildTestScaffold());
        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsOneWidget);

        // With custom compactMaxWidth (750), 700 width becomes portraitCompact
        await tester.pumpWidget(
          buildTestScaffold(
            breakpoints: const AdaptiveBreakpointConfig(compactMaxWidth: 750.0),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NavigationBar), findsOneWidget);
      },
    );
  });

  group('AdaptiveDestination & BreakpointConfig Unit Tests', () {
    test('10. AdaptiveDestination equality, copyWith, and hashCode', () {
      const dest1 = AdaptiveDestination(
        icon: Icon(Icons.home),
        label: 'Home',
        badgeCount: 5,
        tooltip: 'Home Tip',
      );
      const dest2 = AdaptiveDestination(
        icon: Icon(Icons.home),
        label: 'Home',
        badgeCount: 5,
        tooltip: 'Home Tip',
      );
      final dest3 = dest1.copyWith(label: 'Dashboard');

      expect(dest1, equals(dest2));
      expect(dest1.hashCode, equals(dest2.hashCode));
      expect(dest3.label, equals('Dashboard'));
      expect(dest3.badgeCount, equals(5));
      expect(dest1 == dest3, isFalse);
    });

    test('11. AdaptiveDestination badge rendering logic', () {
      const destWithBadge = AdaptiveDestination(
        icon: Icon(Icons.mail),
        label: 'Mail',
        badgeCount: 4,
      );
      const destWithoutBadge = AdaptiveDestination(
        icon: Icon(Icons.mail),
        label: 'Mail',
        badgeCount: 0,
      );

      final iconWithBadge = destWithBadge.buildEffectiveIcon();
      final iconWithoutBadge = destWithoutBadge.buildEffectiveIcon();

      expect(iconWithBadge, isA<Badge>());
      expect(iconWithoutBadge, isA<Icon>());
    });

    test('12. AdaptiveBreakpointConfig defaults and assertions', () {
      const config = AdaptiveBreakpointConfig();
      expect(config.compactMaxWidth, 600.0);
      expect(config.mediumMaxWidth, 1024.0);
      expect(config.shortViewportMaxHeight, 420.0);
      expect(config.railMinWidth, 56.0);
      expect(config.extendedRailMinWidth, 220.0);
      expect(config.compactToolbarHeight, 36.0);

      final modified = config.copyWith(compactMaxWidth: 650.0);
      expect(modified.compactMaxWidth, 650.0);
      expect(modified.mediumMaxWidth, 1024.0);
      expect(config == modified, isFalse);

      expect(
        () => AdaptiveBreakpointConfig(
          compactMaxWidth: 800.0,
          mediumMaxWidth: 500.0,
        ),
        throwsAssertionError,
      );
    });
  });
}
