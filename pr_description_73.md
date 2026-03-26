## Pull Request Details

### Title
fix: maintain active button color when switching session types (#73)

### Description
This PR resolves the issue where the button indicating the active session type (START, INTRO, or GUIDED) would not immediately update its color (blue) when a new session was started or when switching between session types.

#### Key Fixes:
- **State Synchronization**: Wrapped state updates (`_sessionType`, `_isGuided`, `_startTime`) and `_reset()` calls in `setState()` within the `_intro()`, `_guided()`, and `_complete()` methods in `lib/widgets/timer.dart`.
- **Immediate Feedback**: This ensures that as soon as a user taps a button (e.g., INTRO), the previously active button (e.g., START) loses its blue indicator and the new button immediately gains it.
- **Consistent UI State**: Fixed an issue where the UI could get out of sync with the underlying session state, only updating after a separate event (like PAUSE) triggered a rebuild.

### Related Issues
Fixes #73

### Type of Change
- [x] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)

### How To Test?
1. Start the app.
2. Tap the **START** button; verify it turns blue.
3. Tap the **INTRO** button; verify **START** is no longer blue and **INTRO** immediately becomes blue.
4. Tap the **GUIDED** button; verify **INTRO** is no longer blue and **GUIDED** immediately becomes blue.
5. Tap **PAUSE**; verify the active button remains blue.
6. Let the session complete; verify the blue indicator is cleared.

### Checklist
- [x] Changes adhere to the style and coding guidelines
- [x] I have performed a self-review of my code
- [x] I have commented my code
- [x] No lint check errors are related to these changes (`flutter analyze`)
- [x] All tests passed (`flutter test`)
- [x] Verified button color maintenance in all session scenarios.
