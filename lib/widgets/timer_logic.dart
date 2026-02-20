// Logic for managing timer sessions and interactions with the Solid Pod.
//
// Time-stamp: <Saturday 2026-02-21 01:14:00 +1100 Graham Williams>
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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/constants/audio.dart';
import 'package:innerpod/utils/ding_dong.dart';
import 'package:innerpod/utils/log_message.dart';
import 'package:innerpod/utils/session_logic.dart';

mixin TimerStateLogic<T extends StatefulWidget> on State<T> {
  // These will be provided by the state class
  late AudioPlayer player;
  late CountDownController controller;
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  bool isGuided = false;
  bool isPaused = false;
  String sessionType = 'bell';
  DateTime? startTime;
  int duration = 1200;

  void allowSleep();
  void stopSleep();
  Future<void> saveSettings();

  Future<void> playAudio(Source source, {double volume = 1.0}) async {
    if (!mounted) return;
    try {
      await player.stop();
      await player.setVolume(volume);
      await player.play(source);
      await player.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Audio playback error or interrupted: $e');
    }
  }

  void resetTimer() {
    player.stop();
    controller.restart(duration: duration);
    controller.pause();
    isGuided = false;
    isPaused = false;
  }

  Future<void> startIntro() async {
    logMessage('Start Intro Session');
    if (!mounted) return;
    resetTimer();
    stopSleep();
    isGuided = false;
    sessionType = 'intro';
    startTime = DateTime.now();

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await playAudio(introAudio);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    dingDong(player);
    controller.restart(duration: duration);
    if (mounted) setState(() {});
  }

  Future<void> startGuided() async {
    logMessage('Start Guided Session');
    if (!mounted) return;
    resetTimer();
    stopSleep();
    isGuided = true;
    sessionType = 'guided';
    startTime = DateTime.now();

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await playAudio(sessionGuide);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    dingDong(player);
    controller.restart(duration: duration);
    if (mounted) setState(() {});
  }

  Future<void> onTimerComplete() async {
    logMessage('Session Completed');
    if (mounted) {
      await playAudio(dong, volume: bellVolume);
    }

    if (mounted && isGuided) {
      await player.release();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        try {
          await player.setVolume(1.0);
          await player.play(sessionOutro);
          await player.onPlayerComplete.first;
        } catch (e) {
          debugPrint('Audio playback error (final outro): $e');
        }
      }
    }

    if (mounted) {
      resetTimer();
      allowSleep();
      setState(() {});
    }
    await saveSessionToPod();
  }

  Future<void> saveSessionToPod() async {
    if (startTime == null) return;

    final endTime = DateTime.now();
    final session = {
      'start': startTime!.toIso8601String(),
      'end': endTime.toIso8601String(),
      'type': sessionType,
      'silenceDuration': duration,
      'title': titleController.text,
      'description': descriptionController.text,
    };

    try {
      String? content;
      try {
        content = await readPod('sessions.ttl');
      } on ResourceNotExistException {
        content = null;
      }

      String newContent = addSession(content, session);
      await writePod('sessions.ttl', newContent, overwrite: true);
      logMessage('Session saved to Pod');

      startTime = null;
      titleController.clear();
      descriptionController.clear();
      if (mounted) setState(() {});
    } on SecurityKeyNotAvailableException {
      if (mounted) {
        await getKeyFromUserIfRequired(context, widget);
        if (mounted) await saveSessionToPod();
      }
    } catch (e) {
      logMessage('Error saving session to Pod: $e');
      startTime = null;
      titleController.clear();
      descriptionController.clear();
      if (mounted) setState(() {});
    }
  }
}
