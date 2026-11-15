/// Whether the app can currently reach the user's Pod.
///
// Time-stamp: <2026-11-15>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/foundation.dart';

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

/// True when there is a live Pod session to read from and write to.
///
/// 20261115 gjw A STORED WEBID IS NOT A SESSION. `getWebId()` reports only
/// that a WebID sits in secure storage, while `isUserLoggedIn()` also
/// requires an unexpired access token. Treating the WebID alone as logged in
/// sent saves to a Pod that could only refuse them, and showed History as
/// logged in when it was not. Checked in that order so someone who never
/// logged in never reaches `isUserLoggedIn()` and its keychain probe.
///
/// Either call can throw, e.g. when the keyring is locked. That is treated
/// as logged out so the caller falls back to this device and nothing is lost.

Future<bool> hasPodSession() async {
  try {
    final webId = await getWebId();
    return webId != null && webId.isNotEmpty && await isUserLoggedIn();
  } on Object catch (e) {
    debugPrint('[InnerPod] could not check the Pod session: $e');
    return false;
  }
}
