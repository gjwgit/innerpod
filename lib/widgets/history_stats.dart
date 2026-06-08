/// HistoryStats — visual summary of meditation session history.
///
/// Shows headline metrics (total sessions, days practised, completion rate
/// against an expected two sessions per day) and an 8-week calendar heatmap
/// where each day is shaded by how many of the two expected sessions were
/// completed.
///
// Time-stamp: <2026-06-08>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

/// Number of sessions expected per day (morning + evening).
const int kExpectedSessionsPerDay = 2;

/// Cut-off hour separating a "morning" session from an "evening" one.
const int kMorningCutoffHour = 12;

/// A compact statistics + heatmap panel summarising session [starts]
/// (the parsed start DateTime of every recorded session).
class HistoryStats extends StatelessWidget {
  final List<DateTime> starts;
  const HistoryStats({super.key, required this.starts});

  @override
  Widget build(BuildContext context) {
    if (starts.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    // ── Aggregate per-day counts ────────────────────────────────────────────
    // Map of yyyy-MM-dd → number of sessions that day.
    final perDay = <String, int>{};
    var morning = 0;
    var evening = 0;
    DateTime? earliest;
    for (final s in starts) {
      final key = DateFormat('yyyy-MM-dd').format(s);
      perDay[key] = (perDay[key] ?? 0) + 1;
      if (s.hour < kMorningCutoffHour) {
        morning++;
      } else {
        evening++;
      }
      if (earliest == null || s.isBefore(earliest)) earliest = s;
    }

    final totalSessions = starts.length;
    final daysPractised = perDay.length;

    // Completion rate is measured against the span from the first recorded
    // session through today, at the expected rate per day.
    final now = DateTime.now();
    final firstDay = DateTime(earliest!.year, earliest.month, earliest.day);
    final today = DateTime(now.year, now.month, now.day);
    final spanDays = today.difference(firstDay).inDays + 1;
    final expectedTotal = spanDays * kExpectedSessionsPerDay;
    final completion =
        expectedTotal == 0 ? 0.0 : (totalSessions / expectedTotal).clamp(0, 1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Headline metric row ──────────────────────────────────────────
          Row(
            children: [
              _Metric(label: 'Sessions', value: '$totalSessions', cs: cs),
              _Metric(label: 'Days', value: '$daysPractised', cs: cs),
              _Metric(
                label: 'of expected',
                value: '${(completion * 100).round()}%',
                cs: cs,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Completion bar (sessions vs 2/day expectation) ──────────────
          _CompletionBar(done: totalSessions, expected: expectedTotal, cs: cs),
          const SizedBox(height: 6),
          Text(
            '$totalSessions of $expectedTotal expected '
            '($kExpectedSessionsPerDay/day over $spanDays days)',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Morning: $morning   ·   Evening: $evening',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // ── Heatmap ──────────────────────────────────────────────────────
          Text(
            'Last 8 weeks',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _Heatmap(perDay: perDay, cs: cs),
          const SizedBox(height: 8),
          _HeatmapLegend(cs: cs),
        ],
      ),
    );
  }
}

// ── Single headline metric ─────────────────────────────────────────────────

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _Metric({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
}

// ── Completion progress bar ──────────────────────────────────────────────────

class _CompletionBar extends StatelessWidget {
  final int done;
  final int expected;
  final ColorScheme cs;
  const _CompletionBar({
    required this.done,
    required this.expected,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final frac = expected == 0 ? 0.0 : (done / expected).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: frac,
        minHeight: 10,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
      ),
    );
  }
}

// ── Calendar heatmap (8 weeks, week columns) ─────────────────────────────────

class _Heatmap extends StatelessWidget {
  final Map<String, int> perDay;
  final ColorScheme cs;
  const _Heatmap({required this.perDay, required this.cs});

  Color _cellColor(int count) {
    // 0 → faint, 1 → half, 2+ → full primary.
    if (count <= 0) return cs.surfaceContainerHighest;
    if (count == 1) return cs.primary.withValues(alpha: 0.45);
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    const weeks = 8;
    const days = 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Anchor the grid so the LAST column is the week containing today,
    // even when that week is incomplete. Find the Monday of today's week,
    // then step back (weeks - 1) weeks for the first column's Monday.
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final start = mondayOfThisWeek.subtract(
      const Duration(days: days * (weeks - 1)),
    );

    // Build columns = weeks, rows = weekdays Mon..Sun.
    final columns = <Widget>[];
    for (var w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (var d = 0; d < days; d++) {
        final day = start.add(Duration(days: w * days + d));
        final key = DateFormat('yyyy-MM-dd').format(day);
        final count = perDay[key] ?? 0;
        final isFuture = day.isAfter(today);
        cells.add(
          Tooltip(
            message: isFuture
                ? ''
                : '${DateFormat('EEE d MMM').format(day)}: '
                    '$count session${count == 1 ? '' : 's'}',
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isFuture ? Colors.transparent : _cellColor(count),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }
      columns.add(Column(children: cells));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns,
      ),
    );
  }
}

// ── Heatmap legend ───────────────────────────────────────────────────────────

class _HeatmapLegend extends StatelessWidget {
  final ColorScheme cs;
  const _HeatmapLegend({required this.cs});

  Widget _swatch(Color c) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            'Less',
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 4),
          _swatch(cs.surfaceContainerHighest),
          _swatch(cs.primary.withValues(alpha: 0.45)),
          _swatch(cs.primary),
          const SizedBox(width: 4),
          Text(
            'More (0, 1, 2/day)',
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
        ],
      );
}
