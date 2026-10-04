/// Tests for the history statistics and its heatmap.
///
// Time-stamp: <2026-10-04>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:innerpod/widgets/history_stats.dart';

/// Pump the statistics for one session today into a window [width] wide.

Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            HistoryStats(starts: [DateTime.now()]),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The number of weeks the heatmap heading names.

int _weeks(WidgetTester tester) {
  final heading = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((s) => s.startsWith('Last ') && s.endsWith(' weeks'));

  return int.parse(heading.split(' ')[1]);
}

void main() {
  testWidgets('a wider window shows more weeks', (tester) async {
    await _pump(tester, 400);
    final narrow = _weeks(tester);

    await _pump(tester, 1200);
    final wide = _weeks(tester);

    expect(wide, greaterThan(narrow));
  });

  testWidgets('the heatmap fits the window without overflowing',
      (tester) async {
    await _pump(tester, 400);

    expect(tester.takeException(), isNull);
  });
}
