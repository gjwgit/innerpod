/// Main home page for the app.
//
// Time-stamp: <Tuesday 2024-07-09 17:27:02 +1000 Graham Williams>
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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidpod/solidpod.dart';

import 'package:innerpod/constants/colours.dart';
import 'package:innerpod/widgets/instructions.dart';
import 'package:innerpod/widgets/timer.dart';

/// A widget for the actuall app's main home page.

class Home extends StatefulWidget {
  /// Constructor for the home screen.

  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

///

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // We will populate the app version shortly.

  var _appVersion = 'Unknown';

  // Helper function to load the app name and version.

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version; // Set app version from package info
    });
  }

  @override
  void initState() {
    super.initState();

    // Get the app name and version.

    _loadAppInfo();
  }

  // Track which item is selected in the nav bar.

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = <Widget>[
    const Timer(),
    const Instructions(),
    const Icon(Icons.chat, size: 150),
  ];

  @override
  Widget build(BuildContext context) {
    // final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/inner_icon.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 20),
            const Text('Inner Pod'),
          ],
        ),
        backgroundColor: border,
        actions: [
          Text('Version $_appVersion', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 50),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () async {
              final appInfo = await getAppNameVersion();
              final appName = appInfo.name;

              // Note the use of the conditional with `context.mounted` to avoid
              // the "Don't use 'BuildContext's across async gaps" warning.

              if (context.mounted) {
                showAboutDialog(
                  context: context,
                  applicationIcon: Image.asset(
                    'assets/images/inner_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  applicationName:
                      '${appName[0].toUpperCase()}${appName.substring(1)}',
                  applicationVersion: appInfo.version,
                  applicationLegalese: '© 2024 Togaware',
                  children: [
                    const SizedBox(
                      width: 300, // Limit the width of the about dialog.
                      child: SelectableText(
                          '\nA meditation timer and session log.\n\n'
                          'Inner Pod is an app for timing meditation sessions and, '
                          'optionally, storing a log of your meditation'
                          ' sessions to your Pod. A session, in fact, can be anything.'
                          ' The app is commonly used for contemplative or silent'
                          ' meditation as is the tradition in many cultures and religions.\n\n'
                          'The app is written in Flutter and the open source code'
                          ' is available from github at'
                          ' https://github.com/gjwgit/innerpod.'
                          ' You can try it out online at'
                          ' https://innerpod.solidcommunity.au.\n\n'
                          'The concept for the app and images were generated by'
                          ' large language models.\n\n'
                          ' Authors: Graham Williams.'),
                    ),
                  ],
                );
              }
            },
            tooltip: 'Popup a window about the app.',
          ),
        ],
      ),
      body: Center(child: _pages.elementAt(_selectedIndex)), //Timer()),
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
