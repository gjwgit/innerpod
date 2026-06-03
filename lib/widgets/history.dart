/// A table of past sessions logged to the user's Solid Pod.
///
// Time-stamp: <Thursday 2026-03-12 10:03:00 +1100 Graham Williams>
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

import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/constants/colours.dart' as colours;
import 'package:innerpod/constants/colours.dart';
import 'package:innerpod/utils/session_logic.dart';
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
  List<Map<String, String>> _rawSessions = [];
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
  DateTime _parseDate(String s) {
    final trimmed = s.trim();
    // Stored as literal "null" when end time was missing in old sessions.
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

  Future<void> _loadSessions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String? content;
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        debugPrint('sessions.ttl does not exist yet (normal for new users)');
        content = null;
      } catch (e) {
        if (e.toString().contains('You must first set the security key!')) {
          debugPrint(
            'Security key missing - cannot access sessions.ttl. Prompting user.',
          );
          if (mounted) {
            await getKeyFromUserIfRequired(context, widget);
            if (mounted) {
              await _loadSessions();
              return;
            }
          }
        }
        // Log other errors related to reading from Pod.

        debugPrint('Error accessing sessions.ttl: $e');
        content = null;
      }

      // parseSessions handles null content and returns empty list

      _rawSessions = parseSessions(content);
      final List<Map<String, String>> sessions = _rawSessions.map((item) {
        final start = _parseDate(item['start']!);
        final endRaw = item['end'] ?? 'null';
        final end = _parseDate(endRaw);
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
        };
      }).toList();

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

  Future<void> _deleteSession(String rawStart) async {
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
    final titleController = TextEditingController(text: session['title']);
    final descriptionController =
        TextEditingController(text: session['description']);

    // Parse current start/end into editable DateTime values. End may be
    // missing ("null") on old sessions — default it to the start time.
    DateTime startDt = _parseDate(session['rawStart']!);
    final rawEnd = session['rawEnd'] ?? 'null';
    DateTime endDt = (rawEnd.trim() == 'null' || rawEnd.trim().isEmpty)
        ? startDt
        : _parseDate(rawEnd);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickDateTime({required bool isStart}) async {
            final current = isStart ? startDt : endDt;
            final date = await showDatePicker(
              context: context,
              initialDate: current,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date == null || !context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(current),
            );
            if (time == null) return;
            final combined = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
              isStart ? current.second : current.second,
            );
            setDialogState(() {
              if (isStart) {
                startDt = combined;
              } else {
                endDt = combined;
              }
            });
          }

          final fmt = DateFormat('yyyy-MM-dd HH:mm');
          return AlertDialog(
            title: const Text('Edit Session'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter session title',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter session description',
                      prefixIcon: const Icon(Icons.notes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Start time — tap to edit.
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.play_arrow_outlined),
                    title: const Text('Start'),
                    subtitle: Text(fmt.format(startDt)),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => pickDateTime(isStart: true),
                  ),
                  // End time — tap to edit.
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.stop_outlined),
                    title: const Text('End'),
                    subtitle: Text(fmt.format(endDt)),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => pickDateTime(isStart: false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (endDt.isBefore(startDt)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('End time must be after start time.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );

    if (updated == true) {
      setState(() => _isLoading = true);
      try {
        final content = await readPod('sessions.ttl');
        final newContent = updateSession(content, session['rawStart']!, {
          'title': titleController.text,
          'description': descriptionController.text,
          'start': startDt.toIso8601String(),
          'end': endDt.toIso8601String(),
        });
        await writePod(
          'sessions.ttl',
          newContent,
          overwrite: true,
        );
        await _loadSessions();
      } catch (e) {
        if (e.toString().contains('You must first set the security key!')) {
          debugPrint(
            'Security key missing - cannot decrypt sessions.ttl for update',
          );
          if (mounted) {
            await getKeyFromUserIfRequired(context, widget);

            if (mounted) {
              await _editSession(session);
            }
          }
          return;
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action row replacing the AppBar actions.
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return HistorySessionTile(
                          session: session,
                          onEdit: () => _editSession(session),
                          onDelete: () => _deleteSession(session['rawStart']!),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
