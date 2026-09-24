/// Tests for the session timer's two layouts.
///
// Time-stamp: <2026-09-13>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:innerpod/widgets/app_button.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';
// Timer collides with dart:async's, so the app's widget is prefixed.
import 'package:innerpod/widgets/timer.dart' as app;

/// Pump the timer into a window of [size] and return the rectangle of the
/// countdown circle and of the window it sits in.

Future<(Rect timer, Rect window)> _layout(
  WidgetTester tester,
  Size size,
) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: app.Timer())),
  );
  await tester.pump();

  return (
    tester.getRect(find.byType(AppCircularCountDownTimer)),
    tester.getRect(find.byType(Scaffold)),
  );
}

void main() {
  testWidgets('wide layout centres the timer top to bottom', (tester) async {
    // Landscape: the timer sits beside the taller buttons panel, and must
    // be centred in the window rather than pinned to the top of it.

    final (timer, window) = await _layout(tester, const Size(1200, 800));

    expect(
      (timer.center.dy - window.center.dy).abs(),
      lessThan(1.0),
      reason: 'timer centre ${timer.center.dy} vs window ${window.center.dy}',
    );

    // It belongs on the left of the window, not centred horizontally.

    expect(timer.center.dx, lessThan(window.center.dx));
  });

  testWidgets('tall layout stacks the timer above the buttons', (tester) async {
    final (timer, window) = await _layout(tester, const Size(600, 1000));

    expect(timer.center.dy, lessThan(window.center.dy));
  });

  testWidgets('a narrow window keeps the buttons on screen', (tester) async {
    // In landscape the buttons panel gets only half the window, which at a
    // modest window size is narrower than the buttons' natural width. They
    // have to narrow to fit rather than run off the edge.

    final (_, window) = await _layout(tester, const Size(800, 560));

    for (final button in find.byType(AppButton).evaluate()) {
      final rect = tester.getRect(find.byWidget(button.widget));
      expect(
        rect.right,
        lessThanOrEqualTo(window.right),
        reason: '${(button.widget as AppButton).title} runs off the window',
      );
    }
  });
}
