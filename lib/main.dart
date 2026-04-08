/// Main program for the inner pod session timing and logging.
//
// Time-stamp: <Thursday 2026-02-26 09:40:21 +1100 Graham Williams>
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

import 'package:google_fonts/google_fonts.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SolidSecurityKeyCentralManager.instance;

  runApp(const InnerPodApp());
}

class InnerPodApp extends StatefulWidget {
  const InnerPodApp({super.key});
  @override
  State<InnerPodApp> createState() => _InnerPodAppState();
}

class _InnerPodAppState extends State<InnerPodApp> {
  final _themeNotifier = SolidThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.initialize();
    _themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Pod',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: _themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      home: InnerPod(themeNotifier: _themeNotifier),
    );
  }
}

ThemeData _lightTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B5E3C),
        surface: const Color(0xFFFDFBF9),
        primary: const Color(0xFF8B5E3C),
        secondary: const Color(0xFFE6B276),
        tertiary: const Color(0xFFAD8B73),
        surfaceContainerHighest: const Color(0xFFF5EADA),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 32,
          letterSpacing: -0.5,
          color: const Color(0xFF2D1B0E),
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.2,
          color: const Color(0xFF2D1B0E),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          letterSpacing: -0.1,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 4,
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFF2D1B0E),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        indicatorColor: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B5E3C),
            );
          }
          return GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        color: Colors.white,
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF8B5E3C),
        secondarySelectedColor: const Color(0xFFFDFBF9),
        labelStyle: GoogleFonts.outfit(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    );

ThemeData _darkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B5E3C),
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1412),
        primary: const Color(0xFFD4A574),
        secondary: const Color(0xFFE6B276),
        tertiary: const Color(0xFFCAAE94),
        surfaceContainerHighest: const Color(0xFF2D2420),
      ),
      textTheme:
          GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 32,
          letterSpacing: -0.5,
          color: const Color(0xFFF5E6D8),
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.2,
          color: const Color(0xFFF5E6D8),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          letterSpacing: -0.1,
          height: 1.5,
          color: const Color(0xFFE0D0C0),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 4,
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFFF5E6D8),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        color: const Color(0xFF2D2420),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: const Color(0xFF2D2420),
        selectedColor: const Color(0xFFD4A574),
        labelStyle: GoogleFonts.outfit(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
