/// Log a message to the pod.
//
// Time-stamp: <Wednesday 2024-06-26 12:31:34 +1000 Graham Williams>
//
/// Copyright (C) 2024, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams

library;

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

/// Log the [msg] to the user's Solid Pod.

void logMessage(String msg) {
  final ts = DateTime.now();
  debugPrint('LOG TO POD: ${DateFormat("yMMddTHHmmss").format(ts)} $msg');
}
