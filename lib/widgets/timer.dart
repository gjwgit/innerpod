/// A countdown timer and buttons for a session.
//
// Time-stamp: <Monday 2024-07-01 12:12:27 +1000 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:innerpod/constants/audio.dart';
import 'package:innerpod/constants/spacing.dart';
import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/utils/log_message.dart';
import 'package:innerpod/widgets/app_button.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';

/// The default session length is 20 minutes.That seems to be a world wide
/// default.

const defaultSessionSeconds = 20 * 60;

/// A countdown timer widget with buttons for the home page.

// This is a statefull widget so as to track whether GUIDED is chosen and so not
// to do the final ding. Once we break GUIDED audio into individual tracks
// (currently 20240626) it is one 30 minute file) then revisit this decision of
// a stateful widget. 20240203 gjw

class Timer extends StatefulWidget {
  ///

  const Timer({super.key});

  @override
  TimerState createState() => TimerState();
}

/// The timer state.

class TimerState extends State<Timer> {
  // Here we create the variables to record the state. Originally state was
  // recoreded for _isGuided but we no longer need this. Do we still need state?
  // 20240701 gjw.

  var _isGuided = false;

  // The [CountDownController] supports operations on the countdown timer
  // itself.

  final _controller = CountDownController();

  // The [AudioPlayer] supports playing audio files.

  final _player = AudioPlayer();

  // The duration is the currently selected duration for the session recorded in
  // seconds.

  var _duration = defaultSessionSeconds;

  // The INTRO choice is the AI generated voice intro and it's duration is
  // determined dynamically as 17.632 seconds.

  // The GUIDED version is JM for now.

  // TODO 20240626 gjw SPLIT JM AUDIO INTO THREE.
  //
  // SPLIT INTO introInstructions, introMusic, AND outroMuisc. THEN DYNAMICALLY
  // DETERMINE LENGTHS AND USE THAT HERE.

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

  // final _guidedIntroTime = 5 * 60 + 0; //JM
  // final _guidedOutroTime = 5 * 60 + 25; //JM

  var _audioDuration = Duration.zero;

  // Turn on device sleeping. I.e., disable the lock so the device can sleep.

  void _allowSleep() => WakelockPlus.disable();

  // Turn off device sleeping. I.e., lock the device into being awake.

  void _stopSleep() => WakelockPlus.enable();

  ////////////////////////////////////////////////////////////////////////
  // RESET
  ////////////////////////////////////////////////////////////////////////

  void _reset() {
    _player.stop();
    _controller.restart();
    _controller.pause();
    _isGuided = false;
  }

  ////////////////////////////////////////////////////////////////////////
  // INTRO
  ////////////////////////////////////////////////////////////////////////

  Future<void> _intro() async {
    // The audio is played and then we begin the session.

    logMessage('Start Intro Session');
    _reset();

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    // Make sure there is no other audio playing just now and then start the
    // intro audio.

    await _player.stop();
    await _player.play(introAudio);

    debugPrint('INTRO: waiting $_audioDuration');

    // Wait now while the intro audio is played before the dong when the timer
    // then actually starts.

    //await Future.delayed(Duration(seconds: _introTime));
    await Future.delayed(_audioDuration);

    // Good to wait another 1 second here before the dings after the
    // introduction audio, otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    _stopSleep();
    await dingDong(_player);
    _controller.restart();
  }

  ////////////////////////////////////////////////////////////////////////
  // GUIDED
  ////////////////////////////////////////////////////////////////////////

  Future<void> _guided() async {
    // Ensure any currently playing audio and the countdown timer are stopped.

    logMessage('Start Guided Session');
    _reset();
    _isGuided = true;

    // Good to wait a second before starting the audio after tapping the button,
    // otherwise it feels rushed.

    await Future.delayed(const Duration(seconds: 1));

    // Play and wait for the session guide audio to finish.

    await _player.play(sessionGuide);
    debugPrint('GUIDED: waiting $_audioDuration');
    await Future.delayed(_audioDuration);

    // Play and wait for the intro music to finish.

    await _player.play(sessionIntro);
    debugPrint('GUIDED: waiting $_audioDuration');
    await Future.delayed(_audioDuration);

    // Good to wait a second before the dings otherwise it feels rushed coming
    // straight from the music.

    await Future.delayed(const Duration(seconds: 1));

    // The introductions are complete. We now tell the device not to sleep, play
    // the dings, and start the timer.

    _stopSleep();
    await dingDong(_player);
    debugPrint('GUIDED: waiting $_audioDuration');
    _controller.restart();
  }

