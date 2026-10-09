/// Driver for the store screenshot run — writes each capture to disk.
///
// Time-stamp: <Saturday 2026-10-10 10:00:00 +1100 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
/// Authors: Graham Williams

library;

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// 20261010 gjw Runs on the HOST, not the device. Ported from radiopod.
///
/// `binding.takeScreenshot()` in the test hands the PNG bytes back over the
/// driver extension, and this writes them where the workflow can upload
/// them.
///
/// SCREENSHOT_DIR gives each device its own folder; it defaults to a plain
/// `screenshots/` for a run by hand. SCREENSHOT_PREFIX names the files the
/// way assets/screenshots already does — innerpod_android_history.png — so
/// a fresh set can be copied straight over the hand-taken ones. The test
/// supplies only the screen, since it cannot tell which device it is on.

Future<void> main() async {
  final env = Platform.environment;
  final dir = env['SCREENSHOT_DIR'] ?? 'screenshots';
  final prefix = env['SCREENSHOT_PREFIX'] ?? 'innerpod';

  await integrationDriver(
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? args]) async {
      final file = File('$dir/${prefix}_$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      stdout.writeln('wrote ${file.path} (${bytes.length} bytes)');

      // Returning false fails the test. This only stores the image, it
      // compares against nothing, so it always succeeds.

      return true;
    },
  );
}
