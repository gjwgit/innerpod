/// EditSessionDialog — the edit-session dialog for the InnerPod history,
/// extracted from history.dart to keep that widget within the project
/// line-count limit.
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

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

/// The edited values returned by [showEditSessionDialog].
typedef EditSessionResult = ({
  String title,
  String description,
  DateTime start,
  DateTime end,
});

/// Show the edit-session dialog, pre-filled from [session] with the parsed
/// [start] and [end] times. Returns the edited values, or null if cancelled.
Future<EditSessionResult?> showEditSessionDialog(
  BuildContext context, {
  required Map<String, String> session,
  required DateTime start,
  required DateTime end,
}) async {
  final titleController = TextEditingController(text: session['title']);
  final descriptionController =
      TextEditingController(text: session['description']);
  var startDt = start;
  var endDt = end;

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
            current.second,
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

  if (updated != true) return null;
  return (
    title: titleController.text,
    description: descriptionController.text,
    start: startDt,
    end: endDt,
  );
}
