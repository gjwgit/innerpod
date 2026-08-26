/// Tests for the selectable session bells.
///
// Time-stamp: <2026-08-27>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:innerpod/constants/bells.dart';

void main() {
  group('bellById', () {
    test('returns the bell with the given id', () {
      expect(bellById('bowl').label, 'Singing Bowl');
      expect(bellById('original').asset, 'sounds/bell_original.mp3');
    });

    test('falls back to the default for null or unknown ids', () {
      // A missing preference, or one written by a later version of the app,
      // must still sound a bell rather than leaving the session silent.

      expect(bellById(null).id, defaultBellId);
      expect(bellById('no-such-bell').id, defaultBellId);
    });
  });

  group('bells', () {
    test('the default is one of them', () {
      expect(bells.map((bell) => bell.id), contains(defaultBellId));
    });

    test('ids are unique', () {
      expect(bells.map((bell) => bell.id).toSet(), hasLength(bells.length));
    });

    test('every audio file exists and is declared in the pubspec', () {
      // Guards the easily missed second step of adding a bell: dropping the
      // mp3 in place but forgetting to list it under `flutter: assets:`.

      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final bell in bells) {
        final path = 'assets/${bell.asset}';
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
        expect(pubspec, contains('- $path'), reason: '$path not in pubspec');
      }
    });
  });
}
