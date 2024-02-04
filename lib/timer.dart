/// A countdown timer and buttons for a session.
//
// Time-stamp: <Saturday 2024-02-03 21:35:09 +1100 Graham Williams>
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
import 'package:neon_circular_timer/neon_circular_timer.dart';
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
  final _guide = AssetSource('sounds/00_meditation_session.mp3');

  var _isGuided = false;

  // We encapsulate the playing of the dong into its own function because of the
  // need for it to be async through the await.

  Future<void> _intro() async {
    await _player.play(_instruct);
  }

  Future<void> _dingDong() async {
    await _player.play(_dong);
  }

  Future<void> _guided() async {
    _isGuided = true;
    //_controller.restart();
    //_controller.pause();
    await _player.stop();
    await _player.play(_guide);
    //sleep(const Duration(seconds: 275));
    //sleep(const Duration(seconds: 10));
    //_controller.restart();
    //_controller.pause();
    //_controller.resume();
    await WakelockPlus.enable();
  }

  @override
  Widget build(BuildContext context) {
    // Define the various buttons.

    final startButton = SizedBox(
      height: 45,
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
      height: 45,
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
      height: 45,
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
      height: 45,
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
      height: 45,
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
      height: 45,
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

    final spin1 = Colors.blueAccent.shade100;
    final spin2 = Colors.blueAccent.shade700;

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonCircularTimer(
            width: 250,
            duration: _duration,
            controller: _controller,
            autoStart: false,
            // backgroudColor: Colors.blueGrey.shade600,
            backgroudColor: background,
            textStyle: const TextStyle(
              color: text,
              fontSize: 55,
            ),
            onComplete: () {
              if (!_isGuided) {
                _dingDong();
              }
              WakelockPlus.disable();
            },
            isReverse: true,
            isReverseAnimation: true,
            innerFillGradient: LinearGradient(
              colors: [spin1, spin2],
            ),
            neonGradient: LinearGradient(
              colors: [spin1, spin2],
            ),
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
