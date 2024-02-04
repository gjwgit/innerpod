/// Main program for the inner pod session timing and logging.
//
// Time-stamp: <Sunday 2024-02-04 11:25:34 +1100 Graham Williams>
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

// import 'package:solidpod/solid.dart';

import 'package:innerpod/constants.dart';
import 'package:innerpod/timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Call MaterialApp() here rather than within InnerPod so that
  // MaterialLocalizations is found when firing off the showAboutDialog.

  runApp(
    const MaterialApp(
        title: 'Inner Pod',
        debugShowCheckedModeBanner: false,
        home: InnerPod()),
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
    // timer). If the user does connect to their Pod then the session
    // information will be saved. Eventually we will have a Save Session and
    // View History functionality that will then prompt to login to the POD at
    // that time.

    // TODO 20240204 gjw NOT USING SolidLogin() FOR NOW.

    // return const SolidLogin(
    //   title: 'MANAGE YOUR INNER POD',
    //   requireLogin: false,
    //   image: AssetImage('assets/images/inner_image.jpg'),
    //   logo: AssetImage('assets/images/inner_icon.png'),
    //   continueText: 'SESSION',
    //   registerText: 'REGISTER',
    //   link: 'https://github.com/gjwgit/innerpod/blob/main/README.md',
    //   child: _InnerPodScaffold(),
    // );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Inner Pod Session Timer'),
        backgroundColor: border,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Inner Pod',
                applicationVersion: '0.0.0',
                applicationIcon:
                    const ImageIcon(AssetImage('assets/images/inner_icon.png')),
                children: [
                  const SelectableText('A session timer with logging.\n\n'
                      'Inner Pod is an app for timing sessions and storing'
                      ' sessions to your Pod. A session can be anything though'
                      ' the app is commonly used for contemplative'
                      ' meditation.\n\n'
                      'The app is written in Flutter and the open source code'
                      ' is available from github at'
                      ' https://github.com/gjwgit/innerpod.'
                      ' You can try it out online at'
                      ' https://innerpod.solidcommunity.au.\n\n'
                      ' Authors: Graham Williams.'),
                ],
              );
            },
            tooltip: 'Popup a window about the app.',
          ),
        ],
      ),
      body: Center(child: Timer()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: border,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet),
            label: 'Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
