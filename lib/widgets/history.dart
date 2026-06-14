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

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/constants/colours.dart' as colours;
import 'package:innerpod/constants/colours.dart';
import 'package:innerpod/utils/local_session_store.dart';
import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/edit_session_dialog.dart';
import 'package:innerpod/widgets/history_backup.dart';
import 'package:innerpod/widgets/history_format.dart';
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

  /// Parse a date string tolerantly, handling both ISO 8601
  /// (e.g. "2026-05-25T14:30:22.000") and the legacy compact format
  /// (e.g. "20260525T143022") that older app versions wrote to the Pod.
  /// Promote a locally-stored session to the Pod: write it to sessions.ttl,
  /// then remove it from the local store. Triggered by tapping the lock icon.
  Future<void> _syncToPod(Map<String, String> session) async {
    if (!_isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first to save to your Pod.'),
          ),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Reconstruct the raw session map for addSession.
      final raw = <String, dynamic>{
        'start': session['rawStart'],
        'end': session['rawEnd'],
        'type': session['type'],
        // Duration is shown as e.g. "20m"; convert back to seconds.
        'silenceDuration': durationToSeconds(session['duration']),
        'title': session['title'],
        'description': session['description'],
      };

      String content = '';
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        content = '';
      }
      final newContent = addSession(content, raw);
      await writePod('sessions.ttl', newContent, overwrite: true);

      // Remove from local store now that it's on the Pod.
      await LocalSessionStore.removeSessionLocal(session['rawStart']!);

      await _loadSessions();
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) await _syncToPod(session);
        }
        return;
      }
      debugPrint('Failed to sync local session to Pod: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save to Pod. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Convert a display duration like "20m" back to seconds for storage.
  Future<void> _loadSessions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Always load the local (un-synced) store.
      final localRaw = await LocalSessionStore.readSessions();

      // Load the Pod store only when logged in.
      String? content;
      if (_isLoggedIn) {
        try {
          content = await readPod('sessions.ttl');
        } on ResourceNotExistException {
          debugPrint('sessions.ttl does not exist yet (normal for new users)');
          content = null;
        } catch (e) {
          if (e.toString().contains('You must first set the security key!')) {
            debugPrint(
              'Security key missing - cannot access sessions.ttl. Prompting.',
            );
            if (mounted) {
              await getKeyFromUserIfRequired(context, widget);
              if (mounted) {
                await _loadSessions();
                return;
              }
            }
          }
          debugPrint('Error accessing sessions.ttl: $e');
          content = null;
        }
      }

      final podRaw = parseSessions(content);

      // Merge: Pod sessions (not local) + local sessions (tagged local).
      final sessions = <Map<String, String>>[
        ...podRaw.map((item) => sessionToDisplay(item)),
        ...localRaw.map((item) => sessionToDisplay(item, local: true)),
      ];

      // Sort newest first by raw start timestamp.
      sessions.sort((a, b) => b['rawStart']!.compareTo(a['rawStart']!));

      if (mounted) {
        setState(() {
          _sessions = sessions;
        });
      }
    } catch (e) {
      debugPrint('Unexpected error loading sessions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSession(String rawStart, {bool local = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this session? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      // Local sessions are deleted from the device store, not the Pod.
      if (local) {
        try {
          await LocalSessionStore.removeSessionLocal(rawStart);
          await _loadSessions();
        } catch (e) {
          debugPrint('Error deleting local session: $e');
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
        return;
      }
      try {
        final content = await readPod('sessions.ttl');
        final newContent = deleteSession(content, rawStart);
        await writePod(
          'sessions.ttl',
          newContent,
          overwrite: true,
        );
        await _loadSessions();
      } catch (e) {
        if (e.toString().contains('You must first set the security key!')) {
          debugPrint(
            'Security key missing - cannot decrypt sessions.ttl for deletion',
          );
          if (mounted) {
            await getKeyFromUserIfRequired(context, widget);
            if (mounted) {
              await _deleteSession(rawStart);
            }
          }
          return;
        }
        debugPrint('Error deleting session: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete session: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAllSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Sessions'),
        content: const Text(
          'Are you sure you want to delete ALL sessions? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
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
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performDeleteAll();
    }
  }

  Future<void> _performDeleteAll() async {
    setState(() => _isLoading = true);
    try {
      final newContent = serializeSessions([]);
      await writePod(
        'sessions.ttl',
        newContent,
        overwrite: true,
      );
      await _loadSessions();
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        debugPrint('Security key missing - '
            'cannot write sessions.ttl for bulk deletion');
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) {
            await _performDeleteAll();
          }
        }
        return;
      }
      debugPrint('Error deleting all sessions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete all sessions: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editSession(Map<String, String> session) async {
    // Parse current start/end into editable DateTime values. End may be
    // missing ("null") on old sessions — default it to the start time.
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

    setState(() => _isLoading = true);
    try {
      final content = await readPod('sessions.ttl');
      final newContent = updateSession(content, session['rawStart']!, {
        'title': result.title,
        'description': result.description,
        'start': result.start.toIso8601String(),
        'end': result.end.toIso8601String(),
      });
      await writePod('sessions.ttl', newContent, overwrite: true);
      await _loadSessions();
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        debugPrint(
          'Security key missing - cannot decrypt sessions.ttl for update',
        );
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) await _editSession(session);
        }
        return;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Export all sessions to a .ttl backup file, prompting for the location.
  Future<void> _exportBackup() async {
    if (!_isLoggedIn) {
      _toast('Please log in first to back up your history.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      String content;
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        content = serializeSessions([]);
      }
      if (await saveTtlBackup(content)) _toast('History exported.');
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) await _exportBackup();
        }
        return;
      }
      debugPrint('[History] export failed: $e');
      _toast('Could not export history. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

    setState(() => _isLoading = true);
    try {
      String content;
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        content = serializeSessions([]);
      }

      final merged = mergeBackup(content, importedContent);
      await writePod('sessions.ttl', merged.content, overwrite: true);
      await _loadSessions();
      _toast(
        merged.added == 0
            ? 'No new sessions to import.'
            : 'Imported ${merged.added} '
                'session${merged.added == 1 ? '' : 's'}.',
      );
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) await _importBackup();
        }
        return;
      }
      debugPrint('[History] import failed: $e');
      _toast('Could not import history. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Show a brief message via a SnackBar.
  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action row replacing the AppBar actions.
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MarkdownTooltip(
              message: '**Export Backup**\n\n'
                  'Save all your session history to a .ttl backup file. '
                  'You will be prompted for where to save it.',
              child: IconButton(
                icon: const Icon(Icons.file_upload_outlined),
                tooltip: 'Export Backup',
                onPressed: _exportBackup,
              ),
            ),
            MarkdownTooltip(
              message: '**Import Backup**\n\n'
                  'Restore sessions from a previously exported .ttl backup '
                  'file. Existing sessions are kept; only new ones are added.',
              child: IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Import Backup',
                onPressed: _importBackup,
              ),
            ),
            if (_sessions.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: colours.error,
                ),
                tooltip: 'Delete all sessions',
                onPressed: _deleteAllSessions,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _loadSessions,
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLoggedIn ? Icons.history : Icons.lock_outline,
                            size: 64,
                            color: historyNoneColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isLoggedIn
                                ? 'No sessions recorded yet.'
                                : 'No sessions available.\nPlease login to view the session history.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: historyNoneColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
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
