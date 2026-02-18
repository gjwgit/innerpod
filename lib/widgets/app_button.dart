/// The default nutton style for the app.
///
/// Copyright (C) 2024, Togaware Pty Ltd.
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

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

  final VoidCallback onPressed;

  /// The button's background colour.

  final Color backgroundColor;

  /// Override the default text font size.

  final double fontSize;

  /// Override the default text wight.

  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    bool isPrimary = backgroundColor != Colors.white;

    return SizedBox(
      height: 52,
      width: 170,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPrimary
                ? [
                    backgroundColor,
                    Color.lerp(backgroundColor, Colors.black, 0.05)!,
                  ]
                : [
                    Colors.white,
                    const Color(0xFFFDF7F0),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? backgroundColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(
              child: MarkdownTooltip(
                message: tooltip,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isPrimary ? FontWeight.bold : fontWeight,
                    color: isPrimary
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                        : const Color(0xFF5D4037),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
