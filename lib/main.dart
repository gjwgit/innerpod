/// Main program for the inner pod session timing and logging.
//
// Time-stamp: <Thursday 2024-02-01 09:10:22 +1100 Graham Williams>
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

import 'package:solid/solid.dart';

import 'package:innerpod/constants.dart';
import 'package:innerpod/timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(InnerPod());
}

/// The root widget for the app.

class InnerPod extends StatelessWidget {
  /// Initialise the class.

  InnerPod({super.key});

  // Construct the Scaffold as the main window to display after logging in to
  // the Solid Pod.

  final _home = Scaffold(
    backgroundColor: background,
    appBar: AppBar(
      title: const Text('Inner Pod Session Timer'),
      backgroundColor: border,
      foregroundColor: Colors.black,
    ),
    body: Center(
      child: Timer(),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: border,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.text_snippet),
          label: 'Text',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'About',
        ),
      ],
    ),
  );

  // This widget is the root of the application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Pod',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Change the theme for the app here.

        cardTheme: const CardTheme(
          color: border,
        ),
      ),

      // Build the actual home widget. Our app has functionality that does not
      // require access to Pod data (a session timer). If the user does connect
      // to their Pod then the session information will be saved.

      home: SolidLogin(
        // Images generated using Bing Image Creator from Designer, powered by
        // DALL-E3.

        title: 'MANAGE YOUR INNER POD',
        requireLogin: false,
        image: const AssetImage('assets/images/inner_image.jpg'),
        logo: const AssetImage('assets/images/inner_icon.png'),
        continueText: 'SESSION',
        registerText: 'REGISTER',
        link: 'https://github.com/gjwgit/innerpod/blob/main/README.md',
        child: _home,
      ),
    );
  }
}
