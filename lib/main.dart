/// Main program for the inner pod session timing and logging.
//
// Time-stamp: <Monday 2024-07-08 13:29:54 +1000 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
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

import 'package:innerpod/home.dart';
import 'package:innerpod/constants/colours.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:innerpod/timer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  themeNotifier.themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const InnerPodApp());
}

class InnerPodApp extends StatelessWidget {
  const InnerPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Inner Pod',
          themeMode: themeNotifier.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF0D1AD),
              surface: const Color(0xFFFDF7F0),
              primary: const Color(0xFF8B5E3C),
              onPrimary: Colors.white,
              secondary: const Color(0xFFE6B276),
              surfaceContainerHighest: const Color(0xFFF5E0C8),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: TextStyle(
                color: Color(0xFF5D4037),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFFFDF7F0),
              indicatorColor: const Color(0xFFE6B276).withValues(alpha: 0.5),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white.withValues(alpha: 0.9),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B5E3C),
              brightness: Brightness.dark,
              surface: const Color(0xFF1A1A1A),
              primary: const Color(0xFFE6B276),
              onPrimary: Colors.black,
              secondary: const Color(0xFF8B5E3C),
              surfaceContainerHighest: const Color(0xFF2C2C2C),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: TextStyle(
                color: Color(0xFFE6B276),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Color(0xFFE6B276)),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF1A1A1A),
              indicatorColor: const Color(0xFF8B5E3C).withValues(alpha: 0.5),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.grey[900]?.withValues(alpha: 0.9),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          home: const InnerPod(),
        );
      },
    );
  }
}
