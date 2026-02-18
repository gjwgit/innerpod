/// Session logic for InnerPod.
//
// Time-stamp: <2026-02-10 16:40:00 Amogh Hosamane>
//
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
/// Authors: Amogh Hosamane

library;

const String _prefixes = '''
@prefix : <#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.
''';

/// Parses a TTL string containing session data into a list of maps.
/// Returns a list of sessions, where each session is a map with 'start', 'end', 'type', 'silenceDuration', 'name', and 'comment' keys.
List<Map<String, String>> parseSessions(String? content) {
  if (content == null || content.isEmpty) {
    return [];
  }

  final List<Map<String, String>> sessions = [];

  // RegExp to match a session block.
  // It looks for a block starting with :session_ and ending with a literal dot
  // that is followed by whitespace or end of string.
  final RegExp sessionBlockRegExp =
      RegExp(r':session_\d+.*?\.(?:\s+|$)', dotAll: true);

  // RegExp to extract properties within a block
  final RegExp startRegExp = RegExp(r':start "(.*?)"\^\^xsd:dateTime');
  final RegExp endRegExp = RegExp(r':end "(.*?)"\^\^xsd:dateTime');
  final RegExp typeRegExp = RegExp(r':type "(.*?)"');
  final RegExp durationRegExp = RegExp(r':silenceDuration (\d+)');
  final RegExp nameRegExp = RegExp(r':name "(.*?)"');
  final RegExp commentRegExp = RegExp(r':comment "(.*?)"');

  final matches = sessionBlockRegExp.allMatches(content);

  for (final match in matches) {
    final block = match.group(0)!;
    final startMatch = startRegExp.firstMatch(block);
    final endMatch = endRegExp.firstMatch(block);
    final typeMatch = typeRegExp.firstMatch(block);
    final durationMatch = durationRegExp.firstMatch(block);
    final nameMatch = nameRegExp.firstMatch(block);
    final commentMatch = commentRegExp.firstMatch(block);

    if (startMatch != null && endMatch != null) {
      sessions.add({
        'start': startMatch.group(1)!,
        'end': endMatch.group(1)!,
        'type': typeMatch?.group(1) ?? 'basic',
        'silenceDuration': durationMatch?.group(1) ?? '1200',
        'name': nameMatch?.group(1) ?? '',
        'comment': commentMatch?.group(1) ?? '',
      });
    }
  }

  // Sort by start time descending (newest first)
  sessions.sort((a, b) => b['start']!.compareTo(a['start']!));

  return sessions;
}

/// Serializes a list of sessions into a TTL string.
String serializeSessions(List<Map<String, String>> sessions) {
  if (sessions.isEmpty) {
    return _prefixes;
  }

  final buffer = StringBuffer();
  buffer.write(_prefixes);

  for (final session in sessions) {
    final String start = session['start']!;
    final String end = session['end']!;
    final String type = session['type'] ?? 'basic';
    final String duration = session['silenceDuration'] ?? '1200';
    final String name = session['name'] ?? '';
    final String comment = session['comment'] ?? '';

    // Use timestamp as unique ID
    final String id = DateTime.parse(start).millisecondsSinceEpoch.toString();

    buffer.write('\n:session_$id a :Session;\n');
    buffer.write('    :start "$start"^^xsd:dateTime;\n');
    buffer.write('    :end "$end"^^xsd:dateTime;\n');
    buffer.write('    :type "$type";\n');
    buffer.write('    :silenceDuration $duration');
    if (name.isNotEmpty) buffer.write(';\n    :name "$name"');
    if (comment.isNotEmpty) buffer.write(';\n    :comment "$comment"');
    buffer.write('.\n');
  }

  return buffer.toString();
}

/// Adds a new session to the existing TTL content.
String addSession(String? currentContent, Map<String, dynamic> newSession) {
  List<Map<String, String>> sessions = parseSessions(currentContent);

  // Convert map values to String
  final Map<String, String> sessionToAdd = {
    'start': newSession['start'].toString(),
    'end': newSession['end'].toString(),
    'type': (newSession['type'] ?? 'basic').toString(),
    'silenceDuration': (newSession['silenceDuration'] ?? 1200).toString(),
    'name': (newSession['name'] ?? '').toString(),
    'comment': (newSession['comment'] ?? '').toString(),
  };

  sessions.add(sessionToAdd);
  return serializeSessions(sessions);
}

/// Deletes a session with the given start time from the TTL content.
String deleteSession(String currentContent, String startTime) {
  List<Map<String, String>> sessions = parseSessions(currentContent);
  sessions.removeWhere((s) => s['start'] == startTime);
  return serializeSessions(sessions);
}

/// Updates a session with the given start time in the TTL content.
String updateSession(
  String currentContent,
  String startTime,
  Map<String, dynamic> updatedData,
) {
  List<Map<String, String>> sessions = parseSessions(currentContent);
  final index = sessions.indexWhere(
    (s) => s['start'] == startTime,
  );

  if (index != -1) {
    final session = sessions[index];
    if (updatedData.containsKey('name')) {
      session['name'] = updatedData['name'].toString();
    }
    if (updatedData.containsKey('comment')) {
      session['comment'] = updatedData['comment'].toString();
    }
    if (updatedData.containsKey('type')) {
      session['type'] = updatedData['type'].toString();
    }
    // We don't usually update start/end times via UI but keeping it flexible
    if (updatedData.containsKey('end')) {
      session['end'] = updatedData['end'].toString();
    }
    sessions[index] = session;
  }

  return serializeSessions(sessions);
}
