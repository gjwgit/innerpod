/// BellPrefs — which bell this device sounds for a session.
///
/// The chosen bell is a device preference, like the theme, and so is kept
/// only in SharedPreferences and never written to the Pod.
///
// Time-stamp: <2026-08-27>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:innerpod/constants/bells.dart';
import 'package:innerpod/models/bell.dart';

/// The device-local choice of session bell.

class BellPrefs {
  BellPrefs._();

  /// SharedPreferences key holding the chosen bell's id.

  static const String _key = 'innerpod_bell';

  /// The chosen bell, or the default when nothing has been saved yet.

  static Future<Bell> selected() async {
    final prefs = await SharedPreferences.getInstance();

    return bellById(prefs.getString(_key));
  }

  /// Remember [bell] as this device's choice.

  static Future<void> select(Bell bell) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, bell.id);
  }
}
