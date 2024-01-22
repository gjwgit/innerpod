/// A countdown timer for a meditation session.
//
// Time-stamp: <Monday 2024-01-22 20:55:48 +1100 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:neon_circular_timer/neon_circular_timer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Timer extends StatelessWidget {
  final CountDownController controller = CountDownController();
  final player = AudioPlayer();

  Timer({super.key});

  Future<void> _dingDong() async {
    await player.play(AssetSource('sounds/dong.ogg'));
  }

  @override
  Widget build(BuildContext context) {
    return NeonCircularTimer(
      width: 200,
      duration: 20 * 60,
      controller: controller,
      onStart: () {
        WakelockPlus.enable();
        _dingDong();
      },
      onComplete: () {
        _dingDong();
        WakelockPlus.disable();
      },
      isReverse: true,
      isReverseAnimation: true,
      // initialDuration: 5, // THIS IS THE TIME ALREADY COMPLETED
    );
  }
}
