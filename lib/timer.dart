/// A countdown timer and buttons for a session.
//
// Time-stamp: <Wednesday 2024-03-27 18:38:14 +1100 Graham Williams>
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
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:innerpod/constants.dart';

/// A countdown timer widget with buttons for the home page.

// TODO 20240203 gjw THIS NEEDS TO BE A STATEFULL WIDGET SINCE IT TRACKS WHETHER
// GUIDED IS CHOSEN AND SO NOT TO DO THE FINAL DING.

class Timer extends StatelessWidget {
  /// Initialise the timer.

  Timer({super.key});

  final _controller = CountDownController();
  final _player = AudioPlayer();

  // Add 1 to the duration to see 20:00 momentarily rather than 19:59, for
  // example. It is 'disturbing' to not initially see the full timer duration on
  // starting.

  final _duration = 20 * 60; // + 1;

  // For testing use a short duration.

  // final _duration = 41;

  // A particular session has the following intro and outro timing.

  final _guidedIntro = 4 * 60 + 45;
  final _guidedOutro = 5 * 60 + 25;

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

  final _instruct = AssetSource('sounds/intro.ogg');
  final _dong = AssetSource('sounds/dong.ogg');
  final _guide = AssetSource('sounds/session.ogg');

  // For the guided session we play the dong after a delay to match the
  // audio. Gor non-guided sessions we dong immediately at the termination of the
  // countdown timer.

  var _isGuided = false;

  // We encapsulate the playing of the dong into its own function because of the
  // need for it to be async through the await.

  Future<void> _intro() async {
    _isGuided = false;
    await _player.play(_instruct);
    // TODO 20240327 gjw How to wait until the audio is finished?
    await Future.delayed(const Duration(seconds: 19));
    await _dingDong();
    _controller.restart();
    await WakelockPlus.enable();
  }

  Future<void> _dingDong() async {
    await _player.play(_dong);
  }

  Future<void> _guided() async {
    _isGuided = true;
    await _player.stop();
    await _player.play(_guide);
    await WakelockPlus.enable();
    await Future.delayed(Duration(seconds: _guidedIntro));
    _controller.restart();
    // This now displays 0 until the end of the session whereby the countdown
    // timer is sleeping for the outro.
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
          WakelockPlus.enable();
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
                sleep(Duration(seconds: _guidedOutro));
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
            //innerFillGradient: LinearGradient(
            //  colors: [spin1, spin2],
            //),
            //neonGradient: LinearGradient(
            //  colors: [spin1, spin2],
            //),
            // initialDuration: 5, // THIS IS THE TIME ALREADY COMPLETED
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
        ],
      ),
    );
  }
}
