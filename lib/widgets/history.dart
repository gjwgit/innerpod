/// A table of past sessions logged to the user's Solid Pod.
///
// Time-stamp: <Tuesday 2026-02-17 08:23:09 +1100 Graham Williams>
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
      } catch (e) {
        debugPrint('Error reading from Pod: $e');
        content = null;
      }

      // parseSessions handles null content and returns empty list
      List<dynamic> jsonList = parseSessions(content);
      if (mounted) {
        setState(() {
          _sessions = jsonList.map((item) {
            final start = DateTime.parse(item['start']);
            final end = DateTime.parse(item['end']);
            return {
              'date': DateFormat('yyyy-MM-dd').format(start),
              'start': DateFormat('HH:mm:ss').format(start),
              'end': DateFormat('HH:mm:ss').format(end),
              'type': (item['type'] ?? 'basic') as String,
              'duration':
                  '${(int.parse(item['silenceDuration'] ?? '1200') / 60).round()}m',
            };
          }).toList();
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
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Min')),
                          DataColumn(label: Text('Start')),
                          DataColumn(label: Text('End')),
                        ],
                        rows: _sessions.map((session) {
                          return DataRow(
                            cells: [
                              DataCell(Text(session['date']!)),
                              DataCell(Text(session['type']!)),
                              DataCell(Text(session['duration']!)),
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