  ////////////////////////////////////////////////////////////////////////
  // COMPLETE
  ////////////////////////////////////////////////////////////////////////

  Future<void> _complete() async {
    logMessage('Session Completed');
    await _player.play(dong);
    debugPrint('COMPLETE: waiting: $_audioDuration');
    await Future.delayed(_audioDuration);

    if (_isGuided) {
      await _player.play(sessionOutro);
      debugPrint('COMPLETE: waiting: $_audioDuration');
      await Future.delayed(_audioDuration);
    }

    _reset();
    _allowSleep();
  }

  @override
  Widget build(BuildContext context) {
    // Build the GUI

    // Add a listener for a change in the duration of the playing audio
    // file. When the audio is loaded from file then take note of the duration
    // of the audio which will then be used to pause until the audio is
    // complete. 20240329 gjw

    _player.onDurationChanged.listen((d) {
      _audioDuration = d;
    });

    //_duration = 5; // TESTING

    ////////////////////////////////////////////////////////////////////////
    // APP BUTTONS
    ////////////////////////////////////////////////////////////////////////

    // We begin with building the six main app buttons that are displayed on the
    // home screen. Each button has a label, tootltip, and a callback for when
    // the button is pressed.

    final startButton = AppButton(
      title: 'Start',
      tooltip: 'Press here to begin a session of silence for '
          '${(_duration / 60).round()} minutes,\n'
          'beginning and ending with three dings.',
      onPressed: () {
        logMessage('Start Session');
        _reset();
        dingDong(_player);
        _controller.restart();
        _stopSleep();
      },
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.lightGreenAccent.shade100,
    );

    final pauseButton = AppButton(
      title: 'Pause',
      tooltip: 'Press here to Pause the timer and the audio.\n'
          'They can be resumed with a press\n'
          'of the Resume button.',
      onPressed: () {
        _controller.pause();
        _player.pause();
        _allowSleep();
      },
    );

    final resumeButton = AppButton(
      title: 'Resume',
      tooltip: 'After a Pause the timer and the audio can be resumed\n'
          'with a press of the Resume button.',
      onPressed: () {
        _controller.resume();
        _player.resume();
        _stopSleep();
      },
    );

    final resetButton = AppButton(
        title: 'Reset',
        tooltip: 'Press here to reset the session. The count down timer\n'
            'and the audio is stopped.',
        onPressed: () {
          _reset();
          _allowSleep();
        });

    final introButton = AppButton(
      title: 'Intro',
      tooltip: 'Press here to play a short introduction for a session.\n'
          'After the introduction a ${(_duration / 60).round()} minute\n'
          'session will begin and end with three dings.',
      onPressed: _intro,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.blue.shade100,
    );

    final guidedButton = AppButton(
      title: 'Guided',
      tooltip: 'Press here to play a full 30 minute guided session.\n\n'
          'The session begins with instructions for meditation from John Main.\n'
          'Introductory and final music tracks are played between which\n'
          '20 minutes of silence is introduced and finished with three dings.\n\n'
          'The audio may take a little time to download for the Web version',
      onPressed: _guided,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.purple.shade100,
    );

    ////////////////////////////////////////////////////////////////////////
    // DURATION CHOICE
    ////////////////////////////////////////////////////////////////////////

    final Widget durationChoice = Wrap(
      spacing: 8.0, // Gap between adjacent chips.
      runSpacing: 4.0, // Gap between lines.
      children: [10, 15, 20, 25, 30].map((number) {
        return ChoiceChip(
          label: Text(number.toString()),
          selected: _duration == number * 60,
          selectedColor: Colors.lightGreenAccent,
          showCheckmark: false, // This will hide the tick mark.
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _duration = number * 60;
                debugPrint('CHOOSE: duration $_duration');
                _controller.restart(duration: _duration);
                _controller.pause();
                _player.stop();
                _allowSleep();
              }
            });
          },
        );
      }).toList(),
    );

    ////////////////////////////////////////////////////////////////////////
    // BUILD THE MAIN WIDGET
    ////////////////////////////////////////////////////////////////////////

    return SingleChildScrollView(
      child: Padding(
        // Add some top and bottom padding so the timer is not clipped at the
        // top nor the chips at the bottom.
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppCircularCountDownTimer(
              duration: _duration,
              controller: _controller,
              onComplete: _complete,
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
                guidedButton,
                const SizedBox(width: widthSpacer),
                resetButton,
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
                const Text(
                  'Minutes:    ',
                  style: TextStyle(fontSize: 20.0, color: Colors.grey),
                ),
                durationChoice,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
