// A countdown timer and buttons for a session.
//
// Time-stamp: <Saturday 2026-02-21 00:49:00 +1100 Graham Williams>
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/widgets/app_circular_countdown_timer.dart';
import 'package:innerpod/widgets/duration_selector.dart';
import 'package:innerpod/widgets/premium_text_field.dart';
import 'package:innerpod/widgets/timer_buttons.dart';
import 'package:innerpod/widgets/timer_logic.dart';

const defaultSessionSeconds = 20 * 60;

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  TimerState createState() => TimerState();
}

class TimerState extends State<Timer> with TimerStateLogic<Timer> {
  @override
  void allowSleep() => WakelockPlus.disable();

  @override
  void stopSleep() => WakelockPlus.enable();

  @override
  void initState() {
    player = AudioPlayer();
    controller = CountDownController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        duration = prefs.getInt('duration') ?? defaultSessionSeconds;
      });
    }
  }

  @override
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('duration', duration);
  }

  @override
  void dispose() {
    player.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerDisplay = AppCircularCountDownTimer(
      duration: duration,
      controller: controller,
      onComplete: onTimerComplete,
    );

    final buttonsMatrix = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerButtons(
            onStart: () {
              resetTimer();
              dingDong(player);
              stopSleep();
              sessionType = 'bell';
              startTime = DateTime.now();
              controller.restart(duration: duration);
              setState(() {});
            },
            onPauseResume: () {
              setState(() {
                if (isPaused) {
                  controller.resume();
                  player.resume();
                  stopSleep();
                  isPaused = false;
                } else {
                  controller.pause();
                  player.pause();
                  allowSleep();
                  isPaused = true;
                }
              });
            },
            onIntro: startIntro,
            onGuided: startGuided,
            isPaused: isPaused,
            durationInMinutes: duration / 60,
          ),
          const SizedBox(height: 40),
          Text(
            'SELECT DURATION',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          DurationSelector(
            currentDuration: duration,
            onDurationSelected: (newDuration) {
              setState(() {
                duration = newDuration;
                controller.restart(duration: duration);
                controller.pause();
                player.stop();
                allowSleep();
              });
              saveSettings();
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                PremiumTextField(
                  controller: titleController,
                  labelText: 'TITLE',
                  hintText: 'Keep it meaningful...',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: descriptionController,
                  labelText: 'DESCRIPTION',
                  hintText: 'Share your thoughts...',
                  icon: Icons.notes,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  timerDisplay,
                  const SizedBox(height: 60),
                  buttonsMatrix,
                ],
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: timerDisplay)),
                  const SizedBox(width: 40),
                  Expanded(child: Center(child: buttonsMatrix)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
