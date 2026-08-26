/// The bells available for the beginning and end of a session.
///
// Time-stamp: <2026-08-27>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:innerpod/models/bell.dart';

/// Every bell sounds three strikes over the same 27 seconds, so the choice
/// changes only the tone and never the timing of a session.

const List<Bell> bells = [
  Bell(
    id: 'temple',
    label: 'Temple',
    description: 'A large temple bell, deep and slow to fade.',
    asset: 'sounds/bell_temple.mp3',
  ),
  Bell(
    id: 'bowl',
    label: 'Singing Bowl',
    description: 'Deep, with a brighter ring above it.',
    asset: 'sounds/bell_bowl.mp3',
  ),
  Bell(
    id: 'deep',
    label: 'Deep',
    description: 'The lowest and softest of the bells.',
    asset: 'sounds/bell_deep.mp3',
  ),
  Bell(
    id: 'original',
    label: 'Original',
    description: 'The original Inner Pod bell, bright and clear.',
    asset: 'sounds/bell_original.mp3',
  ),
];

/// The bell sounded until the user chooses one.

const String defaultBellId = 'temple';

/// The bell known by [id], falling back to the default for a missing or
/// unrecognised value so a stale preference can never leave the app silent.

Bell bellById(String? id) => bells.firstWhere(
      (bell) => bell.id == id,
      orElse: () => bells.firstWhere((bell) => bell.id == defaultBellId),
    );
