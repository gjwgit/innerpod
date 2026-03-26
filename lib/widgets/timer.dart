// A countdown timer and buttons for a session.
//
// Time-stamp: <Thursday 2026-02-19 19:57:31 +1100 Graham Williams>
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

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:innerpod/constants/audio.dart';
import 'package:innerpod/constants/spacing.dart';
import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/utils/log_message.dart';
import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/app_button.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';

/// The default session length is 20 minutes. That seems to be a world wide
/// default. We only utilise this constant in this file (at least for now).

const defaultSessionSeconds = 20 * 60;

/// A countdown timer widget with buttons for the home page.

// This is a statefull widget so as to track whether GUIDED is chosen and so to
// play an additional auiod at the end of the session.

class Timer extends StatefulWidget {
  ///

  const Timer({super.key});

  @override
  TimerState createState() => TimerState();
}

/// The timer state.

class TimerState extends State<Timer> {
  ////////////////////////////////////////////////////////////////////////
  // STATE
  ////////////////////////////////////////////////////////////////////////

  // Track whether a final audio is required at the end of a session.

  var _isGuided = false;

  // Track whether the timer is currently paused.

  var _isPaused = false;

  // Record the currently selected duration for the session, as seconds.

  var _duration = defaultSessionSeconds;

  // Track the start time of a session.

  DateTime? _startTime;

  // Track the session type.

  String _sessionType = 'none';

  ////////////////////////////////////////////////////////////////////////
  // CONSTANTS
  ////////////////////////////////////////////////////////////////////////

  // Identify constants used within this file.

  // The [CountDownController] supports operations on the countdown timer
  // itself.

  final _controller = CountDownController();

  // The [AudioPlayer] supports playing audio files.

  final _player = AudioPlayer();

  // Controllers for session metadata.

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // A GlobalKey to ensure the timer display is preserved across orientation
  // changes.

  final _timerKey = GlobalKey();

  ////////////////////////////////////////////////////////////////////////
  // SLEEP
  ////////////////////////////////////////////////////////////////////////

  // Turn on device sleeping. I.e., disable the lock so the device can sleep.

  void _allowSleep() => WakelockPlus.disable();

  // Turn off device sleeping. I.e., lock the device into being awake.

