/// HistoryFormat — pure date-parsing and display-mapping helpers for the
/// InnerPod history, extracted from history.dart to keep that widget within
/// the project line-count limit.
///
// Time-stamp: <2026-06-14>
///
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';

/// Parse a stored session date string into a [DateTime].
///
/// Handles ISO-8601, the legacy compact `yyyyMMddTHHmmss` form, and the
/// literal "null"/empty placeholder used by old sessions with no end time.
DateTime parseSessionDate(String s) {
  final trimmed = s.trim();
  if (trimmed == 'null' || trimmed.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  try {
    return DateTime.parse(trimmed);
  } catch (_) {}
  // Legacy format: yMMddTHHmmss → 20260525T143022
  final compact = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})$');
  final m = compact.firstMatch(trimmed);
  if (m != null) {
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
      int.parse(m.group(6)!),
    );
  }
  debugPrint('[History] Unparseable date: $s');
  return DateTime.fromMillisecondsSinceEpoch(0);
}

/// Convert a parsed raw session map into the display map used by the session
/// tiles. [local] marks sessions that live only in the local device store
/// (not yet synced to the Pod) so the UI can show a lock.
Map<String, String> sessionToDisplay(
  Map<String, String> item, {
  bool local = false,
}) {
  final start = parseSessionDate(item['start']!);
  final endRaw = item['end'] ?? 'null';
  final end = parseSessionDate(endRaw);
  final endStr = (endRaw.trim() == 'null' || endRaw.trim().isEmpty)
      ? '--:--:--'
      : DateFormat('HH:mm:ss').format(end);
  return {
    'rawStart': item['start']!,
    'rawEnd': endRaw,
    'date': DateFormat('yyyy-MM-dd').format(start),
    'start': DateFormat('HH:mm:ss').format(start),
    'end': endStr,
    'type': item['type'] ?? 'bell',
    'duration':
        '${(int.parse(item['silenceDuration'] ?? '1200') / 60).round()}m',
    'title': item['title'] ?? '',
    'description': item['description'] ?? '',
    'local': local ? 'true' : 'false',
  };
}

/// Convert a duration label such as "20m" into seconds, defaulting to 1200.
int durationToSeconds(String? duration) {
  if (duration == null) return 1200;
  final m = RegExp(r'(\d+)').firstMatch(duration);
  if (m == null) return 1200;
  return int.parse(m.group(1)!) * 60;
}
