/// A table of past sessions logged to the user's Solid Pod.
//
// Time-stamp: <2026-02-09 16:45:00 Amogh Hosamane>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
library;

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/utils/session_logic.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, String>> _rawSessions = [];
  List<Map<String, String>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
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
        // If file doesn't exist yet, treat as empty (no sessions)
        debugPrint('sessions.ttl does not exist yet (normal for new users)');
        content = null;
      } on SecurityKeyNotAvailableException {
        debugPrint('Security key missing. Prompting user.');
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          // Retry loading sessions after popup closes
          if (mounted) {
            await _loadSessions();
            return;
          }
        }
        content = null;
      } catch (e) {
        // Log other errors related to reading from Pod
        debugPrint('Error reading from Pod: $e');
        content = null;
      }

      // parseSessions handles null content and returns empty list
      _rawSessions = parseSessions(content);
      final List<Map<String, String>> sessions = _rawSessions.map((item) {
        final start = DateTime.parse(item['start']!);
        final end = DateTime.parse(item['end']!);
        return {
          'rawStart': item['start']!, // Keep raw start as ID
          'date': DateFormat('yyyy-MM-dd').format(start),
          'start': DateFormat('HH:mm:ss').format(start),
          'end': DateFormat('HH:mm:ss').format(end),
          'type': item['type'] ?? 'basic',
          'duration':
              '${(int.parse(item['silenceDuration'] ?? '1200') / 60).round()}m',
          'name': item['name'] ?? '',
          'comment': item['comment'] ?? '',
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
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        await writePod('sessions.ttl', newContent);
        await _loadSessions();
      } catch (e) {
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

  Future<void> _editSession(Map<String, String> session) async {
    final nameController = TextEditingController(text: session['name']);
    final commentController = TextEditingController(text: session['comment']);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true) {
      setState(() => _isLoading = true);
      try {
        final content = await readPod('sessions.ttl');
        final newContent = updateSession(content, session['rawStart']!, {
          'name': nameController.text,
          'comment': commentController.text,
        });
        await writePod('sessions.ttl', newContent);
        await _loadSessions();
      } catch (e) {
        debugPrint('Error updating session: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update session: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        automaticallyImplyLeading: false, // Don't show back button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text('No sessions recorded yet.'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 12,
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Min')),
                          DataColumn(label: Text('Start')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: _sessions.map((session) {
                          return DataRow(
                            cells: [
                              DataCell(Text(session['date']!)),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    session['name']!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text(session['type']!)),
                              DataCell(Text(session['duration']!)),
                              DataCell(Text(session['start']!)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () => _editSession(session),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteSession(session['rawStart']!),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
