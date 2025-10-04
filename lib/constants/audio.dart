/// Aduio related constants used across the app.
//
// Time-stamp: <Wednesday 2025-09-03 13:35:40 +1000 Graham Williams>
//
/// Copyright (C) 2024, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
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
/// Authors: Graham Williams

library;

import 'package:audioplayers/audioplayers.dart';

// Identify the sounds to be played at various stages within the app, like the
// beginning and end of a session dongs, the INTRO spoken introductiona nd the
// GUIDED spoken and musical pieces for the guided meditation. These are
// [AssetSource] objects from the audioplayers package, loaded fromt eh `assets`
// folder.

/// The dong usually consists of three dings.

final dong = AssetSource('sounds/dong.mp3');

/// The INTRO audio is often a short introductory prayer to begin the session.

final introAudio = AssetSource('sounds/intro.mp3');

/// The GUIDED audio is currently, as of 20240626, the full 30 minute JM
/// meditation session.

final sessionGuide = AssetSource('sounds/session_guide.mp3');

///

final sessionOutro = AssetSource('sounds/session_outro.mp3');
