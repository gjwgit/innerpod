// A premium stylized text field.
//
// Time-stamp: <Friday 2026-02-27 05:29:38 +1100 Graham Williams>
//
// Copyright (C) 2024-2026, Togaware Pty Ltd
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://opensource.org/license/gpl-3-0
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.

library;

import 'package:flutter/material.dart';

/// A styled text field used across the app for standardized inputs.

class PremiumTextField extends StatelessWidget {
  /// The controller for the text field.
  final TextEditingController controller;

  /// The label text of the text field.
  final String labelText;

  /// The hint text of the text field.
  final String hintText;

  /// The prefix icon of the text field.
  final IconData icon;

  /// The max lines the text field should display.
  final int maxLines;

  /// Constructor
  const PremiumTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
      ),
      maxLines: maxLines,
    );
  }
}
