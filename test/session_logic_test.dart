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
        'end': '2024-01-01T10:20:00.000Z'
      };
      final result = addSession(null, newSession);

      expect(result.contains('@prefix : <#>.'), isTrue);
      expect(result.contains('@prefix xsd:'), isTrue);
      expect(result.contains(':start "2024-01-01T10:00:00.000Z"^^xsd:dateTime'),
          isTrue);
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
        'end': '2024-01-01T12:20:00.000Z'
      };
      final result = addSession(existing, newSession);

      final parsed = parseSessions(result);
      expect(parsed.length, 2);
      expect(parsed.first['start'], '2024-01-01T12:00:00.000Z'); // Newest first
    });
  });
}
