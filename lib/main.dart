/// Main program for the inner pod app.
//
// Time-stamp: <Tuesday 2024-01-23 12:39:47 +1100 Graham Williams>
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

// import 'package:solid/solid.dart';

import 'package:innerpod/timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(InnerPod());
}

class InnerPod extends StatelessWidget {
  InnerPod({super.key});

  // Construct the Scaffold as the main window to display after logging in to
  // the Solid Pod.

  final home = Scaffold(
    backgroundColor: Colors.blueGrey.shade700,
    appBar: AppBar(
      title: const Text('Inner Pod Meditation Timer'),
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Timer(),
    ),
  );

  // This widget is the root of the application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Pod',
      color: Colors.purple,

      // Build the actual home widget. Because our app requires access to the
      // data stored within the user's POD for any of its functionality, we wrap

      home: home,
      // home: const SolidLogin(
      //   // Images generated using Bing Image Creator from Designer, powered by
      //   // DALL-E3.

      //   image: AssetImage('assets/images/inner_image.jpg'),
      //   logo: AssetImage('assets/icon/icon.png'),
      //   title: 'MANAGE YOUR INNER POD',
      //   link: 'https://github.com/gjwgit/inner',
      //   child: home,
      // ),
    );
  }
}
