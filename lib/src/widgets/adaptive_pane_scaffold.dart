import 'package:flutter/material.dart';

import '../models/adaptive_breakpoint_config.dart';
import '../models/adaptive_destination.dart';
import 'adaptive_layout_scope.dart';

/// A production-grade responsive scaffold that automatically adapts navigation
/// and layout presentation across mobile, tablet, and desktop form factors.
///
/// Features:
/// - Bottom [NavigationBar] on compact portrait viewports.
/// - Scrollable [NavigationRail] on landscape, tablet, and desktop viewports.
/// - Automatic compact toolbar compression (36.0 logical pixels) on short landscape viewports.
/// - 360dp-safe vertical scrolling inside [NavigationRail] to avoid flex overflow.
/// - Extended [NavigationRail] with visible destination labels on desktop viewports.
/// - Built-in root tap-to-unfocus gesture detection.
/// - Zero hardcoded colors, dynamically bound to [ColorScheme].
class AdaptivePaneScaffold extends StatelessWidget {
  /// Creates an adaptive pane scaffold.
  ///
  /// The [destinations] list must contain at least 2 items.
  /// The [selectedIndex] must be within the bounds of [destinations].
  const AdaptivePaneScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.railLeading,
    this.railTrailing,
    this.breakpoints = const AdaptiveBreakpointConfig(),
    this.enableTapToUnfocus = true,
  })  : assert(
          destinations.length >= 2,
          'destinations must contain at least 2 destinations',
        ),
        assert(
          selectedIndex >= 0 && selectedIndex < destinations.length,
          'selectedIndex must be within valid destinations range',
        );

  /// The list of navigation destinations presented across navigation components.
  final List<AdaptiveDestination> destinations;

  /// The index of the currently active destination.
  final int selectedIndex;

  /// Called when the user selects a destination item.
  final ValueChanged<int> onDestinationSelected;

  /// The primary content area widget displayed in the scaffold body.
  final Widget body;

  /// Optional text title displayed in the app bar.
  ///
  /// Ignored if [titleWidget] is provided.
  final String? title;

  /// Optional custom widget displayed as the app bar title.
  final Widget? titleWidget;

  /// Optional list of action widgets displayed in the app bar trailing section.
  final List<Widget>? actions;

  /// Optional floating action button widget.
  final Widget? floatingActionButton;

  /// Optional positioning for the [floatingActionButton].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional widget displayed above the rail destinations.
  ///
  /// Automatically omitted in short landscape orientation to maximize space.
  final Widget? railLeading;

  /// Optional widget displayed below the rail destinations.
  final Widget? railTrailing;

  /// The breakpoint configuration governing layout transitions.
  final AdaptiveBreakpointConfig breakpoints;

  /// Whether tapping non-interactive areas dismisses the primary input focus.
  ///
  /// Defaults to true.
  final bool enableTapToUnfocus;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    final isShortLandscape = (orientation == Orientation.landscape &&
            size.height <= breakpoints.shortViewportMaxHeight) ||
        (size.height <= breakpoints.shortViewportMaxHeight &&
            size.width > size.height);

    final AdaptiveLayoutMode layoutMode;
    if (isShortLandscape) {
      layoutMode = AdaptiveLayoutMode.landscapeCompact;
    } else if (size.width < breakpoints.compactMaxWidth) {
      layoutMode = (orientation == Orientation.landscape)
          ? AdaptiveLayoutMode.landscapeCompact
          : AdaptiveLayoutMode.portraitCompact;
    } else if (size.width < breakpoints.mediumMaxWidth) {
      layoutMode = AdaptiveLayoutMode.tabletRail;
    } else {
      layoutMode = AdaptiveLayoutMode.desktopExtended;
    }

    final isPortraitCompact = layoutMode == AdaptiveLayoutMode.portraitCompact;
    final isDesktopExtended = layoutMode == AdaptiveLayoutMode.desktopExtended;

    PreferredSizeWidget? appBar;
    if (title != null || titleWidget != null || actions != null) {
      final double effectiveToolbarHeight =
          isShortLandscape ? breakpoints.compactToolbarHeight : kToolbarHeight;

      final Widget? effectiveTitle = titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: isShortLandscape
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                )
              : null);

      appBar = AppBar(
        toolbarHeight: effectiveToolbarHeight,
        title: effectiveTitle,
        actions: actions,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      );
    }

    Widget contentBody;
    if (isPortraitCompact) {
      contentBody = body;
    } else {
      final railDestinations = destinations
          .map(
            (destination) => NavigationRailDestination(
              icon: destination.buildEffectiveIcon(isSelected: false),
              selectedIcon: destination.buildEffectiveIcon(isSelected: true),
              label: Text(destination.label),
            ),
          )
          .toList();

      final navigationRail = NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        extended: isDesktopExtended,
        minWidth: breakpoints.railMinWidth,
        minExtendedWidth: breakpoints.extendedRailMinWidth,
        labelType: isDesktopExtended
            ? null
            : (isShortLandscape
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all),
        leading: isShortLandscape ? null : railLeading,
        trailing: railTrailing,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: railDestinations,
      );

      final scrollableRail = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: IntrinsicHeight(
          child: navigationRail,
        ),
      );

      contentBody = Row(
        children: [
          scrollableRail,
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(child: body),
        ],
      );
    }

    Widget? bottomNavBar;
    if (isPortraitCompact) {
      bottomNavBar = NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: destinations
            .map(
              (destination) => NavigationDestination(
                icon: destination.buildEffectiveIcon(isSelected: false),
                selectedIcon: destination.buildEffectiveIcon(isSelected: true),
                label: destination.label,
                tooltip: destination.tooltip,
              ),
            )
            .toList(),
      );
    }

    Widget scaffold = Scaffold(
      appBar: appBar,
      body: contentBody,
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );

    if (enableTapToUnfocus) {
      scaffold = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: scaffold,
      );
    }

    return AdaptiveLayoutScope(
      layoutMode: layoutMode,
      isShortLandscape: isShortLandscape,
      breakpoints: breakpoints,
      child: scaffold,
    );
  }
}
