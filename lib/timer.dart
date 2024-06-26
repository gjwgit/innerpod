/// A countdown timer and buttons for a session.
//
// Time-stamp: <Wednesday 2024-06-26 12:18:02 +1000 Graham Williams>
//
/// Copyright (C) 2024, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams

library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:innerpod/constants/audio.dart';
import 'package:innerpod/constants/spacing.dart';
import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/widgets/app_button.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';

void _logit(String msg) {
  final ts = DateTime.now();
  debugPrint('LOG TO POD: ${DateFormat("yMMddTHHmmss").format(ts)} $msg');
}

/// A countdown timer widget with buttons for the home page.

// 20240203 gjw This is a statefull widget so as to track whether GUIDED is
// chosen and so not to do the final ding. Once we break GUIDED audio into
// individual tracks (currently 20240626) it is one 30 minute file) then revisit
// this decision of a stateful widget.

class Timer extends StatefulWidget {
  /// Intialise the timer state.

  const Timer({super.key});

  @override
  TimerState createState() => TimerState();
}

/// The timer state.

class TimerState extends State<Timer> {
  //

  final _controller = CountDownController();
  final _player = AudioPlayer();

  // The default duration is 20 minutes. That seems to be a world wide default.

  var _duration = 20 * 60;

  // For the guided session we play the dong after a delay to match the
  // audio. For non-guided sessions we dong immediately at the termination of the
  // countdown timer.

  var _isGuided = false;

  // The INTRO choice is the AI generated voice intro and it's duration is
  // determined dynamically as 17.632 seconds.

  // The GUIDED version is JM for now.

  // TODO 20240626 gjw SPLIT JM INTO introInstructions, introMusic, AND
  // outroMuisc. THEN DYNAMICALLY DETERMINE LENGTHS AND USE THAT HERE.

  // The AI generated voice session has the following intro time and no outro at
  // present. The intro time is the time to wait until the dings in the audio
  // occur.

  // final _guidedIntro = 60 + 25;
  // final _guidedOutro = 0;

  // The full JM session has the following intro and outro timing. The intro
  // timing is used to identify when the start the timer count down. It is not
  // an exact match with start and end for the 20 minutes separated dong, but
  // close. The dings in the recording come some 30 seconds after the countdown
  // timer reaches 0.

  final _guidedIntroTime = 5 * 60 + 0; //JM
  final _guidedOutroTime = 5 * 60 + 25; //JM

  var _audioDuration = Duration.zero;

  Future<void> _intro() async {
    // The audio is played and then we begin the session.

    _logit('Start Intro');

    // Add a listener for a change in the duration of the playing audio
    // file. When the audio is loaded from file then take note of the duration
    // of the audio.

    _player.onDurationChanged.listen((d) {
      _audioDuration = d;
      debugPrint('INTRO: insider duration=$_audioDuration');
    });

    // Not yet working. The first time this is 0!

    debugPrint('INTRO: outsider duration: $_audioDuration');

    // We want the dongs at the end of the session because unlike the current
    // guided audio the intro audio does not contain its own dongs. This will
    // change eventually when the different sections of the guided audio will be
    // orchestrted in the code rather than a single session file.

    _isGuided = false;

    // Make sure we are ready for a session and the duration is shown.

    _controller.restart();
    _controller.pause();

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    // Make sure there is no other audio playing just now and then start the
    // intro audio.

    await _player.stop();
    await _player.play(introAudio);

    debugPrint('INTRO: latest duration: $_audioDuration');

    // Wait now while the intro audio is played before the dong when the timer
    // then actually starts.

    //await Future.delayed(Duration(seconds: _introTime));
    await Future.delayed(_audioDuration);

    // Good to wait another 1 second here before the dings after the
    // introduction audio, otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    // Turn off device sleeping. I.e., lock the device into being awake.

    await WakelockPlus.enable();

    _logit('Start Intro Session');

    await dingDong(_player);
    _controller.restart();
  }

  Future<void> _guided() async {
    _logit('Start Guided');

    // TODO 20240329 gjw THIS IS A DEMO OF GETTING THE AUDIO
    // DURATION. PRESUMABLY I CAN GET RID OF THE debugPrint() calls BUT STILL
    // NEED THE audioDuration ASSIGNEMNT TO KEEP THINGS WORKING.

    _player.onDurationChanged.listen((d) {
      _audioDuration = d;
      debugPrint('GUIDED: insider duration: $_audioDuration');
    });

    debugPrint('GUIDED: outsider duration: $_audioDuration');

    _isGuided = true;

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    // Ensure any playing sudio is stopped.

    await _player.stop();
    await _player.play(guidedAudio);

    debugPrint('GUIDED: latest duration: $_audioDuration');

    // Always reset (by doing a restart and then pause) any current timer
    // session. For now with the fixed whole session audio, it includes a 20
    // minute session so we make sure that is the case here

    _duration = 20 * 60;
    _controller.restart(duration: _duration);
    _controller.pause();

    // Turn off device sleeping.

    await WakelockPlus.enable();

    // Wait for the intro of the guided session to complete.

    await Future.delayed(Duration(seconds: _guidedIntroTime));

    _controller.restart();
  }

