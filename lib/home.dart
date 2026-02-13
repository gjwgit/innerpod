// A session timer with session logged to your Solid Pod.
//
// Time-stamp: <Tuesday 2026-02-10 15:44:48 +1100 Graham Williams>
//
// Copyright (C) 2024-2025, Togaware Pty Ltd
//
// Licensed under the GNU General Public License, Version 3 (the "License");
//
// License: https://opensource.org/license/gpl-3-0
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

import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidui/solidui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:innerpod/constants/colours.dart';
import 'package:innerpod/widgets/about.dart';
import 'package:innerpod/widgets/history.dart';
import 'package:innerpod/widgets/instructions.dart';
import 'package:innerpod/widgets/timer.dart';

/// The primary widget for the app.

class InnerPod extends StatelessWidget {
  /// The primary app widget.

  const InnerPod({super.key});

  @override
  Widget build(BuildContext context) {
    /// We wrap the actual home widget within a [SolidLogin]. If the app has
    /// functionality that does not require access to Pod data then [required]
    /// can be `false`. If the user connects to their Pod then we can ensure
    /// their session information will be saved. If we aim to save the data to
    /// the Pod or view data from the Pod, then if the user did not log i during
    /// startup then we can call [SolidLoginPopup] to establish the connection
    /// at that time. The login token and the security key are (optionally)
    /// cached so that the login information is not required every time.

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
      link: 'https://github.com/Amoghhosamane/innerpod/blob/dev/README.md',
      child: Home(),
    );
  }
}

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

  var _appVersion = '';

  final String _changelogUrl =
      'https://github.com/Amoghhosamane/innerpod/blob/dev/CHANGELOG.md';

  // Helper function to load the app name and version.

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version; // Set app version from package info
      });
    }
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
    const History(),
  ];

  @override
  Widget build(BuildContext context) {
    // final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/inner_icon.png', width: 40, height: 40),
            const SizedBox(width: 20),
            const Text('Inner Pod'),
          ],
        ),
        backgroundColor: border,
        actions: [
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(_changelogUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                debugPrint('Could not launch $_changelogUrl');
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'Version $_appVersion',
                style: const TextStyle(color: Colors.deepPurple, fontSize: 10),
              ),
            ),
          ),
          const SizedBox(width: 50),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showAppAboutDialog(context),
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
