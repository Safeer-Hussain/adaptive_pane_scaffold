import 'package:flutter/foundation.dart';

/// Defines layout thresholds and dimension configurations for adaptive layouts.
///
/// Controls when navigation transitions from bottom bars to side rails, when
/// compact landscape toolbar compression occurs, and the widths of collapsed
/// and extended rails.
@immutable
class AdaptiveBreakpointConfig {
  /// Creates an immutable adaptive breakpoint and dimension configuration.
  const AdaptiveBreakpointConfig({
    this.compactMaxWidth = 600.0,
    this.mediumMaxWidth = 1024.0,
    this.shortViewportMaxHeight = 420.0,
    this.railMinWidth = 56.0,
    this.extendedRailMinWidth = 220.0,
    this.compactToolbarHeight = 36.0,
  })  : assert(compactMaxWidth > 0, 'compactMaxWidth must be positive'),
        assert(
          mediumMaxWidth > compactMaxWidth,
          'mediumMaxWidth must be greater than compactMaxWidth',
        ),
        assert(
          shortViewportMaxHeight > 0,
          'shortViewportMaxHeight must be positive',
        ),
        assert(railMinWidth > 0, 'railMinWidth must be positive'),
        assert(
          extendedRailMinWidth > railMinWidth,
          'extendedRailMinWidth must be greater than railMinWidth',
        ),
        assert(
          compactToolbarHeight > 0,
          'compactToolbarHeight must be positive',
        );

  /// Maximum viewport width considered compact.
  ///
  /// Viewports narrower than this width in portrait orientation render a
  /// bottom navigation bar. Defaults to 600.0 logical pixels.
  final double compactMaxWidth;

  /// Maximum viewport width considered medium or tablet.
  ///
  /// Viewports at or above this width render an extended side rail.
  /// Defaults to 1024.0 logical pixels.
  final double mediumMaxWidth;

  /// Maximum viewport height considered short.
  ///
  /// Viewports at or below this height in landscape orientation compress the
  /// app bar toolbar to [compactToolbarHeight] and use a compact icon-only rail.
  /// Defaults to 420.0 logical pixels.
  final double shortViewportMaxHeight;

  /// Minimum width of the collapsed navigation rail.
  ///
  /// Used in landscape compact and tablet modes. Defaults to 56.0 logical pixels.
  final double railMinWidth;

  /// Minimum width of the extended navigation rail.
  ///
  /// Used in desktop extended modes where labels are shown alongside icons.
  /// Defaults to 220.0 logical pixels.
  final double extendedRailMinWidth;

  /// Compressed height of the app bar in short landscape viewports.
  ///
  /// Maximizes vertical content space on compact mobile screens rotated
  /// horizontally. Defaults to 36.0 logical pixels.
  final double compactToolbarHeight;

  /// Creates a copy of this configuration with the specified properties replaced.
  AdaptiveBreakpointConfig copyWith({
    double? compactMaxWidth,
    double? mediumMaxWidth,
    double? shortViewportMaxHeight,
    double? railMinWidth,
    double? extendedRailMinWidth,
    double? compactToolbarHeight,
  }) {
    return AdaptiveBreakpointConfig(
      compactMaxWidth: compactMaxWidth ?? this.compactMaxWidth,
      mediumMaxWidth: mediumMaxWidth ?? this.mediumMaxWidth,
      shortViewportMaxHeight:
          shortViewportMaxHeight ?? this.shortViewportMaxHeight,
      railMinWidth: railMinWidth ?? this.railMinWidth,
      extendedRailMinWidth: extendedRailMinWidth ?? this.extendedRailMinWidth,
      compactToolbarHeight: compactToolbarHeight ?? this.compactToolbarHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AdaptiveBreakpointConfig &&
        other.compactMaxWidth == compactMaxWidth &&
        other.mediumMaxWidth == mediumMaxWidth &&
        other.shortViewportMaxHeight == shortViewportMaxHeight &&
        other.railMinWidth == railMinWidth &&
        other.extendedRailMinWidth == extendedRailMinWidth &&
        other.compactToolbarHeight == compactToolbarHeight;
  }

  @override
  int get hashCode => Object.hash(
        compactMaxWidth,
        mediumMaxWidth,
        shortViewportMaxHeight,
        railMinWidth,
        extendedRailMinWidth,
        compactToolbarHeight,
      );
}
