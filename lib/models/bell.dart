/// Bell — one of the session bells the user can choose between.
///
// Time-stamp: <2026-08-27>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

/// A selectable bell, sounded at the start and end of a session.

class Bell {
  /// Create a bell with its identifier, presentation text and asset.

  const Bell({
    required this.id,
    required this.label,
    required this.description,
    required this.asset,
  });

  /// Stable identifier saved in SharedPreferences. Never change these once
  /// released or a user's chosen bell silently reverts to the default.

  final String id;

  /// Short name shown against the radio button in the chooser.

  final String label;

  /// One line on how the bell sounds, shown under the label.

  final String description;

  /// Path passed to [AssetSource], so relative to `assets/`.

  final String asset;
}
