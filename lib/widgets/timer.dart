// A countdown timer and buttons for a session.
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
import 'package:innerpod/constants/colours.dart';
import 'package:innerpod/constants/spacing.dart';
import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/utils/log_message.dart';
import 'package:innerpod/utils/session_logic.dart';
import 'package:innerpod/widgets/app_button.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';
import 'package:innerpod/widgets/premium_text_field.dart';

// timer_session.dart is a part file — it shares this library's imports.
part 'timer_session.dart';

/// Default session length (20 minutes, matching the worldwide default).

const defaultSessionSeconds = 20 * 60;

/// A countdown timer widget with buttons for the home page.

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  TimerState createState() => TimerState();
}

/// The timer state. Session/audio/sleep logic lives in timer_session.dart
/// via an extension on TimerState.

class TimerState extends State<Timer> {
  ////////////////////////////////////////////////////////////////////////
  // STATE
  ////////////////////////////////////////////////////////////////////////

  var _isGuided = false;
  var _isPaused = false;
  var _duration = defaultSessionSeconds;
  DateTime? _startTime;
  String _sessionType = 'none';

  ////////////////////////////////////////////////////////////////////////
  // CONSTANTS
  ////////////////////////////////////////////////////////////////////////

  final _controller = CountDownController();

  // GlobalKey ensures CircularCountDownTimer's state survives layout
  // switches (portrait ↔ landscape) in OrientationBuilder.
  final _countdownKey = GlobalKey();

  final _player = AudioPlayer();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ////////////////////////////////////////////////////////////////////////
  // LIFECYCLE
  ////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _player.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////////////////
  // SETTINGS
  ////////////////////////////////////////////////////////////////////////

  /// Loads saved settings and restores any active session from this process.
  /// Must live in [TimerState] (not the extension) because it calls [setState].

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final duration = prefs.getInt('timer_duration') ?? defaultSessionSeconds;
    final isGuided = prefs.getBool('is_guided') ?? false;

    if (_SessionSnapshot.isActive) {
      final startTime = _SessionSnapshot.startTime!;
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      final remaining = _SessionSnapshot.duration - elapsed;

      if (remaining > 0) {
        setState(() {
          _duration = _SessionSnapshot.duration;
          _isGuided = _SessionSnapshot.isGuided;
          _sessionType = _SessionSnapshot.sessionType;
          _startTime = startTime;
          _isPaused = false;
        });
        _stopSleep();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _controller.restart(duration: remaining);
            }
          });
        });
        return;
      } else {
        _SessionSnapshot.clear();
      }
    }

    setState(() {
      _duration = duration;
      _isGuided = isGuided;
    });
  }

  ////////////////////////////////////////////////////////////////////////
  // BUILD
  ////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    ////////////////////////////////////
    // APP BUTTONS
    ////////////////////////////////////

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
          _reset();
          dingDong(_player);
          _controller.restart(duration: _duration);
          _stopSleep();
          setState(() {
            _sessionType = 'bell';
            _startTime = DateTime.now();
          });
          _saveSessionPrefs();
        }
      },
      fontWeight: FontWeight.bold,
      backgroundColor: startBackgroundColor,
      textColor:
          _sessionType == 'bell' ? Theme.of(context).colorScheme.primary : null,
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
            _controller.resume();
            _player.resume();
            _stopSleep();
            _isPaused = false;
          } else {
            _controller.pause();
            _player.pause();
            _allowSleep();
            _isPaused = true;
          }
        });
      },
      backgroundColor: pauseBackgroundColor,
    );

    final introButton = AppButton(
      title: 'Intro',
      tooltip: '''

Tap here to play a short introduction for a session.  After the introduction a
${(_duration / 60).round()} minute session of silence will begin and end with
three dings. The blue progress circle indicates an active session.

'''
          .trim(),
      onPressed: () {
        setState(() => _sessionType = 'intro');
        _intro();
      },
      fontWeight: FontWeight.bold,
      backgroundColor: introBackgroundColor,
      textColor: _sessionType == 'intro'
          ? Theme.of(context).colorScheme.primary
          : null,
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
      onPressed: () {
        setState(() => _sessionType = 'guided');
        _guided();
      },
      fontWeight: FontWeight.bold,
      backgroundColor: guidedBackgroundColor,
      textColor: _sessionType == 'guided'
          ? Theme.of(context).colorScheme.primary
          : null,
    );

    ////////////////////////////////////
    // DURATION SLIDER
    ////////////////////////////////////

    final Widget durationSlider = Column(
      spacing: 8.0,
      children: [
        Slider(
          value: (_duration / 60).toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          label: (_duration / 60).toInt().toString(),
          onChanged: (double value) {
            setState(() {
              _duration = (value * 60).toInt();
              _controller.restart(duration: (_duration / 60).toInt());
              _controller.pause();
              _player.stop();
              _allowSleep();
            });
            _saveSettings();
          },
        ),
      ],
    );

    final timerDisplay = AppCircularCountDownTimer(
      duration: _duration,
      controller: _controller,
      onComplete: _complete,
      timerKey: _countdownKey,
    );

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonsMatrix = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : functionsBackgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withValues(alpha: 0.3)
              : functionsBackgroundColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select duration (1-30 minutes)',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          durationSlider,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                PremiumTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  hintText: 'Enter session title (optional)',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Enter session description (optional)',
                  icon: Icons.notes,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
