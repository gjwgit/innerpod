/// The default circular countdown style for the app.
///
/// Copyright (C) 2024, Togaware Pty Ltd.
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
import 'package:google_fonts/google_fonts.dart';

// CIRCULAR TIMER COLOURS

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
    return CircularCountDownTimer(
      width: 280,
      height: 280,
      duration: duration,
      controller: controller,
      autoStart: false,
      backgroundColor: Colors.white.withValues(alpha: 0.4),
      ringColor: Colors.black.withValues(alpha: 0.05),
      fillColor: Theme.of(context).colorScheme.primary,
      strokeWidth: 12.0,
      strokeCap: StrokeCap.round,
      textStyle: GoogleFonts.outfit(
        color: const Color(0xFF2D1B0E),
        fontSize: 64,
        fontWeight: FontWeight.w600,
        letterSpacing: -2,
      ),
      onComplete: onComplete,
      isReverse: true,
      isReverseAnimation: true,
    );
  }
}
