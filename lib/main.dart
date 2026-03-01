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

import 'package:innerpod/constants/colors.dart' as colours;
import 'package:innerpod/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Inner Pod',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colours.seed,
          surface: colours.surface,
          primary: colours.primary,
          secondary: colours.secondary,
          tertiary: colours.tertiary,
          surfaceContainerHighest: colours.surfaceContainerHighest,
        ),
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          displayLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.5,
            color: colours.text,
          ),
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: -0.2,
            color: colours.text,
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 17,
            letterSpacing: -0.1,
            height: 1.5,
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: colours.transparent,
          elevation: 0,
          scrolledUnderElevation: 4,
          titleTextStyle: GoogleFonts.outfit(
            color: colours.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colours.white.withValues(alpha: 0.8),
          indicatorColor: colours.primary.withValues(alpha: 0.1),
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colours.primary,
              );
            }
            return GoogleFonts.outfit(
              fontSize: 12,
              color: colours.grey600,
            );
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: colours.black.withValues(alpha: 0.05)),
          ),
          color: colours.white,
        ),
        chipTheme: ChipThemeData(
          shape: const StadiumBorder(),
          backgroundColor: colours.white,
          selectedColor: colours.primary,
          secondarySelectedColor: colours.surface,
          labelStyle: GoogleFonts.outfit(fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: const BorderSide(color: colours.border),
        ),
      ),
      home: const InnerPod(),
    ),
  );
}
