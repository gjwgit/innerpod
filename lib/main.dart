/// Main program for the inner pod session timing and logging.
//
// Time-stamp: <Saturday 2024-05-11 16:25:35 +1000 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

//import 'package:innerpod/constants.dart';
import 'package:innerpod/home.dart';
//import 'package:innerpod/timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Call MaterialApp() here rather than within InnerPod so that
  // MaterialLocalizations is found when firing off the showAboutDialog.

  runApp(
    const MaterialApp(title: 'Inner Pod', home: InnerPod()),
  );
}

/// The primary widget for the app.

class InnerPod extends StatelessWidget {
  /// The primary app widget.

  const InnerPod({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the actual home widget within a SolidLogin. Our app has
    // functionality that does not require access to Pod data (a session
    // timer). If the user connects to their Pod then the session information
    // will be saved. Eventually we will have a Save Session and View History
    // functionality that will then prompt to login to the POD at that time.

    return const SolidLogin(
      title: 'MANAGE YOUR INNER POD',
      required: false,
      image: AssetImage('assets/images/inner_image.jpg'),
      logo: AssetImage('assets/images/inner_icon.png'),
      continueButtonStyle: ContinueButtonStyle(
        text: 'Session',
        background: Colors.lightGreenAccent,
      ),
      infoButtonStyle: InfoButtonStyle(
        tooltip: 'Browse to the InnerPod home page.',
      ),
      // registerButtonStyle: registerButtonStyle(
      //   text: 'REG',
      // ),
      link: 'https://github.com/gjwgit/innerpod/blob/dev/README.md',
      child: Home(),
    );
  }
}
