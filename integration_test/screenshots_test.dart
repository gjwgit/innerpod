/// Drives the app through the screens the store listings show.
///
// Time-stamp: <Saturday 2026-10-10 10:00:00 +1100 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
/// Authors: Graham Williams

library;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solidui/solidui.dart' show solidThemeNotifier;

import 'package:innerpod/main.dart' as app;
import 'package:innerpod/utils/local_session_store.dart';
import 'package:innerpod/widgets/premium_text_field.dart';

/// 20261010 gjw Screenshots for the stores, captured on an emulator or
/// simulator. Ported from radiopod's integration_test/screenshots_test.dart.
///
/// This test asserts almost nothing. It exists to put the app in a known
/// state, walk it through the screens, and capture each one with the
/// binding's takeScreenshot, so each PNG is the device's own pixel size.
/// `test_driver/integration_test.dart` writes the bytes to disk on the host.
///
/// Run it by hand against a booted emulator or simulator with
///
///   flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart \
///     -d `<device>`
///
/// Not on the Linux desktop: takeScreenshot is not implemented there, so the
/// desktop shots in assets/screenshots are still taken by hand.
///
/// WARNING. This REPLACES THE DEVICE'S LOCAL SESSION HISTORY with a
/// generated one (`LocalSessionStore`, SharedPreferences). On a fresh
/// emulator that is free. Do not point it at a device whose history you care
/// about.

/// A history worth showing: two 20 minute sessions a day, morning and
/// evening, over 19 weeks, with a sprinkling of missed ones so the heat map
/// is not a solid block. Deterministic, so every run draws the same map.

Future<void> _seedHistory() async {
  await LocalSessionStore.clear();

  final today = DateTime.now();

  for (var day = 132; day >= 1; day--) {
    final date = DateTime(today.year, today.month, today.day - day);

    for (final (slot, hour, minute) in [(0, 5, 51), (1, 17, 34)]) {
      if ((day * 7 + slot * 3) % 11 == 0) continue;

      final start = date.add(Duration(hours: hour, minutes: minute));

      await LocalSessionStore.addSessionLocal({
        'start': start.toIso8601String(),
        'end': start.add(const Duration(minutes: 20)).toIso8601String(),
        'type': 'bell',
        'silenceDuration': 1200,
        'title': '',
      });
    }
  }
}

/// 20261010 gjw Settle, with a BOUNDED wait. See radiopod: pumpAndSettle's
/// first argument is the interval between pumps, and its timeout is the
/// third, defaulting to ten minutes.
///
/// Only for a screen at rest, which a session is too once [_holdAt] has
/// stopped the countdown.

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 30),
    );

/// 20261010 gjw Stop a running session's countdown with [remaining] left.
///
/// The first run sped the clock up with timeDilation instead, and it was not
/// reliable on a live device: the iPad advanced only on the first step and
/// Android overshot and then undershot. Setting the position is exact, and
/// with nothing left animating the screen settles like any other.
///
/// The countdown's AnimationController is private to the package, but its
/// painter is handed the controller itself (the app sets isReverse and
/// isReverseAnimation, so no Tween sits in between), and the painter's
/// animation is public. The ring and the time shown both read it.
///
/// The app still believes the session is running, so Pause stays Pause.
/// [remaining] must not be zero: reaching the end fires onComplete, which
/// rings the closing bells and saves the session.

Future<void> _holdAt(WidgetTester tester, Duration remaining) async {
  final painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((p) => p.painter)
      .whereType<CustomTimerPainter>()
      .first;
  final countdown = painter.animation! as AnimationController;

  countdown.stop();
  countdown.value = remaining.inSeconds / countdown.duration!.inSeconds;
  await _settle(tester);
}

Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // A beat for anything that settles outside the widget tree, such as a font
  // arriving.

  await tester.pump(const Duration(seconds: 2));
  await _settle(tester);
  await binding.takeScreenshot(name);
}

Future<void> _openMenu(WidgetTester tester, IconData icon) async {
  final target = find.byIcon(icon);

  expect(
    target,
    findsWidgets,
    reason: 'No $icon in the navigation. The menu is built from SolidMenuItems '
        'in home.dart — if the icons there changed, change them here too.',
  );

  await tester.tap(target.first);
  await _settle(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('walk the screens for the store listing', (tester) async {
    // Seed BEFORE the app starts: History loads once, when it is first
    // mounted, and the IndexedStack in home.dart mounts it at startup.

    await _seedHistory();

    app.main();
    await _settle(tester);

    // The emulator may be in either mode, and the app remembers the last
    // one chosen. Start from light.

    solidThemeNotifier.setThemeMode(ThemeMode.light);
    await _settle(tester);

    // 20261010 gjw Android cannot read back the Flutter surface until it has
    // been swapped for an image view. See radiopod's test for the detail. A
    // no-op elsewhere, guarded so the intent is plain.

    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
      await _settle(tester);
    }

    await _shot(binding, tester, 'home_light');

    await _openMenu(tester, Icons.menu_book_outlined);
    await _shot(binding, tester, 'text_guide');

    await _openMenu(tester, Icons.history_outlined);
    await _shot(binding, tester, 'history');

    await _openMenu(tester, Icons.timer_outlined);

    // Start rings the bell without waiting on it, and starts the countdown,
    // which _holdAt then stops at each moment wanted.

    await tester.tap(find.text('Start'));
    await tester.pump();

    await _holdAt(tester, const Duration(minutes: 19, seconds: 20));
    await _shot(binding, tester, 'session_light');

    solidThemeNotifier.setThemeMode(ThemeMode.dark);
    await _holdAt(tester, const Duration(minutes: 18, seconds: 45));
    await _shot(binding, tester, 'session_dark');

    solidThemeNotifier.setThemeMode(ThemeMode.light);
    await _holdAt(tester, const Duration(minutes: 4));
    await _shot(binding, tester, 'session_advanced');

    // Filled through the controllers rather than enterText, so no keyboard
    // rises over the screen being photographed.

    final fields = find.byType(PremiumTextField);
    tester.widget<PremiumTextField>(fields.at(0)).controller.text =
        'Add any title here';
    tester.widget<PremiumTextField>(fields.at(1)).controller.text =
        'And we can describe the session here.';

    await _holdAt(tester, const Duration(seconds: 1));
    await _shot(binding, tester, 'session_finished_title_description');
  });
}
