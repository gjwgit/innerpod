/// A countdown timer and buttons for a session.
//
// Time-stamp: <Friday 2024-01-26 12:29:24 +1100 Graham Williams>
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

/// A countdown timer widget with buttons for the home page.

class Timer extends StatelessWidget {
  /// Initialise the timer.

  Timer({super.key});

  final _controller = CountDownController();
  final _player = AudioPlayer();

  // Add 1 to the duration to see 20:00 momentarily rather than 19:59, for
  // example. It is 'disturbing' to not initially see the full timer duration on
  // starting.

  final _duration = (20 * 60) + 1;

  // For testing use a short duration.

  // final _duration = 41;

  // Set the style for the text of the buttons.

  final _buttonTextStyle = const TextStyle(fontSize: 20);

  // A small spacer for layout gaps.

  final _widthSpacer = const SizedBox(width: 20);
  final _heightSpacer = const SizedBox(height: 20);

  // The sound to be played at the beginning and end of a session, being a
  // [Source] from audioplayers.

  final _instruct = AssetSource('sounds/intro.ogg');
  final _dong = AssetSource('sounds/dong.ogg');

  // Choose colours for the internal background of the timer and the gradient of
  // the timer neon.

  static const _background = Color(0xFFE6B276);
  static const _spin1 = Color(0xFFFFB31A);
  static const _spin2 = Color(0xFFB08261);

  // We encapsulate the playing of the dong into its own function because of the
  // need for it to be async through the await.

  Future<void> _intro() async {
    await _player.play(_instruct);
  }

  Future<void> _dingDong() async {
    await _player.play(_dong);
  }

  @override
  Widget build(BuildContext context) {
    // Define the various buttons.

    final startButton = SizedBox(
      height: 45,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: _buttonTextStyle,
        ),
        onPressed: () {
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
          WakelockPlus.enable();
        },
        child: const Text('Resume'),
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
            backgroudColor: _background,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 55,
            ),
            onComplete: () {
              _dingDong();
              WakelockPlus.disable();
            },
            isReverse: true,
            isReverseAnimation: true,
            innerFillGradient: const LinearGradient(
              colors: [_spin1, _spin2],
            ),
            neonGradient: const LinearGradient(
              colors: [_spin1, _spin2],
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
        ],
      ),
    );
  }
}
