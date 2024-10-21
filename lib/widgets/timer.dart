/// A countdown timer and buttons for a session.
//
// Time-stamp: <Monday 2024-10-21 15:58:06 +1100 Graham Williams>
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

  // Record the currently selected duration for the session, as seconds.

  var _duration = defaultSessionSeconds;

  // Track the duration of a loaded audio file.

  var _audioDuration = Duration.zero;

  ////////////////////////////////////////////////////////////////////////
  // CONSTANTS
  ////////////////////////////////////////////////////////////////////////

  // Identify constants used within this file.

  // The [CountDownController] supports operations on the countdown timer
  // itself.

  final _controller = CountDownController();

  // The [AudioPlayer] supports playing audio files.

  final _player = AudioPlayer();

  ////////////////////////////////////////////////////////////////////////
  // SLEEP
  ////////////////////////////////////////////////////////////////////////

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
    // An audio is played and then we begin the session.

    logMessage('Start Intro Session');
    _reset();
    _stopSleep();

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

    await dingDong(_player);
    _controller.restart();
  }

  ////////////////////////////////////////////////////////////////////////
  // GUIDED
  ////////////////////////////////////////////////////////////////////////

  Future<void> _guided() async {
    // A guide audio is played, then a musical interlude, the session, then
    // another musical interlude.

    logMessage('Start Guided Session');
    _reset();
    _stopSleep();
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

    await dingDong(_player);
    debugPrint('GUIDED: waiting $_audioDuration');
    _controller.restart();
  }

  ////////////////////////////////////////////////////////////////////////
  // COMPLETE
  ////////////////////////////////////////////////////////////////////////

  Future<void> _complete() async {
    // What to do at the end of a session.

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

  ////////////////////////////////////////////////////////////////////////
  // BUILD
  ////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Build the Timer Widget.

    // Add a listener for a change in the duration of the playing audio
    // file. When the audio is loaded from file then take note of the duration
    // of the audio which will then be used to pause until the audio is
    // complete. 20240329 gjw

    _player.onDurationChanged.listen((d) {
      _audioDuration = d;
    });

    ////////////////////////////////////
    // APP BUTTONS
    ////////////////////////////////////

    // We begin with building the six main app buttons that are displayed on the
    // home screen. Each button has a label, tootltip, and a callback for when
    // the button is pressed.

    final startButton = AppButton(
      title: 'Start',
      tooltip: '''

Press here to begin a session of silence for ${(_duration / 60).round()}
minutes, beginning and ending with three chimes.

''',
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
      tooltip: '''

Press here to Pause the timer and the audio.  They can be resumed with a press
of the Resume button.

''',
      onPressed: () {
        _controller.pause();
        _player.pause();
        _allowSleep();
      },
    );

    // TODO 20240708 gjw COMMENT OUT BUTTONS UNTIL FUINCTIONALITY MIGRATED
    //
    // I originally had these extra two buttons but UX suggests one buttont to
    // PAUSE whcih when tapped becomes RESUME and if long held it is RESET.

    // final resumeButton = AppButton(
    //   title: 'Resume',
    //   tooltip: 'After a Pause the timer and the audio can be resumed '
    //       'with a press of the Resume button.',
    //   onPressed: () {
    //     _controller.resume();
    //     _player.resume();
    //     _stopSleep();
    //   },
    // );

    // final resetButton = AppButton(
    //     title: 'Reset',
    //     tooltip: 'Press here to reset the session. The count down timer '
    //         'and the audio is stopped.',
    //     onPressed: () {
    //       _reset();
    //       _allowSleep();
    //     });

    final introButton = AppButton(
      title: 'Intro',
      tooltip: '''

Press here to play a short introduction for a session.  After the introduction a
${(_duration / 60).round()} minute session of silence will begin and end with
three dings.

''',
      onPressed: _intro,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.blue.shade100,
    );

    final guidedButton = AppButton(
      title: 'Guided',
      tooltip: '''

Press here to play a ${10 + (_duration / 60).round()} minute guided session.
The session begins with instructions for meditation from John Main.
Introductory music is followed by three chimes and a ${(_duration / 60).round()}
minute silent session which is then finished with another three chimes.  The
audio may take a little time to download for the Web version.

''',
      onPressed: _guided,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.purple.shade100,
    );

    ////////////////////////////////////
    // DURATION CHOICE
    ////////////////////////////////////

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

    ////////////////////////////////////
    // RETURN
    ////////////////////////////////////

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
                pauseButton,
              ],
            ),
            // TODO 20240707 gjw EVENTUALLY PUT RESUME AND RESET INTO PAUSE.
            //
            // A long press will be RESET. On tap PASUE turn the button
            // into RESUME.
            //
            // const SizedBox(height: heightSpacer),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     resetButton,
            //     const SizedBox(width: widthSpacer),
            //     resumeButton,
            //   ],
            // ),
            const SizedBox(height: 2 * heightSpacer),
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
