import 'package:adaptive_pane_scaffold/adaptive_pane_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdaptivePaneExampleApp());
}

/// The root example application widget.
class AdaptivePaneExampleApp extends StatefulWidget {
  /// Creates the adaptive pane example application.
  const AdaptivePaneExampleApp({super.key});

  @override
  State<AdaptivePaneExampleApp> createState() => _AdaptivePaneExampleAppState();
}

class _AdaptivePaneExampleAppState extends State<AdaptivePaneExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Pane Scaffold Example',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: ExampleScaffoldScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

/// The main interactive screen showcasing adaptive dual pane navigation.
class ExampleScaffoldScreen extends StatefulWidget {
  /// Creates the example scaffold screen.
  const ExampleScaffoldScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  /// Callback to toggle between light and dark themes.
  final VoidCallback onToggleTheme;

  /// Whether dark theme is currently active.
  final bool isDarkMode;

  @override
  State<ExampleScaffoldScreen> createState() => _ExampleScaffoldScreenState();
}

class _ExampleScaffoldScreenState extends State<ExampleScaffoldScreen> {
  int _selectedDestinationIndex = 0;
  int _selectedItemId = 1;
  int _inboxBadgeCount = 5;
  int _messagesBadgeCount = 3;

  final ScrollController _primaryScrollController = ScrollController();
  final ScrollController _secondaryScrollController = ScrollController();

  @override
  void dispose() {
    _primaryScrollController.dispose();
    _secondaryScrollController.dispose();
    super.dispose();
  }

  void _markItemAsRead() {
    if (_inboxBadgeCount > 0) {
      setState(() {
        _inboxBadgeCount--;
      });
    }
  }

  void _addNewMessage() {
    setState(() {
      _messagesBadgeCount++;
    });
  }

  List<AdaptiveDestination> _buildDestinations() {
    return [
      AdaptiveDestination(
        icon: const Icon(Icons.inbox_outlined),
        selectedIcon: const Icon(Icons.inbox),
        label: 'Inbox',
        badgeCount: _inboxBadgeCount > 0 ? _inboxBadgeCount : null,
        tooltip: 'Inbox overview',
      ),
      const AdaptiveDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: 'Projects',
        badgeCount: 2,
        tooltip: 'Active projects',
      ),
      const AdaptiveDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Analytics',
        tooltip: 'Performance metrics',
      ),
      AdaptiveDestination(
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
        label: 'Messages',
        badgeCount: _messagesBadgeCount > 0 ? _messagesBadgeCount : null,
        tooltip: 'Direct communications',
      ),
      const AdaptiveDestination(
        icon: Icon(Icons.tune_outlined),
        selectedIcon: Icon(Icons.tune),
        label: 'Settings',
        tooltip: 'Application preferences',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final theme = Theme.of(context);

    return AdaptivePaneScaffold(
      destinations: destinations,
      selectedIndex: _selectedDestinationIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedDestinationIndex = index;
        });
      },
      title: destinations[_selectedDestinationIndex].label,
      actions: [
        IconButton(
          tooltip: 'Add message badge',
          icon: const Icon(Icons.add_comment_outlined),
          onPressed: _addNewMessage,
        ),
        IconButton(
          tooltip: 'Toggle theme mode',
          icon: Icon(
            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: widget.onToggleTheme,
        ),
      ],
      railLeading: IconButton(
        tooltip: 'Menu',
        icon: const Icon(Icons.menu),
        onPressed: () {},
      ),
      railTrailing: IconButton(
        tooltip: 'Help',
        icon: const Icon(Icons.help_outline),
        onPressed: () {},
      ),
      body: AdaptiveDualPane(
        primaryRatio: 0.38,
        paneSpacing: 16.0,
        primaryScrollController: _primaryScrollController,
        secondaryScrollController: _secondaryScrollController,
        primaryPane: _buildMasterList(theme),
        secondaryPane: _buildDetailView(theme),
      ),
    );
  }

  Widget _buildMasterList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Records (${destinationsTitle()})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (int i = 1; i <= 25; i++)
          Card(
            elevation: _selectedItemId == i ? 2 : 0,
            margin: const EdgeInsets.only(bottom: 8.0),
            color: _selectedItemId == i
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: ListTile(
              selected: _selectedItemId == i,
              leading: CircleAvatar(
                backgroundColor: _selectedItemId == i
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                foregroundColor: _selectedItemId == i
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                child: Text('$i'),
              ),
              title: Text(
                'Record Item #$i',
                style: TextStyle(
                  fontWeight: _selectedItemId == i
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text('Category: ${_selectedDestinationIndex + 1}.0.$i'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                setState(() {
                  _selectedItemId = i;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDetailView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 1,
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Detailed Inspection #$_selectedItemId',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _markItemAsRead,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Mark Read'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Associated Destination: ${destinationsTitle()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Operational Telemetry & Logs',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (int p = 1; p <= 6; p++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Section $p: This pane scrolls completely independently from the primary list '
              'pane. The dual pane architecture ensures seamless side-by-side analysis '
              'in landscape, tablet, and desktop viewports, while automatically adapting '
              'to single-pane display on compact portrait screens.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  String destinationsTitle() {
    switch (_selectedDestinationIndex) {
      case 0:
        return 'Inbox';
      case 1:
        return 'Projects';
      case 2:
        return 'Analytics';
      case 3:
        return 'Messages';
      case 4:
        return 'Settings';
      default:
        return 'Overview';
    }
  }
}
