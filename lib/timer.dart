/// A countdown timer and Start button for a session.
//
// Time-stamp: <Wednesday 2024-01-24 09:49:40 +1100 Graham Williams>
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

class Timer extends StatelessWidget {
  Timer({super.key});

  final controller = CountDownController();
  final player = AudioPlayer();

  // Add 1 to the duration to see 20:00 momentarily rather than 19:59, for
  // example.

  final duration = (20 * 60) + 1;

  // Set the style for the text of the buttons.

  final buttonTextStyle = const TextStyle(fontSize: 30);

  // A small spacer for the buttons.

  final spacer = const SizedBox(width: 20);

  // The sound to be played at the beginning and end of a session, being a
  // [Source] from audioplayers.

  final dong = AssetSource('sounds/dong.ogg');

  // We encapsulate the playing of the dong into its own function because of the
  // need for it to be async through the await.

  Future<void> _dingDong() async {
    await player.play(dong);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonCircularTimer(
            width: 250,
            duration: duration,
            controller: controller,
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
          Padding(
            padding: const EdgeInsets.all(60),
            child: Row(
              children: [
                spacer,
                ElevatedButton(
                  style: TextButton.styleFrom(
                    textStyle: buttonTextStyle,
                  ),
                  onPressed: () {
                    _dingDong();
                    controller.restart();
                    WakelockPlus.enable();
                  },
                  child: const Text('Start'),
                ),
                spacer,
                ElevatedButton(
                  style: TextButton.styleFrom(
                    textStyle: buttonTextStyle,
                  ),
                  onPressed: () {
                    controller.pause();
                    WakelockPlus.disable();
                  },
                  child: const Text('Stop'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