  void _stopSleep() => WakelockPlus.enable();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _duration = prefs.getInt('timer_duration') ?? defaultSessionSeconds;
        _isGuided = prefs.getBool('is_guided') ?? false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_duration', _duration);
    await prefs.setBool('is_guided', _isGuided);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _player.dispose();
    super.dispose();
  }

  /// Helper to play an audio source and wait for it to complete.
  Future<void> _play(Source source) async {
    if (!mounted) return;
    try {
      await _player.stop();
      await _player.play(source);
      // Wait for the audio to finish playing.
      await _player.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Audio playback error or interrupted: $e');
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // RESET
  ////////////////////////////////////////////////////////////////////////

  void _reset() {
    _player.stop();
    _controller.restart(duration: _duration);
    _controller.pause();
    _isGuided = false;
    _isPaused = false;
    _sessionType = 'none';
  }

  ////////////////////////////////////////////////////////////////////////
  // INTRO
  ////////////////////////////////////////////////////////////////////////

  Future<void> _intro() async {
    // An audio is played and then we begin the session.

    logMessage('Start Intro Session');
    if (mounted) {
      setState(() {
        _reset();
        _isGuided = false;
        _sessionType = 'intro';
        _startTime = DateTime.now();
      });
      _stopSleep();
    }

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Play and wait for the intro audio.
    await _play(introAudio);
    if (!mounted) return;

    // Good to wait another 1 second here before the dings after the
    // introduction audio, otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await _play(dong);
    if (!mounted) return;
    _controller.restart(duration: _duration);
  }

  ////////////////////////////////////////////////////////////////////////
  // GUIDED
  ////////////////////////////////////////////////////////////////////////

  Future<void> _guided() async {
    // An audio guide to meditation is played that includes the musical
    // interlude, then the dongs, a silent session, the final dongs, then
    // another musical interlude.

    logMessage('Start Guided Session');
    if (mounted) {
      setState(() {
        _reset();
        _isGuided = true;
        _sessionType = 'guided';
        _startTime = DateTime.now();
      });
      _stopSleep();
    }

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Play and wait for the session guide audio to finish.
    await _play(sessionGuide);
    if (!mounted) return;

    // Good to wait a second before the dings otherwise it feels rushed coming
    // straight from the music.

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // The introductions are complete. We play the dings and start the timer.

    await _play(dong);
    if (!mounted) return;
    _controller.restart(duration: _duration);
  }

  ////////////////////////////////////////////////////////////////////////
  // COMPLETE
  ////////////////////////////////////////////////////////////////////////

  Future<void> _complete() async {
    // What to do at the end of a session.

    logMessage('Session Completed');

    final typeToSave = _sessionType;

    // Only play audio and wait if still mounted
    if (mounted) {
      await _play(dong);
    }

    // Check mounted state again after the dings
    if (mounted && _isGuided) {
      // Release the player resources to ensure a clean state for the final audio
      // which helps with issues on Linux with Zoom audio sharing.
      await _player.release();

      // Add a delay between the dings and the outro music for smoother transition
      // especially on systems with busy audio pipes (like Linux with audio sharing).
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Use inline play logic instead of _play() because _play() calls stop()
        // which might fail on a released player, preventing play() from running.
        try {
          await _player.play(sessionOutro);
          await _player.onPlayerComplete.first;
        } catch (e) {
          debugPrint('Audio playback error (final outro): $e');
        }
      }
    }

    // Reset controls only if still mounted to avoid AnimationController errors
    if (mounted) {
      setState(() {
        _reset();
      });
      _allowSleep();
    }

    // Always attempt to save the session, even if navigate away
    // _saveSession handles its own internal null checks
    await _saveSession(typeOverride: typeToSave);
  }

  Future<void> _saveSession({String? typeOverride}) async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final session = {
      'start': _startTime!.toIso8601String(),
      'end': endTime.toIso8601String(),
      'type': typeOverride ?? _sessionType,
      'silenceDuration': _duration,
      'title': _titleController.text,
      'description': _descriptionController.text,
    };

    try {
      String? content;
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        // File doesn't exist yet, we'll create it.
        debugPrint('sessions.ttl does not exist, creating new file.');
        content = null;
      }

      String newContent = addSession(content, session);
      await writePod('sessions.ttl', newContent, overwrite: true);
      logMessage('Session saved to Pod');

      _startTime = null;
      _titleController.clear();
      _descriptionController.clear();
    } on SecurityKeyNotAvailableException {
      debugPrint('Security key missing - cannot save session. Prompting user.');
      if (mounted) {
        await getKeyFromUserIfRequired(context, widget);
        if (mounted) {
          // Retry saving session after popup closes
          await _saveSession(typeOverride: typeOverride);
        }
      }
    } catch (e) {
      logMessage('Error saving session to Pod: $e');
      _startTime = null;
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // BUILD
  ////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Build the Timer Widget.

    ////////////////////////////////////
    // APP BUTTONS
    ////////////////////////////////////

    // We begin with building the six main app buttons that are displayed on the
    // home screen. Each button has a label, tootltip, and a callback for when
    // the button is pressed.

    final startButton = AppButton(
      title: 'Start',
      tooltip: '''

Tap here to begin a session of silence for ${(_duration / 60).round()}
minutes, beginning and ending with three chimes. The blue progress
circle indicates an active session.

'''
          .trim(),
      onPressed: () {
        logMessage('Start Session');
        if (mounted) {
          dingDong(_player);
          _controller.restart(duration: _duration);
          _stopSleep();
          setState(() {
            _reset();
            _sessionType = 'bell';
            _startTime = DateTime.now();
          });
        }
      },
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.lightGreenAccent.shade100,
      textColor: _sessionType == 'bell' ? Colors.blue : null,
    );

    final pauseResumeButton = AppButton(
      title: _isPaused ? 'Resume' : 'Pause',
      tooltip: _isPaused
          ? '''

Tap here to Resume the timer and the audio from where they were paused.

'''
              .trim()
          : '''

Tap here to Pause the timer and the audio. They can be resumed with a press
of the Resume button.

'''
              .trim(),
      onPressed: () {
        setState(() {
          if (_isPaused) {
            // Resume the timer and audio.
            _controller.resume();
            _player.resume();
            _stopSleep();
            _isPaused = false;
          } else {
            // Pause the timer and audio.
            _controller.pause();
            _player.pause();
            _allowSleep();
            _isPaused = true;
          }
        });
      },
    );

    final introButton = AppButton(
      title: 'Intro',
      tooltip: '''

Tap here to play a short introduction for a session.  After the introduction a
${(_duration / 60).round()} minute session of silence will begin and end with
three dings. The blue progress circle indicates an active session.

'''
          .trim(),
      onPressed: _intro,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.blue.shade100,
      textColor: _sessionType == 'intro' ? Colors.blue : null,
    );

    final guidedButton = AppButton(
      title: 'Guided',
      tooltip: '''

Tap here to play a ${10 + (_duration / 60).round()} minute guided session.
The session begins with instructions for meditation from John Main.
Introductory music is followed by three chimes and a ${(_duration / 60).round()}
minute silent session which is then finished with another three chimes. The
blue progress circle indicates an active session.  The
audio may take a little time to download for the Web version.

'''
          .trim(),
      onPressed: _guided,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.purple.shade100,
      textColor: _sessionType == 'guided' ? Colors.blue : null,
    );

    ////////////////////////////////////
    // DURATION CHOICE
    ////////////////////////////////////

    final Widget durationChoice = Wrap(
      spacing: 8.0, // Gap between adjacent chips.
      runSpacing: 4.0, // Gap between lines.
      children: [5, 10, 15, 20, 25, 30].map((number) {
        return ChoiceChip(
          label: Text(number.toString()),
          selected: _duration == number * 60,
          selectedColor: Colors.lightGreenAccent,
          showCheckmark: false, // This will hide the tick mark.
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _duration = number * 60;
                debugPrint('CHOOSE: duration $_duration');
                _controller.restart(duration: _duration);
                _controller.pause();
                _player.stop();
                _allowSleep();
              });
              _saveSettings();
            }
          },
        );
      }).toList(),
    );

    ////////////////////////////////////
    // RETURN
    ////////////////////////////////////

    final timerDisplay = AppCircularCountDownTimer(
      key: _timerKey,
      duration: _duration,
      controller: _controller,
      onComplete: _complete,
    );

    final buttonsMatrix = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              introButton,
              const SizedBox(width: widthSpacer),
              startButton,
            ],
          ),
          const SizedBox(height: heightSpacer),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              guidedButton,
              const SizedBox(width: widthSpacer),
              pauseResumeButton,
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Select duration (minutes)',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          durationChoice,
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter session title (optional)',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter session description (optional)',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return SingleChildScrollView(
            child: Padding(
              // Add some top and bottom padding so the timer is not clipped at the
              // top nor the chips at the bottom.
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2 * heightSpacer),
                  timerDisplay,
                  const SizedBox(height: 2 * heightSpacer),
                  buttonsMatrix,
                ],
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: timerDisplay)),
                  const SizedBox(width: 2 * widthSpacer),
                  Expanded(child: Center(child: buttonsMatrix)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
