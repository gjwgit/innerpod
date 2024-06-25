/// The default nutton style for the app.
///
/// Copyright (C) 2024, Togaware Pty Ltd.
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:innerpod/widgets/delayed_tooltip.dart';

/// An [ElevatedButton] with defaults for the app.

class AppButton extends StatelessWidget {
  /// Idetntify the required parameters.

  const AppButton({
    required this.title,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.backgroundColor = Colors.white,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
  });

  /// The text to be displayed on the button.

  final String title;

  /// The required tooltip for the button. I require every button to have a
  /// tooltip.

  final String tooltip;

  /// The action to undertake on a button tap.

  final VoidCallback? onPressed;

  /// The button's background colour.

  final Color backgroundColor;

  /// Override the default text font size.

  final double fontSize;

  /// Override the default text wight.

  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 170,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          //   textStyle: _buttonTextStyleBold,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: () {
          //   _isGuided = false;
          //   _dingDong();
          //   _controller.restart();
          //   WakelockPlus.enable();
          //   _logit('Start Session');
        },
        child: DelayedTooltip(
          message: tooltip,
          //'Tap here to begin a session of silence for '
          // '${(_duration / 60).round()} minutes,\n'
          //    'beginning and ending with three dings.',
          child: Text(title),
        ),
      ),
    );
  }
}

//           child: ElevatedButton(
//             style: TextButton.styleFrom(
//               textStyle: _buttonTextStyleBold,
//               backgroundColor: Colors.lightGreenAccent,
//             ),
//             onPressed: () {
//               _isGuided = false;
//               _dingDong();
//               _controller.restart();
//               WakelockPlus.enable();
//               _logit('Start Session');
//             },
//             child: DelayedTooltip(
//               message: 'Tap here to begin a session of silence for '
//               '${(_duration / 60).round()} minutes,\n'
//               'beginning and ending with three dings.',
//               child: Text(title),
//             ),
//           ),
//         );
//     }
//     }
