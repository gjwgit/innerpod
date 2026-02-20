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

import 'package:google_fonts/google_fonts.dart';

import 'package:innerpod/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Inner Pod',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
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
            color: const Color(0xFF4A3427),
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
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8B5E3C),
              );
            }
            return GoogleFonts.outfit(
                fontSize: 12, color: Colors.grey.shade600);
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
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFE6B276),
          surface: const Color(0xFF121212),
          primary: const Color(0xFFE6B276),
          secondary: const Color(0xFF8B5E3C),
          surfaceContainerHighest: const Color(0xFF1E1E1E),
        ),
        textTheme:
            GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.5,
            color: const Color(0xFFFDFBF9),
          ),
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: -0.2,
            color: const Color(0xFFFDFBF9),
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 17,
            letterSpacing: -0.1,
            height: 1.5,
            color: const Color(0xFFE0D7D0),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 4,
          titleTextStyle: GoogleFonts.outfit(
            color: const Color(0xFFFDFBF9),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
          indicatorColor: const Color(0xFFE6B276).withValues(alpha: 0.2),
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE6B276),
              );
            }
            return GoogleFonts.outfit(
                fontSize: 12, color: Colors.grey.shade500);
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          color: const Color(0xFF1E1E1E),
        ),
      ),
      home: const InnerPod(),
    ),
  );
}
