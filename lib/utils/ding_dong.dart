/// Play the ding dong audio file.
//
// Time-stamp: <Wednesday 2024-06-26 12:21:59 +1000 Graham Williams>
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
/// Authors: AUTHORS

library;

import 'package:innerpod/constants/audio.dart';

/// Encapsulate the playing of the dong into its own function because of the
/// need for it to be async through the await and it is called upon multiple
/// times.

Future<void> dingDong(player) async {
  // Always stop the player first in case there is some other audio still
  // playing.
  await player.stop();
  await player.play(dong);
}
