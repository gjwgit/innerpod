/// A delayed tooltip to avoid clutter of tooltips.
///
/// Copyright (C) 2023, Togaware Pty Ltd.
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

/// A [Tooltip] that is delayed before being displayed.

class DelayedTooltip extends StatelessWidget {
  /// Idetntify the required parameters.

  const DelayedTooltip({
    required this.child,
    required this.message,
    super.key,
    this.wait = const Duration(seconds: 1),
  });

  /// The widget to be displayed as the tooltip.

  final Widget child;

  /// the message to be displayed.

  final String message;

  /// How long to delay before displayiung the tooltip.

  final Duration wait;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      waitDuration: wait,
      child: child,
    );
  }
}
