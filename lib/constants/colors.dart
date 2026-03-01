/// Color constants used throughout the app.
//
// Time-stamp: <Sunday 2026-03-01 20:55:00 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
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

// ----------------------------------------------------------------------
// Theme Colors (typically for ColorScheme)
// ----------------------------------------------------------------------

/// The seed color used to generate the app's color scheme.
const seed = Color(0xFF8B5E3C);

/// The default background color for surfaces.
const surface = Color(0xFFFDFBF9);

/// The primary color used for key components.
const primary = Color(0xFF8B5E3C);

/// The secondary color for accents and highlights.
const secondary = Color(0xFFE6B276);

/// The tertiary color for additional branding elements.
const tertiary = Color(0xFFAD8B73);

/// A surface container color for high-contrast elements.
const surfaceContainerHighest = Color(0xFFF5EADA);

// ----------------------------------------------------------------------
// Functional Colors
// ----------------------------------------------------------------------

/// The background color of the main widget of the app.
const background = Color(0xFFF0D1AD);

/// A lighter color for borders and some background elements.
const border = Color(0xFFF5E0C8);

/// The standard text color (dark brown).
const text = Color(0xFF2D1B0E);

/// A lighter text color for secondary information.
const textSecondary = Color(0xFF4A3427);

/// A color specifically for button primary text or accents.
const accentBrown = Color(0xFF5D4037);

// ----------------------------------------------------------------------
// Specific Widget Colors
// ----------------------------------------------------------------------

/// The background color for the Start button.
const startButtonBackground = Color(0xFFF1FBE9); // lightGreenAccent.shade100

/// The background color for the Intro button.
const introButtonBackground = Color(0xFFE3F2FD); // blue.shade100

/// The background color for the Guided button.
const guidedButtonBackground = Color(0xFFF3E5F5); // purple.shade100

/// The color for selected duration chips.
const accentGreen = Colors.lightGreenAccent;

/// The color for the timer's active fill.
const timerFill = Colors.blueAccent;

/// The color for error or delete actions.
const error = Colors.redAccent;

// ----------------------------------------------------------------------
// Base Colors
// ----------------------------------------------------------------------

/// Pure white.
const white = Colors.white;

/// Pure black.
const black = Colors.black;

/// Transparent.
const transparent = Colors.transparent;

/// Standard grey.
const grey = Colors.grey;

/// A medium-dark grey (Colors.grey[600]).
const grey600 = Color(0xFF757575);

/// A medium grey (Colors.grey[500]).
const grey500 = Color(0xFF9E9E9E);

/// A dark grey (Colors.grey.shade700).
const grey700 = Color(0xFF616161);
