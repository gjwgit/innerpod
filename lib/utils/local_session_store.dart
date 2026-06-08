/// LocalSessionStore — offline persistence for meditation sessions.
///
/// When the user is not logged in (or the Pod is unreachable), sessions are
/// saved here to local device storage (SharedPreferences) instead of the
/// Pod. They are reused to populate the History view, and can later be
/// promoted ("synced") to the Pod individually once the user logs in.
///
/// Sessions are stored using the same TTL serialisation as the Pod
/// (via session_logic), so they round-trip through parseSessions identically.
///
// Time-stamp: <2026-06-08>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:innerpod/utils/session_logic.dart';

/// Local (un-synced) session storage backed by SharedPreferences.
class LocalSessionStore {
  LocalSessionStore._();

  /// SharedPreferences key holding the serialised local sessions (TTL text).
  static const String _key = 'innerpod_local_sessions';

  /// Read the raw serialised content of the local store (TTL text), or an
  /// empty string if nothing is stored.
  static Future<String> readContent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  /// Return the locally-stored sessions as parsed maps.
  static Future<List<Map<String, String>>> readSessions() async {
    return parseSessions(await readContent());
  }

  /// Add [session] to the local store.
  static Future<void> addSessionLocal(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_key) ?? '';
    final updated = addSession(current, session);
    await prefs.setString(_key, updated);
  }

  /// Remove the local session identified by its [startTime] (the raw start
  /// string used as the session id).
  static Future<void> removeSessionLocal(String startTime) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_key) ?? '';
    if (current.isEmpty) return;
    final updated = deleteSession(current, startTime);
    await prefs.setString(_key, updated);
  }

  /// True if there is at least one locally-stored session.
  static Future<bool> hasLocal() async {
    final content = await readContent();
    return parseSessions(content).isNotEmpty;
  }

  /// Clear all locally-stored sessions.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
