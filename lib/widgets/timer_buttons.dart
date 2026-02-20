// Buttons for controlling the session timer.
//
// Time-stamp: <Saturday 2026-02-21 01:16:00 +1100 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Amogh Hosamane

library;

import 'package:flutter/material.dart';

import 'package:innerpod/widgets/app_button.dart';

class TimerButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onIntro;
  final VoidCallback onGuided;
  final bool isPaused;
  final double durationInMinutes;

  const TimerButtons({
    required this.onStart,
    required this.onPauseResume,
    required this.onIntro,
    required this.onGuided,
    required this.isPaused,
    required this.durationInMinutes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              title: 'Intro',
              tooltip: '''
Tap here to play a short introduction for a session. After the introduction a
${durationInMinutes.round()} minute session of silence will begin and end with
three dings. The blue progress circle indicates an active session.
'''
                  .trim(),
              onPressed: onIntro,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.blue.shade100,
            ),
            const SizedBox(width: 16),
            AppButton(
              title: 'Start',
              tooltip: '''
Tap here to begin a session of silence for ${durationInMinutes.round()}
minutes, beginning and ending with three chimes. The blue progress
circle indicates an active session.
'''
                  .trim(),
              onPressed: onStart,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.lightGreenAccent.shade100,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              title: 'Guided',
              tooltip: '''
Tap here to play a ${10 + durationInMinutes.round()} minute guided session.
The session begins with instructions for meditation from John Main.
Introductory music is followed by three chimes and a ${durationInMinutes.round()}
minute silent session which is then finished with another three chimes. The
blue progress circle indicates an active session. The
audio may take a little time to download for the Web version.
'''
                  .trim(),
              onPressed: onGuided,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.purple.shade100,
            ),
            const SizedBox(width: 16),
            AppButton(
              title: isPaused ? 'Resume' : 'Pause',
              tooltip: isPaused
                  ? 'Tap here to Resume the timer and the audio from where they were paused.'
                  : 'Tap here to Pause the timer and the audio. They can be resumed with a press of the Resume button.',
              onPressed: onPauseResume,
            ),
          ],
        ),
      ],
    );
  }
}
