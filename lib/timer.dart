/// A countdown timer and Start button for a session.
//
// Time-stamp: <Thursday 2024-01-25 21:09:10 +1100 Graham Williams>
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

/// Buld a widget for the home page time and buttons.

class Timer extends StatelessWidget {
  /// Initialise the timer.

  Timer({super.key});

  final _controller = CountDownController();
  final _player = AudioPlayer();

  /// Add 1 to the duration to see 20:00 momentarily rather than 19:59, for
  /// example.

  final duration = (20 * 60) + 1;
  // final duration = 41;

  /// Set the style for the text of the buttons.

  final buttonTextStyle = const TextStyle(fontSize: 30);

  /// Set the button size.

  final buttonTheme = ButtonTheme(
    minWidth: 200.0,
    height: 100.0,
    child: ElevatedButton(
      onPressed: () {},
      child: const Text('test'),
    ),
  );

  // A small spacer for layout gaps.

  final _widthSpacer = const SizedBox(width: 20);
  final _heightSpacer = const SizedBox(height: 20);

  // The sound to be played at the beginning and end of a session, being a
  // [Source] from audioplayers.

  final _instruct = AssetSource('sounds/intro.ogg');
  final _dong = AssetSource('sounds/dong.ogg');

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
          textStyle: buttonTextStyle,
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
          textStyle: buttonTextStyle,
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
          textStyle: buttonTextStyle,
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
          textStyle: buttonTextStyle,
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
            duration: duration,
            controller: _controller,
            autoStart: false,
            backgroudColor: Colors.blueGrey.shade600,
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
            innerFillGradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade100,
                Colors.blueAccent.shade700,
              ],
            ),
            neonGradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade100,
                Colors.blueAccent.shade700,
              ],
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
