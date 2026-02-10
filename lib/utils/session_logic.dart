const String _prefixes = '''
@prefix : <#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.
''';

/// Parses a TTL string containing session data into a list of maps.
/// Returns a list of sessions, where each session is a map with 'start' and 'end' keys.
List<Map<String, String>> parseSessions(String? content) {
  if (content == null || content.isEmpty) {
    return [];
  }

  final List<Map<String, String>> sessions = [];

  // RegExp to match a session block.
  // It looks for a block starting with :session_ and ending with a literal dot
  // that is followed by whitespace or end of string.
  // The dot in timestamps (e.g., .000Z) is NOT followed by whitespace, so this distinguishes the terminator.
  final RegExp sessionBlockRegExp =
      RegExp(r':session_\d+.*?\.(?:\s+|$)', dotAll: true);

  // RegExp to extract start and end times within a block
  final RegExp startRegExp = RegExp(r':start "(.*?)"\^\^xsd:dateTime');
  final RegExp endRegExp = RegExp(r':end "(.*?)"\^\^xsd:dateTime');

  final matches = sessionBlockRegExp.allMatches(content);

  for (final match in matches) {
    final block = match.group(0)!;
    final startMatch = startRegExp.firstMatch(block);
    final endMatch = endRegExp.firstMatch(block);

    if (startMatch != null && endMatch != null) {
      sessions.add({
        'start': startMatch.group(1)!,
        'end': endMatch.group(1)!,
      });
    }
  }

  // Sort by start time descending (newest first)
  sessions.sort((a, b) => b['start']!.compareTo(a['start']!));

  return sessions;
}

/// Adds a new session to the existing TTL content.
/// If currentContent is null or empty, initializes with prefixes.
/// Returns the updated TTL content string.
String addSession(String? currentContent, Map<String, dynamic> newSession) {
  String content = currentContent ?? '';

  // key fix: trim() handles invisible whitespace that might make "empty" check false
  if (content.trim().isEmpty) {
    content = _prefixes;
  } else if (!content.contains('@prefix')) {
    // If somehow content exists but no prefixes (legacy/corrupt), add them
    content = '$_prefixes\n$content';
  }

  final String start = newSession['start'];
  final String end = newSession['end'];
  // Use timestamp as unique ID
  final String id = DateTime.parse(start).millisecondsSinceEpoch.toString();

  // Add newline before new entry if needed
  final String separator = content.endsWith('\n') ? '' : '\n';

  final String newEntry = '''
$separator
:session_$id a :Session;
    :start "$start"^^xsd:dateTime;
    :end "$end"^^xsd:dateTime.
''';

  return content + newEntry;
}
