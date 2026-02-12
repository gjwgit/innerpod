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

import 'package:innerpod/utils/session_logic.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, String>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? content = await readPod('sessions.ttl');
      // If readPod returns nullable, use ?. or just pass to parseSessions which handles null
      List<dynamic> jsonList = parseSessions(content);
      if (jsonList.isNotEmpty) {
        setState(() {
          _sessions = jsonList.map((item) {
            final start = DateTime.parse(item['start']);
            final end = DateTime.parse(item['end']);
            return {
              'date': DateFormat('yyyy-MM-dd').format(start),
              'start': DateFormat('HH:mm:ss').format(start),
              'end': DateFormat('HH:mm:ss').format(end),
            };
          }).toList();
        });
      }
    } catch (e) {
      // If file doesn't exist yet, treat as empty (no sessions)
      debugPrint(
        'sessions.ttl does not exist yet (this is normal for new users)',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Start')),
                          DataColumn(label: Text('End')),
                        ],
                        rows: _sessions.map((session) {
                          return DataRow(
                            cells: [
                              DataCell(Text(session['date']!)),
                              DataCell(Text(session['start']!)),
                              DataCell(Text(session['end']!)),
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
