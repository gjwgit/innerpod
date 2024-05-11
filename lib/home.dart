/// Main home page for the app.
//
// Time-stamp: <Saturday 2024-05-11 19:26:26 +1000 Graham Williams>
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

import 'package:innerpod/constants.dart';
import 'package:innerpod/instructions.dart';
import 'package:innerpod/timer.dart';

/// A widget for the actuall app's main home page.

class Home extends StatefulWidget {
  /// Initialise widget variables

  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

///

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  // Track which item is selected in the nav bar.

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = <Widget>[
    Timer(),
    instructions,
    // const Icon(Icons.camera, size: 150),
    const Icon(Icons.chat, size: 150),
  ];

  @override
  Widget build(BuildContext context) {
    // final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Inner Pod'),
        backgroundColor: border,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () async {
              final appNameVersion = await getAppNameVersion();

              // Note the use of the conditional with `context.mounted` to avoid
              // the "Don't use 'BuildContext's across async gaps" warning.

              if (context.mounted) {
                showAboutDialog(
                  context: context,

                  // Note the `.toString()` is used to avoid the warning about
                  // "The argument type 'dynamic' can't be assigned to the
                  // parameter type 'String'"

                  applicationName: appNameVersion.name,
                  applicationVersion: appNameVersion.version,
                  applicationIcon: const ImageIcon(
                      AssetImage('assets/images/inner_icon.png')),
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
                        'The concept for the app and images were generated by'
                        ' large language models.\n\n'
                        ' Authors: Graham Williams.'),
                  ],
                );
              }
            },
            tooltip: 'Popup a window about the app.',
          ),
        ],
      ),
      body: Center(child: _pages.elementAt(_selectedIndex)), //Timer()),
      // 20240311 TODO gjw Remove for now for initial release.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: border,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), //, color: Colors.black),
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
