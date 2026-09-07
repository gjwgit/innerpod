/// A table of past sessions logged to the user's Solid Pod.
///
// Time-stamp: <Monday 2026-06-08 11:14:23 +1000 Graham Williams>
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
/// Authors: Amogh Hosamane

// Add the library directive as we have doc entries above. We publish the above
// meta doc lines in the docs.

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/constants/colours.dart' as colours;
import 'package:innerpod/utils/local_session_store.dart';
import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/edit_session_dialog.dart';
import 'package:innerpod/widgets/history_actions.dart';
import 'package:innerpod/widgets/history_backup.dart';
import 'package:innerpod/widgets/history_format.dart';
import 'package:innerpod/widgets/history_pod.dart';
import 'package:innerpod/widgets/history_stats.dart';
import 'package:innerpod/widgets/history_tile.dart';

class History extends StatefulWidget {
  /// Incrementing this notifier from outside causes the history to
  /// reload, e.g. immediately after a new session is saved.
  const History({super.key, this.sessionVersion});

  final ValueNotifier<int>? sessionVersion;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, String>> _sessions = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initHistory();
    // Reload whenever the parent signals a new session was saved.
    widget.sessionVersion?.addListener(_loadSessions);
  }

  @override
  void dispose() {
    widget.sessionVersion?.removeListener(_loadSessions);
    super.dispose();
  }

  Future<void> _initHistory() async {
    final webId = await getWebId();
    if (mounted) {
      setState(() => _isLoggedIn = webId != null && webId.isNotEmpty);
    }
    await _loadSessions();
  }

  /// Run [action] with the loading indicator showing, then reload the list
  /// unless [reload] is false.
  ///
  /// Every Pod operation shares the same recovery: if the Pod reports the
  /// security key is not yet set, prompt for it and retry once. Other
  /// failures are logged and, when [onError] is given, reported to the user.

  Future<void> _guard(
    Future<void> Function() action, {
    String? onError,
    bool reload = true,
  }) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (reload && mounted) await _loadSessions();
    } catch (e) {
      if (isMissingKeyError(e)) {
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) await _guard(action, onError: onError, reload: reload);
        }
        return;
      }
      debugPrint('[History] ${onError ?? 'operation failed'}: $e');
      if (onError != null) _toast(onError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Ask the user to confirm a destructive action, returning true if they do.

  Future<bool> _confirm(String title, String message, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colours.error.withValues(alpha: 0.1),
              foregroundColor: colours.error,
              elevation: 0,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// Show a brief message via a SnackBar.

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadSessions() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // Always load the local (un-synced) store.
      final localRaw = await LocalSessionStore.readSessions();

      // Load the Pod store only when logged in.
      String? content;
      if (_isLoggedIn) {
        try {
          content = await readSessions();
        } catch (e) {
          if (isMissingKeyError(e) && mounted) {
            debugPrint('[History] security key missing - prompting.');
            await getKeyFromUserIfRequired(context, widget);
            if (mounted) {
              await _loadSessions();
              return;
            }
          }
          debugPrint('[History] error accessing $sessionsFile: $e');
          content = null;
        }
      }

      // Merge: Pod sessions (not local) + local sessions (tagged local).
      final sessions = <Map<String, String>>[
        ...parseSessions(content).map(sessionToDisplay),
        ...localRaw.map((item) => sessionToDisplay(item, local: true)),
      ];

      // Sort newest first by raw start timestamp.
      sessions.sort((a, b) => b['rawStart']!.compareTo(a['rawStart']!));

      if (mounted) setState(() => _sessions = sessions);
    } catch (e) {
      debugPrint('[History] unexpected error loading sessions: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Promote a locally-stored session to the Pod, then remove the local copy.
  /// Triggered by tapping the lock icon on a local session.

  Future<void> _syncToPod(Map<String, String> session) async {
    if (!_isLoggedIn) {
      _toast('Please log in first to save to your Pod.');
      return;
    }
    await _guard(
      () => podSyncSession(session),
      onError: 'Could not save to Pod. Try again.',
    );
  }

  Future<void> _deleteSession(String rawStart, {bool local = false}) async {
    final confirmed = await _confirm(
      'Delete Session',
      'Are you sure you want to delete this session? '
          'This action cannot be undone.',
      'Delete',
    );
    if (!confirmed) return;

    // Local sessions are deleted from the device store, not the Pod.
    await _guard(
      local
          ? () => LocalSessionStore.removeSessionLocal(rawStart)
          : () => podDeleteSession(rawStart),
      onError: local ? null : 'Failed to delete the session. Try again.',
    );
  }

  Future<void> _deleteAllSessions() async {
    final confirmed = await _confirm(
      'Delete All Sessions',
      'Are you sure you want to delete ALL sessions? '
          'This action cannot be undone.',
      'Delete All',
    );
    if (!confirmed) return;

    await _guard(
      podDeleteAllSessions,
      onError: 'Failed to delete all sessions. Try again.',
    );
  }

  Future<void> _editSession(Map<String, String> session) async {
    // Parse current start/end into editable DateTime values. End may be
    // missing ("null") on old sessions - default it to the start time.
    final startDt = parseSessionDate(session['rawStart']!);
    final rawEnd = session['rawEnd'] ?? 'null';
    final endDt = (rawEnd.trim() == 'null' || rawEnd.trim().isEmpty)
        ? startDt
        : parseSessionDate(rawEnd);

    final result = await showEditSessionDialog(
      context,
      session: session,
      start: startDt,
      end: endDt,
    );
    if (result == null) return; // cancelled

    await _guard(
      () => podUpdateSession(session['rawStart']!, {
        'title': result.title,
        'description': result.description,
        'start': result.start.toIso8601String(),
        'end': result.end.toIso8601String(),
      }),
    );
  }

  /// Export all sessions to a .ttl backup file, prompting for the location.

  Future<void> _exportBackup() async {
    if (!_isLoggedIn) {
      _toast('Please log in first to back up your history.');
      return;
    }
    await _guard(
      () async {
        if (await saveTtlBackup(await readSessions())) {
          _toast('History exported.');
        }
      },
      onError: 'Could not export history. Try again.',
      reload: false,
    );
  }

  /// Import sessions from a .ttl backup file, merging them into the Pod.
  /// Sessions whose start time already exists are skipped.

  Future<void> _importBackup() async {
    if (!_isLoggedIn) {
      _toast('Please log in first to restore your history.');
      return;
    }
    final importedContent = await pickTtlBackup();
    if (importedContent == null) return; // cancelled / unreadable

    await _guard(
      () async {
        final added = await podImportBackup(importedContent);
        _toast(
          added == 0
              ? 'No new sessions to import.'
              : 'Imported $added session${added == 1 ? '' : 's'}.',
        );
      },
      onError: 'Could not import history. Try again.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HistoryActions(
          onExport: _exportBackup,
          onImport: _importBackup,
          onRefresh: _loadSessions,
          onDeleteAll: _sessions.isEmpty ? null : _deleteAllSessions,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _sessions.isEmpty
                  ? HistoryEmpty(isLoggedIn: _isLoggedIn)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      // +1 for the stats header at index 0.
                      itemCount: _sessions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return HistoryStats(
                            starts: _sessions
                                .map((s) => parseSessionDate(s['rawStart']!))
                                .toList(),
                          );
                        }
                        final session = _sessions[index - 1];
                        final isLocal = session['local'] == 'true';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HistorySessionTile(
                            session: session,
                            onEdit: () => _editSession(session),
                            onDelete: () => _deleteSession(
                              session['rawStart']!,
                              local: isLocal,
                            ),
                            onSync: isLocal ? () => _syncToPod(session) : null,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
