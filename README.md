# adaptive_pane_scaffold

[![pub package](https://img.shields.io/pub/v/adaptive_pane_scaffold.svg)](https://pub.dev/packages/adaptive_pane_scaffold)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/github/actions/workflow/status/Safeer-Hussain/adaptive_pane_scaffold/ci.yml?branch=main)](https://github.com/Safeer-Hussain/adaptive_pane_scaffold/actions)

A production-grade, zero-external-dependency Flutter UI package engineered for responsive dual-pane navigation. Provides a 360dp-safe scrollable NavigationRail, compact landscape toolbar compression, and independent master-detail pane scrolling across mobile, tablet, and desktop viewports.

Repository: [https://github.com/Safeer-Hussain/adaptive_pane_scaffold](https://github.com/Safeer-Hussain/adaptive_pane_scaffold)  
Issue Tracker: [https://github.com/Safeer-Hussain/adaptive_pane_scaffold/issues](https://github.com/Safeer-Hussain/adaptive_pane_scaffold/issues)

## Features

| Feature | Description |
| --- | --- |
| Responsive Navigation | Switches between bottom NavigationBar on portrait compact viewports and left NavigationRail on landscape, tablet, and desktop viewports. |
| 360dp-Safe Scrollable Rail | Wraps NavigationRail in an IntrinsicHeight SingleChildScrollView with ClampingScrollPhysics to eliminate RenderFlex overflow on ultra-short screens (320dp-360dp height). |
| Compact Landscape Toolbar | Automatically compresses AppBar to 36dp height and hides railLeading in short landscape viewports to maximize vertical reading area. |
| Adaptive Dual Pane | Master-detail layout supporting customizable split ratio, divider visibility, custom spacing, and independent scrolling. |
| Adaptive Layout Scope | InheritedWidget exposing current AdaptiveLayoutMode (portraitCompact, landscapeCompact, tabletRail, desktopExtended) and isShortLandscape. |
| Material 3 Dynamic Colors | Derives all colors dynamically from Theme.of(context).colorScheme with zero hardcoded palette values. |
| Zero External Dependencies | Built entirely upon the Flutter SDK with no third-party package dependencies. |

## Breakpoint Matrix

| Layout Mode | Viewport Criteria | Navigation Component | Toolbar Height |
| --- | --- | --- | --- |
| portraitCompact | Width < 600dp and portrait orientation | Bottom NavigationBar | Standard (56dp) |
| landscapeCompact | Height <= 420dp or landscape with width < 1024dp | Scrollable NavigationRail (minWidth: 56dp, no labels) | Compact (36dp) |
| tabletRail | 600dp <= Width < 1024dp and Height > 420dp | Left NavigationRail (minWidth: 56dp, labels visible) | Standard (56dp) |
| desktopExtended | Width >= 1024dp | Extended NavigationRail (minExtendedWidth: 220dp, labels visible) | Standard (56dp) |

## Installation

Add adaptive_pane_scaffold to your pubspec.yaml dependencies:

```bash
flutter pub add adaptive_pane_scaffold
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_pane_scaffold: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:adaptive_pane_scaffold/adaptive_pane_scaffold.dart';
import 'package:flutter/material.dart';
```

### Complete Example

```dart
import 'package:adaptive_pane_scaffold/adaptive_pane_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Pane Scaffold Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedItemId = 1;

  final List<AdaptiveDestination> _destinations = const [
    AdaptiveDestination(
      icon: Icon(Icons.inbox_outlined),
      selectedIcon: Icon(Icons.inbox),
      label: 'Inbox',
      badgeCount: 3,
      tooltip: 'Inbox messages',
    ),
    AdaptiveDestination(
      icon: Icon(Icons.send_outlined),
      selectedIcon: Icon(Icons.send),
      label: 'Sent',
      tooltip: 'Sent messages',
    ),
    AdaptiveDestination(
      icon: Icon(Icons.star_outline),
      selectedIcon: Icon(Icons.star),
      label: 'Favorites',
      tooltip: 'Starred messages',
    ),
    AdaptiveDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
      tooltip: 'App settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptivePaneScaffold(
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      title: 'Mailbox',
      body: AdaptiveDualPane(
        primaryPane: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            final id = index + 1;
            final isSelected = id == _selectedItemId;
            return ListTile(
              selected: isSelected,
              title: Text('Message #$id'),
              subtitle: Text('Preview snippet for item $id...'),
              onTap: () {
                setState(() {
                  _selectedItemId = id;
                });
              },
            );
          },
        ),
        secondaryPane: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Reading Message #$_selectedItemId',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('Full content of selected message displays here.'),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Additional Information

- Source Code: [https://github.com/Safeer-Hussain/adaptive_pane_scaffold](https://github.com/Safeer-Hussain/adaptive_pane_scaffold)
- Issue Tracker: [https://github.com/Safeer-Hussain/adaptive_pane_scaffold/issues](https://github.com/Safeer-Hussain/adaptive_pane_scaffold/issues)
- Contributions: Pull requests and issue reports are welcome on GitHub.
- License: MIT License. See [LICENSE](https://github.com/Safeer-Hussain/adaptive_pane_scaffold/blob/main/LICENSE) for details.
