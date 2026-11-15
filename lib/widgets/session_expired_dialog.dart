/// Note at start up that a previous Pod login has expired.
///
// Time-stamp: <2026-11-15>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

/// Tell the user when a WebID is stored but its session is no longer valid.
///
/// A stored WebID is not a session: `getWebId()` reports only that a WebID
/// sits in secure storage, while `isUserLoggedIn()` also requires an
/// unexpired access token. Once the token ages out the app is no longer
/// logged in, though it was the last time it was used, and sessions are
/// saved on this device instead. That is worth interrupting for, as RadioPod
/// does, since the remedy is a deliberate act. Someone who never logged in
/// has no WebID and is never asked.

Future<void> noteExpiredSession(BuildContext context) async {
  try {
    final webId = await getWebId();
    if (webId == null || webId.isEmpty || await isUserLoggedIn()) return;
  } on Object catch (e) {
    // An unanswerable question is not worth a dialog the user cannot act on.

    debugPrint('[InnerPod] could not check the Pod session: $e');
    return;
  }

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline),
          SizedBox(width: 8),
          Expanded(child: Text('Your Pod session has expired')),
        ],
      ),
      content: const Text(
        'You were previously logged in to your Pod, but are not logged in '
        'now. Sessions you complete will be saved on this device until you '
        'log in again, and can be copied to your Pod from History.\n\n'
        'Log in again from the profile menu to reconnect to your Pod.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
