/// Tests for session logic.
//
// Time-stamp: <2026-02-10 16:45:00 Amogh Hosamane>
//
/// Copyright (C) 2024, Togaware Pty Ltd
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
/// Authors: Amogh Hosamane

import 'package:flutter_test/flutter_test.dart';

import 'package:innerpod/utils/session_logic.dart';

void main() {
  group('Session Logic TTL Tests', () {
    test('parseSessions returns empty list on null content', () {
      expect(
        parseSessions(null),
        isEmpty,
      );
    });

    test('parseSessions returns empty list on empty content', () {
      expect(
        parseSessions(''),
        isEmpty,
      );
    });

    test('parseSessions parses a session correctly', () {
      final ttl = '''
:session_123456789 a :Session;
    :start "2024-01-01T10:00:00.000Z"^^xsd:dateTime;
    :end "2024-01-01T10:20:00.000Z"^^xsd:dateTime.
''';
      final sessions = parseSessions(ttl);
      expect(
        sessions.length,
        1,
      );
      expect(
        sessions.first['start'],
        '2024-01-01T10:00:00.000Z',
      );
      expect(
        sessions.first['end'],
        '2024-01-01T10:20:00.000Z',
      );
    });

    test('addSession adds session to empty content with prefixes', () {
      final newSession = {
        'start': '2024-01-01T10:00:00.000Z',
        'end': '2024-01-01T10:20:00.000Z',
      };
      final result = addSession(null, newSession);

      expect(result.contains('@prefix : <#>.'), isTrue);
      expect(result.contains('@prefix xsd:'), isTrue);
      expect(
        result.contains(':start "2024-01-01T10:00:00.000Z"^^xsd:dateTime'),
        isTrue,
      );
    });

    test('addSession appends session to existing content', () {
      final existing = '''
@prefix : <#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.

:session_123456789 a :Session;
    :start "2023-01-01T00:00:00.000Z"^^xsd:dateTime;
    :end "2023-01-01T00:20:00.000Z"^^xsd:dateTime.
''';
      final newSession = {
        'start': '2024-01-01T12:00:00.000Z',
        'end': '2024-01-01T12:20:00.000Z',
      };
      final result = addSession(existing, newSession);

      final parsed = parseSessions(result);
      expect(
        parsed.length,
        2,
      );
      expect(
        parsed.first['start'],
        '2024-01-01T12:00:00.000Z',
      ); // Newest first
    });
  });
}
