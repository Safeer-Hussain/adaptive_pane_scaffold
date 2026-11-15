import 'package:flutter/widgets.dart';

import '../models/adaptive_breakpoint_config.dart';

/// Categorizes the current layout tier based on viewport dimensions and orientation.
enum AdaptiveLayoutMode {
  /// Compact mobile viewport in portrait orientation.
  ///
  /// Typically renders a bottom navigation bar and full-width primary content.
  portraitCompact,

  /// Compact mobile viewport in landscape orientation or short viewport.
  ///
  /// Typically renders a compressed toolbar and a compact scrollable side rail.
  landscapeCompact,

  /// Medium viewport such as tablets or foldables.
  ///
  /// Renders a standard unextended navigation rail and dual-pane content if available.
  tabletRail,

  /// Large viewport such as desktop monitors or expanded browser windows.
  ///
  /// Renders an extended navigation rail with visible labels and wide dual panes.
  desktopExtended,
}

/// An [InheritedWidget] providing adaptive layout metrics to descendant widgets.
///
/// Descendants can inspect [layoutMode], [isShortLandscape], and active [breakpoints]
/// to adjust visual presentations dynamically.
class AdaptiveLayoutScope extends InheritedWidget {
  /// Creates an adaptive layout scope.
  const AdaptiveLayoutScope({
    super.key,
    required this.layoutMode,
    required this.isShortLandscape,
    required this.breakpoints,
    required super.child,
  });

  /// The active layout classification calculated for the current viewport.
  final AdaptiveLayoutMode layoutMode;

  /// Whether the current viewport is in a compact landscape orientation or
  /// has a height below [AdaptiveBreakpointConfig.shortViewportMaxHeight].
  final bool isShortLandscape;

  /// The active breakpoint configuration guiding layout mode decisions.
  final AdaptiveBreakpointConfig breakpoints;

  /// Returns the nearest [AdaptiveLayoutScope] ancestor, throwing an assertion
  /// error if none is found.
  static AdaptiveLayoutScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AdaptiveLayoutScope found in the widget tree');
    return scope!;
  }

  /// Returns the nearest [AdaptiveLayoutScope] ancestor, or null if not found.
  static AdaptiveLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveLayoutScope>();
  }

  @override
  bool updateShouldNotify(AdaptiveLayoutScope oldWidget) {
    return layoutMode != oldWidget.layoutMode ||
        isShortLandscape != oldWidget.isShortLandscape ||
        breakpoints != oldWidget.breakpoints;
  }
}
