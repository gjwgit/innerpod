/// The default circular countdown style for the app.
///
/// Copyright (C) 2024-2026, Togaware Pty Ltd.
///
/// License: https://opensource.org/license/gpl-3-0
///
// Licensed under the GNU General Public License, Version 3 (the "License");
///
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:innerpod/constants/colours.dart';

/// A [CircularCountDownTimer] with defaults for the app.

class AppCircularCountDownTimer extends StatelessWidget {
  /// Idetntify the required parameters.

  const AppCircularCountDownTimer({
    required this.duration,
    required this.onComplete,
    required this.controller,
    super.key,
  });

  /// The duration for the count down in minutes.

  final int duration;

  /// The controller of the count down timer.

  final CountDownController controller;

  /// The action to undertake on a button tap.

  final Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return CircularCountDownTimer(
      width: 250,
      height: 250,
      duration: duration,
      controller: controller,
      autoStart: false,
      backgroundColor: isDark ? cs.surfaceContainerHighest : timerCentralColor,
      ringColor: isDark ? cs.surfaceContainerHighest : spinBackgroundColor,
      fillColor: isDark ? cs.primary : spinColor,
      strokeWidth: 20.0,
      textStyle: TextStyle(
        color: isDark ? cs.onSurface : timerTextColor,
        fontSize: 55,
      ),
      onComplete: onComplete,
      isReverse: true,
      isReverseAnimation: true,
    );
  }
}
