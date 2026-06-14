/// HistoryBackup — pure file-picker and session-merge helpers for the
/// InnerPod history backup feature, extracted from history.dart to keep that
/// widget within the project line-count limit.
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';

import 'package:innerpod/utils/session_logic.dart';

/// A timestamped backup filename, e.g. innerpod_sessions_20260614_2130.ttl.
String backupFileName() {
  final now = DateTime.now();
  final ts =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
      '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  return 'innerpod_sessions_$ts.ttl';
}

/// Prompt for a location and write the TTL [content] there.
///
/// Returns true if saved, false if the user cancelled.
Future<bool> saveTtlBackup(String content) async {
  final bytes = utf8.encode(content);
  final savePath = await FilePicker.saveFile(
    dialogTitle: 'Export History Backup',
    fileName: backupFileName(),
    type: FileType.custom,
    allowedExtensions: ['ttl'],
    bytes: kIsWeb ? Uint8List.fromList(bytes) : null,
  );
  if (savePath == null) return false;
  if (!kIsWeb) {
    await File(savePath).writeAsBytes(bytes);
  }
  return true;
}

/// Prompt the user to pick a .ttl backup file and return its text content,
/// or null if cancelled / unreadable.
Future<String?> pickTtlBackup() async {
  final result = await FilePicker.pickFiles(
    dialogTitle: 'Import History Backup',
    type: FileType.custom,
    allowedExtensions: ['ttl'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  final bytes = result.files.first.bytes;
  if (bytes == null) return null;
  return utf8.decode(bytes);
}

/// Merge the sessions in [importedContent] into [existingContent], skipping
/// any whose start time already exists. Returns the new TTL content and the
/// number of sessions added.
({String content, int added}) mergeBackup(
  String existingContent,
  String importedContent,
) {
  final imported = parseSessions(importedContent);
  final existingStarts =
      parseSessions(existingContent).map((s) => s['start']).toSet();
  var content = existingContent;
  var added = 0;
  for (final s in imported) {
    if (existingStarts.contains(s['start'])) continue;
    content = addSession(content, s);
    existingStarts.add(s['start']);
    added++;
  }
  return (content: content, added: added);
}
