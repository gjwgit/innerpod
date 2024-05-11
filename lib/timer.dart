/// A countdown timer and buttons for a session.
//
// Time-stamp: <Saturday 2024-05-11 21:27:44 +1000 Graham Williams>
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

import 'package:innerpod/constants.dart';

void _logit(String msg) {
  final ts = DateTime.now();
  debugPrint('LOG TO POD: ${DateFormat("yMMddTHHmmss").format(ts)} $msg');
}

/// A countdown timer widget with buttons for the home page.

// TODO 20240203 gjw THIS NEEDS TO BE A STATEFULL WIDGET SINCE IT TRACKS WHETHER
// GUIDED IS CHOSEN AND SO NOT TO DO THE FINAL DING.

class Timer extends StatefulWidget {
  const Timer({Key? key}) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  //

  final _controller = CountDownController();
  final _player = AudioPlayer();

  // TODO 20240329 gjw Introduce a duration selection for 20, 30, 40 minutes
  // instead of this hard coded choice.

  var _duration = 20 * 60;

  // For the guided session we play the dong after a delay to match the
  // audio. For non-guided sessions we dong immediately at the termination of the
  // countdown timer.

  var _isGuided = false;

  // The intro is always the AI intro now.

  // DETERMINED DYNAMICALLY final _introTime = 18;

  // The guided version is either AI or JM. Let's assume JM for now. New issue
  // to slplit JM into introInstructions, IntroMusic, outroMuisc. Then
  // dynamically determin lengths, and use that here

  // The developing AI session has the following intro time and no outro at
  // present. The intro time is the time to wait until the dings in the audio
  // occur.

  // final _guidedIntro = 60 + 25;
  // final _guidedOutro = 0;

  // The current full JM session has the following intro and outro timing.

  final _guidedIntroTime = 4 * 60 + 45; //JM
  final _guidedOutroTime = 5 * 60 + 25; //JM

  // Set the style for the text of the buttons.

  final _buttonTextStyle = const TextStyle(fontSize: 20);
  final _buttonTextStyleBold = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // A small spacer for layout gaps.

  final _widthSpacer = const SizedBox(width: 20);
  final _heightSpacer = const SizedBox(height: 20);

  // The sound to be played at the beginning and end of a session, being a
  // [Source] from audioplayers.

  final _dong = AssetSource('sounds/dong.ogg');
  final _introAudio = AssetSource('sounds/intro.ogg');
  final _guidedAudio = AssetSource('sounds/session.ogg');

  var _audioDuration = Duration.zero;

  // We encapsulate the playing of the dong into its own function because of the
  // need for it to be async through the await.

  Future<void> _dingDong() async {
    // Always stop the player first in case there is some other audio still
    // playing.
    await _player.stop();
    await _player.play(_dong);
  }

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
    await _player.play(_introAudio);

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

    await _dingDong();
    _controller.restart();
  }

  Future<void> _guided() async {
    _logit('Start Guided');

    // TODO 20240329 gjw This is a demo of getting the audio duration.

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
    await _player.play(_guidedAudio);

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
    // Define the various buttons.

    // TODO 20240317 gjw The button height should be a constant rather than the
    // literal listed here. Also, Google PLay Store noted accessibility
    // guidelines suggest the height should be at least 48.

    final startButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyleBold,
          backgroundColor: Colors.lightGreenAccent,
        ),
        onPressed: () {
          _isGuided = false;
          _dingDong();
          _controller.restart();
          WakelockPlus.enable();
          _logit('Start Session');
        },
        child: const Text('Start'),
      ),
    );

    final pauseButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: () {
          _controller.pause();
          _player.pause();
          WakelockPlus.disable();
        },
        child: const Text('Pause'),
      ),
    );

    final resumeButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: () {
          _controller.resume();
          _player.resume();
          WakelockPlus.enable();
        },
        child: const Text('Resume'),
      ),
    );

    final resetButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: () {
          _controller.restart();
          _controller.pause();
          _player.stop();
          WakelockPlus.disable();
        },
        child: const Text('Reset'),
      ),
    );

    final introButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: _intro,
        child: const Text('Intro'),
      ),
    );

    final guidedButton = SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: _guided,
        child: const Text('Guided'),
      ),
    );

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

// Choose colours for the internal background of the timer and the gradient
    // of the timer neon.

    const text = Colors.black;

    // const spin1 = Color(0xFFFFB31A);
    // const spin2 = Color(0xFFB08261);

    const spin1 = Colors.white;
    final spin2 = Colors.blueAccent.shade700;

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularCountDownTimer(
            width: 250,
            height: 250,
            duration: _duration,
            controller: _controller,
            autoStart: false,
            backgroundColor: background,
            ringColor: spin1,
            fillColor: spin2,
            strokeWidth: 10.0,
            textStyle: const TextStyle(
              color: text,
              fontSize: 55,
            ),
            onComplete: () {
              if (_isGuided) {
                // TODO 20240329 gjw It would be better to check if the audio
                // has finished then wait for it to do so, and once finished to
                // then proceed.
                sleep(Duration(seconds: _guidedOutroTime));
              } else {
                _dingDong();
              }
              // Reset the timer so we see 20:00.
              _controller.restart();
              _controller.pause();
              // Allow the device to sleep.
              WakelockPlus.disable();
            },
            isReverse: true,
            isReverseAnimation: true,
          ),
          _heightSpacer,
          _heightSpacer,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              introButton,
              _widthSpacer,
              startButton,
            ],
          ),
          _heightSpacer,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pauseButton,
              _widthSpacer,
              resumeButton,
            ],
          ),
          _heightSpacer,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              guidedButton,
              _widthSpacer,
              resetButton,
            ],
          ),
          // const Text('a'),
          const SizedBox(height: 20),
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
