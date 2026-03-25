## Pull Request Details

### Title
fix: preserve timer state across orientation changes (#74)

### Description
This PR resolves the issue where the meditation session timer would reset or stop when the device orientation changed (e.g., rotating a phone or resizing a window).

#### Key Fixes:
- **State Preservation**: Added a `GlobalKey` to the `AppCircularCountDownTimer` in `lib/widgets/timer.dart`. This ensures that the widget's internal state (which tracks the active timer's progress) is preserved when Flutter moves the widget between different positions in the tree during an orientation change (Portrait Column vs Landscape Row).
- **Sub-Widget Stability**: Added a stable `ValueKey` to the internal `CircularCountDownTimer` in `lib/widgets/app_circular_countdown_timer.dart` to provide additional stability during rebuilds.
- **Consistent UI**: The `TimerState` now correctly persists its local configurations (duration, guided mode, etc.) throughout the app's lifecycle during layout shifts.

### Related Issues
Fixes #74

### Type of Change
- [x] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] This change requires a documentation update

### How To Test?
1. Start an InnerPod session.
2. Rotate your device (or resize the window if on desktop/web) to switch between portrait and landscape modes.
3. Observe that the timer continues its countdown from the current point without resetting to the initial duration or stopping.

### Checklist
- [x] Changes adhere to the [style and coding guidelines](https://survivor.togaware.com/gnulinux/flutter-style.html)
- [x] I have performed a self-review of my code
- [x] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [x] No lint check errors are related to these changes (`flutter analyze`)
- [x] All tests passed (`flutter test`)
- [x] Verified logic of state preservation across orientation.
