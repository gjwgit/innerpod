/// The default nutton style for the app.
///
/// Copyright (C) 2024-2026, Togaware Pty Ltd.
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
    this.textColor,
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

  /// The colour of the label text.

  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF2C1E12) : Colors.white;
    final resolvedBackgroundColor =
        backgroundColor == Colors.white ? defaultBg : backgroundColor;
    bool isPrimary = resolvedBackgroundColor != defaultBg;

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
                    resolvedBackgroundColor,
                    Color.lerp(resolvedBackgroundColor,
                        isDark ? Colors.white : Colors.black, 0.05,)!,
                  ]
                : [
                    resolvedBackgroundColor,
                    isDark ? const Color(0xFF1A120B) : const Color(0xFFFDF7F0),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? resolvedBackgroundColor.withValues(alpha: 0.3)
                  : (isDark
                      ? Colors.black45
                      : Colors.grey.withValues(alpha: 0.1)),
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
                    color: textColor ??
                        (isPrimary
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF5D4037))),
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
