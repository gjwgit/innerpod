/// HistoryActions — the action row and empty-state placeholder for the
/// InnerPod history, extracted from history.dart to keep that widget within
/// the project line-count limit.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:innerpod/constants/colours.dart' as colours;
import 'package:innerpod/constants/colours.dart';

/// The row of history actions shown in place of the AppBar actions.

class HistoryActions extends StatelessWidget {
  const HistoryActions({
    required this.onExport,
    required this.onImport,
    required this.onRefresh,
    this.onDeleteAll,
    super.key,
  });

  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onRefresh;

  /// When null the delete-all button is hidden, as there is nothing to delete.

  final VoidCallback? onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MarkdownTooltip(
          message: '**Export Backup**\n\n'
              'Save all your session history to a .ttl backup file. '
              'You will be prompted for where to save it.',
          child: IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Export Backup',
            onPressed: onExport,
          ),
        ),
        MarkdownTooltip(
          message: '**Import Backup**\n\n'
              'Restore sessions from a previously exported .ttl backup '
              'file. Existing sessions are kept; only new ones are added.',
          child: IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import Backup',
            onPressed: onImport,
          ),
        ),
        if (onDeleteAll != null)
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: colours.error,
            ),
            tooltip: 'Delete all sessions',
            onPressed: onDeleteAll,
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: onRefresh,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// The placeholder shown when there are no sessions to list, prompting a
/// logged-out user to log in.

class HistoryEmpty extends StatelessWidget {
  const HistoryEmpty({required this.isLoggedIn, super.key});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLoggedIn ? Icons.history : Icons.lock_outline,
            size: 64,
            color: historyNoneColor,
          ),
          const SizedBox(height: 16),
          Text(
            isLoggedIn
                ? 'No sessions recorded yet.'
                : 'No sessions available.\n'
                    'Please login to view the session history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: historyNoneColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
