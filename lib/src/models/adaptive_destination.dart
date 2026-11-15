import 'package:flutter/material.dart';

/// Represents a destination item within an adaptive navigation hierarchy.
///
/// Encapsulates the visual icon, an optional selected state icon, a text
/// label, an optional badge count, and an optional tooltip string. Used by
/// both [NavigationBar] in compact portrait modes and [NavigationRail] in
/// landscape, tablet, and desktop modes.
@immutable
class AdaptiveDestination {
  /// Creates an immutable adaptive destination configuration.
  ///
  /// The [icon] and [label] arguments must not be null.
  const AdaptiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.tooltip,
  });

  /// The primary icon widget displayed for this destination.
  final Widget icon;

  /// An optional alternative icon widget displayed when this destination is selected.
  final Widget? selectedIcon;

  /// The textual label identifying this navigation destination.
  final String label;

  /// An optional numeric badge count.
  ///
  /// When non-null and greater than zero, a Material 3 [Badge] is rendered
  /// atop the destination icon.
  final int? badgeCount;

  /// An optional accessibility and hover tooltip text string.
  final String? tooltip;

  /// Builds the effective icon widget, wrapping it in a Material 3 [Badge]
  /// if [badgeCount] is non-null and greater than zero.
  Widget buildEffectiveIcon({bool isSelected = false}) {
    final effectiveIcon =
        (isSelected && selectedIcon != null) ? selectedIcon! : icon;
    if (badgeCount != null && badgeCount! > 0) {
      return Badge.count(
        count: badgeCount!,
        child: effectiveIcon,
      );
    }
    return effectiveIcon;
  }

  /// Creates a copy of this [AdaptiveDestination] with the given fields replaced.
  AdaptiveDestination copyWith({
    Widget? icon,
    Widget? selectedIcon,
    String? label,
    int? badgeCount,
    String? tooltip,
  }) {
    return AdaptiveDestination(
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      label: label ?? this.label,
      badgeCount: badgeCount ?? this.badgeCount,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  static bool _widgetEquals(Widget? a, Widget? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.runtimeType != b.runtimeType || a.key != b.key) {
      return false;
    }
    if (a is Icon && b is Icon) {
      return a.icon == b.icon &&
          a.size == b.size &&
          a.color == b.color &&
          a.semanticLabel == b.semanticLabel;
    }
    return a == b;
  }

  static int _widgetHashCode(Widget? widget) {
    if (widget == null) {
      return 0;
    }
    if (widget is Icon) {
      return Object.hash(
        widget.runtimeType,
        widget.key,
        widget.icon,
        widget.size,
        widget.color,
      );
    }
    return widget.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AdaptiveDestination &&
        _widgetEquals(other.icon, icon) &&
        _widgetEquals(other.selectedIcon, selectedIcon) &&
        other.label == label &&
        other.badgeCount == badgeCount &&
        other.tooltip == tooltip;
  }

  @override
  int get hashCode => Object.hash(
        _widgetHashCode(icon),
        _widgetHashCode(selectedIcon),
        label,
        badgeCount,
        tooltip,
      );
}
