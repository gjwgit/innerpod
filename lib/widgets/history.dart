/// A table of past sessions logged to the user's Solid Pod.
///
// Time-stamp: <Thursday 2026-02-19 20:39:57 +1100 Graham Williams>
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

import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/constants/colours.dart' as colours;

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
        debugPrint('Error accessing sessions.ttl: $e');
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
      } on SecurityKeyNotAvailableException {
        debugPrint(
          'Security key missing - cannot decrypt sessions.ttl for deletion',
        );
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) {
            await _deleteSession(rawStart);
          }
        }
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
    } on SecurityKeyNotAvailableException {
      debugPrint(
        'Security key missing - cannot write sessions.ttl for bulk deletion',
      );
      if (mounted) {
        await getKeyFromUserIfRequired(context, widget);
        if (mounted) {
          await _performDeleteAll();
        }
      }
    } catch (e) {
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

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    if (updated == true) {
      setState(() => _isLoading = true);
      try {
        final content = await readPod('sessions.ttl');
        final newContent = updateSession(content, session['rawStart']!, {
          'title': titleController.text,
          'description': descriptionController.text,
        });
        await writePod(
          'sessions.ttl',
          newContent,
          overwrite: true,
        );
        await _loadSessions();
      } on SecurityKeyNotAvailableException {
        debugPrint(
          'Security key missing - cannot decrypt sessions.ttl for update',
        );
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) {
            await _editSession(session);
          }
        }
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Session History'),
        automaticallyImplyLeading: false, // Don't show back button
        actions: [
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No sessions recorded yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _editSession(session),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  session['type'] == 'guided'
                                      ? Icons.auto_awesome_outlined
                                      : Icons.self_improvement,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          session['date']!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          session['duration']!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      session['title']!.isEmpty
                                          ? 'Session'
                                          : session['title']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (session['description']!.isNotEmpty)
                                      Text(
                                        session['description']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session['start']} - ${session['end']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => _editSession(session),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: colours.error,
                                    ),
                                    onPressed: () =>
                                        _deleteSession(session['rawStart']!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
