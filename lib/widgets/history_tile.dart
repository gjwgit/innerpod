/// A tile widget displaying a single session in the history list.
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

import 'package:innerpod/constants/colours.dart';

/// Displays a single session entry in the history list.
/// Callbacks are used so this widget has no dependency on [_HistoryState].

class HistorySessionTile extends StatelessWidget {
  const HistorySessionTile({
    required this.session,
    required this.onEdit,
    required this.onDelete,
    this.onSync,
    super.key,
  });

  final Map<String, String> session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Called when the user taps the lock icon on a locally-stored session to
  /// save it to the Pod. Null for sessions already on the Pod.
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onEdit,
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
                      .withValues(alpha: 0.5),
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
                            color: historyIncidentalColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          session['duration']!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session['title']!,
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
                          color: historyIncidentalColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${session['start']} - ${session['end']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: historyIncidentalColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  if (onSync != null)
                    IconButton(
                      icon: Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Saved on this device only — '
                          'tap to save to your Pod',
                      onPressed: onSync,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: historyDeleteColor,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
