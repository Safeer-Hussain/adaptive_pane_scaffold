## 0.1.0

* Initial release of adaptive_pane_scaffold.
* Added `AdaptivePaneScaffold` with responsive navigation switching between bottom `NavigationBar` on compact portrait and left `NavigationRail` on landscape/tablet/desktop.
* Implemented 360dp-safe scrollable `NavigationRail` with `IntrinsicHeight` and `ClampingScrollPhysics` to prevent `RenderFlex` overflow errors on short viewports.
* Added compact landscape toolbar compression (`36dp`) for maximum vertical content readability.
* Implemented `AdaptiveDualPane` master-detail layout with configurable pane ratio, spacing, divider, and independent scrolling.
* Added `AdaptiveDestination` model supporting Material 3 icons, selected icons, tooltips, and badges.
* Added `AdaptiveBreakpointConfig` for customizable responsive breakpoints and dimensions.
* Added `AdaptiveLayoutScope` InheritedWidget exposing `AdaptiveLayoutMode` (`portraitCompact`, `landscapeCompact`, `tabletRail`, `desktopExtended`) and `isShortLandscape` state.
* Built with zero external dependencies, relying exclusively on Flutter SDK.