  @override
  Widget build(BuildContext context) {
    // Build the GUI

    ////////////////////////////////////////////////////////////////////////
    // APP BUTTONS
    //
    // We begin with building the six main app buttons that are displayed on the
    // home screen. Each button has a label, tootltip, and a callback for when
    // the button is pressed.
    ////////////////////////////////////////////////////////////////////////

    final startButton = AppButton(
      title: 'Start',
      tooltip: 'Press here to begin a session of silence for '
          '${(_duration / 60).round()} minutes,\n'
          'beginning and ending with three dings.',
      onPressed: () {
        _isGuided = false;
        dingDong(_player);
        _controller.restart();
        WakelockPlus.enable();
        _logit('Start Session');
      },
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.lightGreenAccent,
    );

    final pauseButton = AppButton(
      title: 'Pause',
      tooltip: 'Press here to Pause the timer and the audio.\n'
          'They can be resumed with a press\n'
          'of the Resume button.',
      onPressed: () {
        _controller.pause();
        _player.pause();
        WakelockPlus.disable();
      },
    );

    final resumeButton = AppButton(
      title: 'Resume',
      tooltip: 'After a Pause the timer and the audio can be resumed\n'
          'with a press of the Resume button.',
      onPressed: () {
        _controller.resume();
        _player.resume();
        WakelockPlus.enable();
      },
    );

    final resetButton = AppButton(
      title: 'Reset',
      tooltip: 'Press here to reset the session. The count down timer\n'
          'and the audio is stopped.',
      onPressed: () {
        _controller.restart();
        _controller.pause();
        _player.stop();
        WakelockPlus.disable();
      },
    );

    final introButton = AppButton(
      title: 'Intro',
      tooltip: 'Press here to play a short introduction for a session.\n'
          'After the introduction a ${(_duration / 60).round()} minute\n'
          'session will begin and end with three dings.',
      onPressed: _intro,
    );

    final guidedButton = AppButton(
      title: 'Guided',
      tooltip: 'Press here to play a full 30 minute guided session.\n\n'
          'The session begins with instructions for meditation from John Main.\n'
          'Introductory and final music tracks are played between which\n'
          '20 minutes of silence is introduced and finished with three dings.\n\n'
          'The audio may take a little time to download for the Web version',
      onPressed: _guided,
    );

    ////////////////////////////////////////////////////////////////////////
    // DURATION CHOICE
    ////////////////////////////////////////////////////////////////////////

    final Widget durationChoice = Wrap(
      spacing: 8.0, // Gap between adjacent chips.
      runSpacing: 4.0, // Gap between lines.
      children: [10, 15, 20, 30].map((number) {
        return ChoiceChip(
          label: Text(number.toString()),
          selected: _duration == number * 60,
          selectedColor: Colors.lightGreenAccent,
          showCheckmark: false, // This will hide the tick mark.
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _duration = number * 60;
                debugPrint('Reset duration to $_duration');
                _controller.restart(duration: _duration);
                _controller.pause();
                _player.stop();
                WakelockPlus.disable();
              }
            });
          },
        );
      }).toList(),
    );

    ////////////////////////////////////////////////////////////////////////
    // BUILD THE MAIN WIDGET
    ////////////////////////////////////////////////////////////////////////

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCircularCountDownTimer(
            duration: _duration,
            controller: _controller,
            onComplete: () {
              if (_isGuided) {
                // TODO 20240329 gjw It would be better to check if the audio
                // has finished then wait for it to do so, and once finished to
                // then proceed.
                sleep(Duration(seconds: _guidedOutroTime));
              } else {
                dingDong(_player);
              }
              // Reset the timer so we see 20:00.
              _controller.restart();
              _controller.pause();
              // Allow the device to sleep.
              WakelockPlus.disable();
            },
          ),
          const SizedBox(height: 2 * heightSpacer),
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
              pauseButton,
              const SizedBox(width: widthSpacer),
              resumeButton,
            ],
          ),
          const SizedBox(height: heightSpacer),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              guidedButton,
              const SizedBox(width: widthSpacer),
              resetButton,
            ],
          ),
          const SizedBox(height: heightSpacer),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Minutes:    ',
                style: TextStyle(fontSize: 20.0, color: Colors.grey),
              ),
              durationChoice,
            ],
          ),
        ],
      ),
    );
  }
}
