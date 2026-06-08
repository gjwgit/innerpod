// Session snapshot and audio/sleep/session logic for TimerState.
//
// Time-stamp: <Thursday 2026-03-12 13:26:16 +1100 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
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

// Part of timer.dart — shares all imports declared there.
// Cannot have its own library directive or import statements.

part of 'timer.dart';

////////////////////////////////////////////////////////////////////////
// SESSION SNAPSHOT
////////////////////////////////////////////////////////////////////////

/// In-memory session store — survives widget rebuilds within a single app
/// process but is cleared on app restart (unlike SharedPreferences).

class _SessionSnapshot {
  static DateTime? startTime;
  static String sessionType = 'none';
  static int duration = defaultSessionSeconds;
  static bool isGuided = false;

  static bool get isActive => startTime != null && sessionType != 'none';

  static void save({
    required DateTime start,
    required String type,
    required int dur,
    required bool guided,
  }) {
    startTime = start;
    sessionType = type;
    duration = dur;
    isGuided = guided;
  }

  static void clear() {
    startTime = null;
    sessionType = 'none';
  }
}

////////////////////////////////////////////////////////////////////////
// TIMER LOGIC EXTENSION
////////////////////////////////////////////////////////////////////////

/// Session, audio, and sleep methods for [TimerState].
/// Extracted to timer_session.dart (a part file) to keep each file
/// under 300 meaningful lines.

extension TimerStateLogic on TimerState {
  ////////////////////////////////////////////////////////////////////////
  // SLEEP
  ////////////////////////////////////////////////////////////////////////

  void _allowSleep() => WakelockPlus.disable();
  void _stopSleep() => WakelockPlus.enable();

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_duration', _duration);
    await prefs.setBool('is_guided', _isGuided);
  }

  void _saveSessionPrefs() {
    if (_startTime == null) return;
    _SessionSnapshot.save(
      start: _startTime!,
      type: _sessionType,
      dur: _duration,
      guided: _isGuided,
    );
  }

  void _clearSessionPrefs() {
    _SessionSnapshot.clear();
  }

  ////////////////////////////////////////////////////////////////////////
  // AUDIO
  ////////////////////////////////////////////////////////////////////////

  Future<void> _play(AssetSource source, {double volume = 1.0}) async {
    if (!mounted) return;
    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(source);
      await _player.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Audio playback error or interrupted: $e');
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // RESET
  ////////////////////////////////////////////////////////////////////////

  void _reset({bool stopPlayer = false}) {
    if (stopPlayer) _player.stop();
    _controller.restart(duration: _duration);
    _controller.pause();
    _isGuided = false;
    _isPaused = false;
    _sessionType = 'none';
    _startTime = null;
  }

  ////////////////////////////////////////////////////////////////////////
  // INTRO
  ////////////////////////////////////////////////////////////////////////

  Future<void> _intro() async {
    if (!mounted) return;
    _reset(stopPlayer: true);
    _stopSleep();
    _isGuided = false;
    _sessionType = 'intro';
    _startTime = DateTime.now();
    _saveSessionPrefs();

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await _play(introAudio);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    dingDong(_player);
    _controller.restart(duration: _duration);
  }

  ////////////////////////////////////////////////////////////////////////
  // GUIDED
  ////////////////////////////////////////////////////////////////////////

  Future<void> _guided() async {
    if (!mounted) return;
    _reset(stopPlayer: true);
    _stopSleep();
    _isGuided = true;
    _sessionType = 'guided';
    _startTime = DateTime.now();
    _saveSessionPrefs();

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await _play(sessionGuide);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    dingDong(_player);
    _controller.restart(duration: _duration);
  }

  ////////////////////////////////////////////////////////////////////////
  // COMPLETE
  ////////////////////////////////////////////////////////////////////////

  Future<void> _complete() async {
    final typeToSave = _sessionType;

    // Await bells so all three dings play before we move on.
    if (mounted) {
      await dingDong(_player);
      await _player.onPlayerComplete.first;
    }

    if (mounted && _isGuided) {
      try {
        await _player.release();
        if (mounted) {
          await _player.setVolume(1.0);
          await _player.play(sessionOutro);
          await _player.onPlayerComplete.first;
        }
      } catch (e) {
        debugPrint('Audio playback error (final outro): $e');
      }
    }

    if (mounted) {
      _allowSleep();
      await _saveSession(typeOverride: typeToSave);
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // SAVE SESSION
  ////////////////////////////////////////////////////////////////////////

  Future<void> _saveSession({String? typeOverride}) async {
    if (_startTime == null) return;

    final session = {
      'start': _startTime!.toIso8601String(),
      'end': DateTime.now().toIso8601String(),
      'type': typeOverride ?? _sessionType,
      'silenceDuration': _duration,
      'title': _titleController.text,
    };

    // Determine whether we can reach the Pod. If not logged in, save the
    // session to the local device store instead; it can be promoted to the
    // Pod later from the History view.
    bool loggedIn = false;
    try {
      final webId = await getWebId();
      loggedIn = webId != null && webId.isNotEmpty;
    } catch (_) {
      // getWebId can throw if the keyring is locked — treat as logged out
      // and fall back to local storage so the session is never lost.
      loggedIn = false;
    }

    if (!loggedIn) {
      await _saveSessionLocally(session);
      return;
    }

    try {
      String content = '';
      try {
        content = await readPod('sessions.ttl');
      } catch (e) {
        debugPrint('sessions.ttl does not exist, creating new file.');
      }

      String newContent = addSession(content, session);
      await writePod('sessions.ttl', newContent, overwrite: true);
      logMessage('Session saved to Pod');

      // Notify parent (e.g. to refresh the History screen).
      widget.onSessionSaved?.call();

      _startTime = null;
      _clearSessionPrefs();
      _titleController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (e.toString().contains('You must first set the security key!')) {
        if (mounted) {
          await getKeyFromUserIfRequired(context, widget);
          if (mounted) {
            await _saveSession(typeOverride: typeOverride);
          }
        }
      } else {
        // Pod write failed for some other reason — don't lose the session,
        // store it locally so it can be synced later.
        debugPrint('Session save to Pod failed: $e — storing locally.');
        await _saveSessionLocally(session);
      }
    }
  }

  /// Persist [session] to the local device store and reset the timer state.
  /// Used when the user is not logged in or the Pod write fails.
  Future<void> _saveSessionLocally(Map<String, dynamic> session) async {
    await LocalSessionStore.addSessionLocal(session);
    logMessage('Session saved locally (not logged in)');
    widget.onSessionSaved?.call();
    _startTime = null;
    _clearSessionPrefs();
    _titleController.clear();
    _descriptionController.clear();
  }
}
