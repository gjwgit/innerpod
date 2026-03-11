/// Color constants used throughout the app.
//
// Time-stamp: <Sunday 2026-03-01 05:59:30 +1100 Graham Williams>
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

const appBackgroundColor = Colors.white;
const appButtonColor = Colors.transparent;
final appShadowColor = Colors.black.withValues(alpha: 0.05);

/// The background colour of the main widget of the app.
//
// const background = Color(0xFFE6B276);
// const background = Color(0xFFF5E0C8);
// const background = Color(0xFFF0D1AD);
//
// 20260220 gjw The background to be used for active components of the app, like
// the timer's central area and the box containing the buttons. Though it is not
// currently used. We need to review the colour literals used across the app and
// move them here for ease of maintenance and reducing trechnical debt.
//
// const background = Color(0xFFF0D1AD);

/// A lighter colour for the top and bottom (navbar) elements of the app.
//
// const border = Color(0xFFF5E0C8);
//

/// Colour of the spin bar when it is active
//
// 20260227 gjw Define the colour to be used for the active countdown timer spin
// bar. Exploring colour options that are dark enough to be visible and contrast
// in low light leads to the choice here. The original blueAccent is out of
// place for the new colour scheme. Other colours tried include:
//
// Color(0xFFF0D1AD); Too light.
// Color(0xFFD0A97D);
// Color(0xFFCEAF85);
// Color(0xFFC0895D); This is a little more golden than 0xFFB08261.
// Color(0xFFB08261); A bit flat in colour compared to 0xFFC0895D.
// Colors.blueAccent.shade700; Out of place for the colour scheme.

const spinColor = Color(0xFFC0895D);

const spinBackgroundColor = Colors.white;

const timerCentralColor = Color(0xFFFDFBF9);

/// Colour for the digits displayed within the timer.

const timerTextColor = Colors.black;

/// Background colors for the 4 function buttons.

final guidedBackgroundColor = Colors.purple.shade100;
final introBackgroundColor = Colors.blue.shade100;
final pauseBackgroundColor = Colors.grey[200] ?? Colors.grey;
final startBackgroundColor = Colors.lightGreenAccent.shade100;

/// Background colour of the integer duration buttons.

final durationBackgroundColor = Colors.lightGreenAccent;

/// Colour of the text for the integer duration buttons.

final durationTextColor = Colors.grey[600];

/// Colour for the background of the funcation area.
///
/// This is the area where the function and duration buttons are.
//
// 20260220 gjw Choosing a darker background for the active button area
// distringuishes it from the above timer display to more clearly distinguish
// the buttons matrix from the app background. Another option is to have the
// same background as the title bar and timer central. The white with alpha 1.0
// gives it the same as the time white. Could probably use the same color for
// both.

final functionsBackgroundColor = Colors.white;

const instructionsBarColor = Colors.transparent;
const instructionsUnselectedColor = Colors.grey;

<<<<<<< feature/delete-all-history-65
const border = Color(0xFFF5E0C8);

/// A color for error messages or destructive actions.
const error = Colors.redAccent;
=======
final historyIncidentalColor = Colors.grey[600];
const historyDeleteColor = Colors.redAccent;
final historyNoneColor = Colors.grey.withValues(alpha: 0.5);
>>>>>>> dev
