/// HistoryPod — the Pod read/write operations behind the InnerPod session
/// history, extracted from history.dart to keep that widget within the
/// project line-count limit.
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

import 'package:solidpod/solidpod.dart';

import 'package:innerpod/utils/local_session_store.dart';
import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/history_backup.dart';
import 'package:innerpod/widgets/history_format.dart';

/// The resource within the user's Pod that holds the session history.

const sessionsFile = 'sessions.ttl';

/// True when [e] is the solidpod error raised before the security key is set.
///
/// The caller then prompts for the key and retries the operation.

bool isMissingKeyError(Object e) =>
    e.toString().contains('You must first set the security key!');

/// Read [sessionsFile], returning an empty session document when the resource
/// does not exist yet, which is normal for a new user.

Future<String> readSessions() async {
  try {
    return await readPod(sessionsFile);
  } on ResourceNotExistException {
    return serializeSessions([]);
  }
}

/// Overwrite [sessionsFile] with [content].

Future<void> writeSessions(String content) =>
    writePod(sessionsFile, content, overwrite: true);

/// Promote the locally-stored [session] to the Pod, then drop the local copy.

Future<void> podSyncSession(Map<String, String> session) async {
  // Reconstruct the raw session map for addSession. The duration is displayed
  // as e.g. "20m", so convert it back to seconds for storage.

  final raw = <String, dynamic>{
    'start': session['rawStart'],
    'end': session['rawEnd'],
    'type': session['type'],
    'silenceDuration': durationToSeconds(session['duration']),
    'title': session['title'],
    'description': session['description'],
  };

  final content = await readSessions();
  await writeSessions(addSession(content, raw));
  await LocalSessionStore.removeSessionLocal(session['rawStart']!);
}

/// Remove the session starting at [rawStart] from the Pod.

Future<void> podDeleteSession(String rawStart) async {
  final content = await readSessions();
  await writeSessions(deleteSession(content, rawStart));
}

/// Remove every session from the Pod.

Future<void> podDeleteAllSessions() => writeSessions(serializeSessions([]));

/// Apply [updates] to the Pod session starting at [rawStart].

Future<void> podUpdateSession(
  String rawStart,
  Map<String, dynamic> updates,
) async {
  final content = await readSessions();
  await writeSessions(updateSession(content, rawStart, updates));
}

/// Merge the sessions in [importedContent] into the Pod, skipping any whose
/// start time is already recorded. Returns the number of sessions added.

Future<int> podImportBackup(String importedContent) async {
  final merged = mergeBackup(await readSessions(), importedContent);
  await writeSessions(merged.content);
  return merged.added;
}
