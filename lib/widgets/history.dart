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
        debugPrint('sessions.ttl does not exist yet');
        content = null;
      } on SecurityKeyNotAvailableException {
        debugPrint('Security key missing. Prompting user.');
        if (mounted) {
          await getKeyFromUserIfRequired(
            context,
            widget,
          );
          if (mounted) {
            await _loadSessions();
            return;
          }
        }
        content = null;
      } catch (e) {
        debugPrint('Error reading Pod: $e');
        content = null;
      }

      _rawSessions = parseSessions(content);

      final sessions = _rawSessions.map((item) {
        final start = DateTime.parse(item['start']!);
        final end = DateTime.parse(item['end']!);

        return {
          'rawStart': item['start']!,
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
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final content = await readPod('sessions.ttl');
      final newContent = deleteSession(
        content,
        rawStart,
      );

      await writePod(
        'sessions.ttl',
        newContent,
      );

      await _loadSessions();
    }
  }

  Future<void> _editSession(Map<String, String> session) async {
    final nameController = TextEditingController(
      text: session['name'],
    );
    final commentController = TextEditingController(
      text: session['comment'],
    );

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final content = await readPod('sessions.ttl');

      final newContent = updateSession(
        content,
        session['rawStart']!,
        {
          'name': nameController.text,
          'comment': commentController.text,
        },
      );

      await writePod(
        'sessions.ttl',
        newContent,
      );

      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _sessions.isEmpty
              ? const Center(
                  child: Text('No sessions'),
                )
              : DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Start')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _sessions.map((session) {
                    return DataRow(
                      cells: [
                        DataCell(Text(session['date']!)),
                        DataCell(Text(session['name']!)),
                        DataCell(Text(session['start']!)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editSession(
                                  session,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteSession(
                                  session['rawStart']!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}
