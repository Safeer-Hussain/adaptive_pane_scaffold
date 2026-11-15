import 'package:flutter/material.dart';

import 'adaptive_layout_scope.dart';

/// An adaptive master-detail dual-pane layout widget.
///
/// In narrow portrait viewports, renders a single pane ([primaryPane] by default,
/// or [secondaryPane] when [showSecondaryOnCompactPortrait] is true).
/// In landscape, tablet, and desktop viewports, displays both panes side-by-side
/// with configurable width proportions, spacing, dividers, and independent scrolling.
class AdaptiveDualPane extends StatelessWidget {
  /// Creates an adaptive dual pane container.
  const AdaptiveDualPane({
    super.key,
    required this.primaryPane,
    required this.secondaryPane,
    this.primaryRatio = 0.35,
    this.paneSpacing = 12.0,
    this.showDivider = true,
    this.panePadding,
    this.primaryScrollController,
    this.secondaryScrollController,
    this.wrapInScrollViews = true,
    this.showSecondaryOnCompactPortrait = false,
  })  : assert(paneSpacing >= 0, 'paneSpacing must be non-negative'),
        assert(
          primaryRatio >= 0.0 && primaryRatio <= 1.0,
          'primaryRatio must be between 0.0 and 1.0',
        );

  /// The master/list pane widget displayed on the leading side.
  final Widget primaryPane;

  /// The detail pane widget displayed on the trailing side.
  final Widget secondaryPane;

  /// The fractional width allocated to [primaryPane] in dual-pane view.
  ///
  /// Clamped between 0.2 and 0.8 to prevent either pane from becoming unusable.
  /// Defaults to 0.35.
  final double primaryRatio;

  /// The horizontal separation distance between the two panes.
  ///
  /// Defaults to 12.0 logical pixels.
  final double paneSpacing;

  /// Whether to render a subtle vertical divider line between the two panes.
  ///
  /// Defaults to true.
  final bool showDivider;

  /// Optional padding applied around the content of each pane.
  ///
  /// When null, defaults to horizontal 12, vertical 8 in short landscape viewports,
  /// and 16 on all edges otherwise.
  final EdgeInsetsGeometry? panePadding;

  /// Optional scroll controller attached to the [primaryPane] scroll view.
  final ScrollController? primaryScrollController;

  /// Optional scroll controller attached to the [secondaryPane] scroll view.
  final ScrollController? secondaryScrollController;

  /// Whether each pane should be wrapped in an independent [SingleChildScrollView].
  ///
  /// When true, wraps each pane in a [SingleChildScrollView] with [ClampingScrollPhysics].
  /// Set to false if panes already contain internal scrollable widgets such as [ListView].
  /// Defaults to true.
  final bool wrapInScrollViews;

  /// Whether to display [secondaryPane] instead of [primaryPane] in compact portrait mode.
  ///
  /// Useful for master-detail navigation flows where selecting an item in the master list
  /// displays the detail view on compact phone screens. Defaults to false.
  final bool showSecondaryOnCompactPortrait;

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveLayoutScope.maybeOf(context);
    final bool isCompactPortrait;
    final bool isShortLandscape;

    if (scope != null) {
      isCompactPortrait =
          scope.layoutMode == AdaptiveLayoutMode.portraitCompact;
      isShortLandscape = scope.isShortLandscape;
    } else {
      final size = MediaQuery.sizeOf(context);
      final orientation = MediaQuery.orientationOf(context);
      isCompactPortrait =
          orientation == Orientation.portrait && size.width < 600.0;
      isShortLandscape =
          (orientation == Orientation.landscape && size.height <= 420.0) ||
              (size.height <= 420.0 && size.width > size.height);
    }

    final effectivePadding = panePadding ??
        (isShortLandscape
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.all(16));

    if (isCompactPortrait) {
      final targetPane =
          showSecondaryOnCompactPortrait ? secondaryPane : primaryPane;
      final targetController = showSecondaryOnCompactPortrait
          ? secondaryScrollController
          : primaryScrollController;

      final Widget paneContent;
      if (wrapInScrollViews) {
        paneContent = SingleChildScrollView(
          controller: targetController,
          physics: const ClampingScrollPhysics(),
          child: targetPane,
        );
      } else {
        paneContent = targetPane;
      }

      return Padding(
        padding: effectivePadding,
        child: paneContent,
      );
    }

    final clampedRatio = primaryRatio.clamp(0.2, 0.8);
    final primaryFlex = (clampedRatio * 1000).round();
    final secondaryFlex = ((1.0 - clampedRatio) * 1000).round();

    final Widget primaryContent = wrapInScrollViews
        ? SingleChildScrollView(
            controller: primaryScrollController,
            physics: const ClampingScrollPhysics(),
            child: primaryPane,
          )
        : primaryPane;

    final Widget secondaryContent = wrapInScrollViews
        ? SingleChildScrollView(
            controller: secondaryScrollController,
            physics: const ClampingScrollPhysics(),
            child: secondaryPane,
          )
        : secondaryPane;

    final Widget separator;
    if (showDivider) {
      separator = SizedBox(
        width: paneSpacing,
        child: Center(
          child: VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      );
    } else {
      separator = SizedBox(width: paneSpacing);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: primaryFlex,
          child: Padding(
            padding: effectivePadding,
            child: primaryContent,
          ),
        ),
        separator,
        Expanded(
          flex: secondaryFlex,
          child: Padding(
            padding: effectivePadding,
            child: secondaryContent,
          ),
        ),
      ],
    );
  }
}
