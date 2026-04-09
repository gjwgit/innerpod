## Pull Request Details

### Title
fix: maintain active button colour when switching sessions (#73)

### Description
This PR resolves the issue where tapping INTRO or GUIDED while a START session was already running would not turn those buttons blue, even though the new session had begun. The button only turned blue after pressing PAUSE.

#### Key Fixes:
- **Race Condition Eliminated**: `_reset()` previously called `_controller.restart()` internally. When tapped during an active session, this restart could fire the `onComplete` callback on the previous timer instance, triggering `_complete()` → `setState(_reset())` → `_sessionType = 'none'` *after* the initial `setState` in `_intro()`/`_guided()` had already set the correct session type, silently wiping the colour indicator.
- **Controller Side-Effects Extracted**: `_reset()` now only resets internal state variables (`_isGuided`, `_isPaused`, `_sessionType`). Callers (`_intro`, `_guided`, `startButton.onPressed`) explicitly stop audio and restart+pause the controller *before* calling `setState`, ensuring the old timer is fully neutralised before any state update.
- **Pause Button Indicator**: The Pause/Resume button now also shows blue text when a session is actively paused (`_isPaused && _sessionType != 'none'`), giving clear visual feedback regardless of which session type is running.

### Related Issues
Fixes #73

### Type of Change
- [x] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] This change requires a documentation update

### How To Test?
1. Launch the app and tap **START** — the Start button text should turn blue immediately.
2. While Start is running, tap **INTRO** — the Intro button text should turn blue immediately (previously it did not).
3. While any session is running, tap **GUIDED** — the Guided button text should turn blue immediately.
4. Tap **PAUSE** — the Pause button text should turn blue while paused, and the session button should remain blue.
5. Tap **Resume** — both buttons should return to their normal states as the session continues.

### Checklist
- [x] Changes adhere to the [style and coding guidelines](https://survivor.togaware.com/gnulinux/flutter-style.html)
- [x] I have performed a self-review of my code
- [x] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [x] No lint check errors are related to these changes (`flutter analyze`)
- [x] All tests passed (`flutter test`)
- [x] Verified that pressing START, INTRO, and GUIDED each immediately highlights the correct button blue.
