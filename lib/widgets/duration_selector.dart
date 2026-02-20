// A widget for selecting session duration using choice chips.
//
// Time-stamp: <Saturday 2026-02-21 01:19:00 +1100 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
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
/// Authors: Amogh Hosamane

library;

import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final int currentDuration;
  final Function(int) onDurationSelected;

  const DurationSelector({
    required this.currentDuration,
    required this.onDurationSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [5, 10, 15, 20, 25, 30].map((number) {
        final durationInSeconds = number * 60;
        return ChoiceChip(
          label: Text(number.toString()),
          selected: currentDuration == durationInSeconds,
          selectedColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          showCheckmark: false,
          onSelected: (selected) {
            if (selected) {
              onDurationSelected(durationInSeconds);
            }
          },
        );
      }).toList(),
    );
  }
}
