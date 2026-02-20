/// A table of past sessions logged to the user's Solid Pod.
//
// Time-stamp: <Saturday 2026-02-21 00:58:00 +1100 Graham Williams>
//
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

library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/edit_session_dialog.dart';
import 'package:innerpod/widgets/session_card.dart';

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final content = await readPod('sessions.ttl');
      _rawSessions = parseSessions(content);

      _sessions = _rawSessions.map((s) {
        final start = DateTime.parse(s['start']!);
        final end = DateTime.parse(s['end']!);
        final durationSeconds = int.parse(s['silenceDuration']!);
        final durationMinutes = (durationSeconds / 60).round();

        return {
          'rawStart': s['start']!,
          'date': DateFormat('EEE, MMM d, yyyy').format(start),
          'start': DateFormat('HH:mm').format(start),
          'end': DateFormat('HH:mm').format(end),
          'duration': '$durationMinutes min',
          'type': s['type']!,
          'title': s['title'] ?? '',
          'description': s['description'] ?? '',
        };
      }).toList();
    } on ResourceNotExistException {
      debugPrint('Sessions file does not exist yet.');
      _sessions = [];
    } on SecurityKeyNotAvailableException {
      debugPrint('Security key missing - cannot decrypt sessions.ttl');
      if (mounted) {
        await getKeyFromUserIfRequired(context, widget);
        if (mounted) {
          await _loadSessions();
        }
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(String rawStart) async {
    final confirm = await showDialog<bool>(
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

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final content = await readPod('sessions.ttl');
        final newContent = deleteSession(content, rawStart);
        await writePod('sessions.ttl', newContent, overwrite: true);
        await _loadSessions();
      } catch (e) {
        debugPrint('Error deleting session: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editSession(Map<String, String> session) async {
    final titleController = TextEditingController(text: session['title']);
    final descriptionController =
        TextEditingController(text: session['description']);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditSessionDialog(
        titleController: titleController,
        descriptionController: descriptionController,
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
        title: Text(
          'Session History',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        automaticallyImplyLeading: false, // Don't show back button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                    return SessionCard(
                      session: session,
                      onEdit: () => _editSession(session),
                      onDelete: () => _deleteSession(session['rawStart']!),
                    );
                  },
                ),
    );
  }
}
