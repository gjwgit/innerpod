// A session timer with session logged to your Solid Pod.
//
// Time-stamp: <Friday 2026-02-20 05:21:30 +1100 Graham Williams>
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidui/solidui.dart';
import 'package:solidpod/solidpod.dart';

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
      image: AssetImage('assets/images/app_image.jpg'),
      logo: AssetImage('assets/images/app_icon.png'),
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

class HomeState extends State<Home> {
  // We will populate the app version shortly.

  var _appVersion = '';

  final String _changelogUrl =
      'https://github.com/Amoghhosamane/innerpod/blob/dev/CHANGELOG.md';

  // Helper function to load the app name and version.

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version; // Set app version from package info
        _selectedIndex = prefs.getInt('selected_index') ?? 0;
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

  void _onItemTapped(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_index', index);
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Widget> _pages = <Widget>[
    const Timer(key: PageStorageKey('timer_page')),
    const Instructions(key: PageStorageKey('text_page')),
    const History(key: PageStorageKey('history_page')),
  ];

  @override
  Widget build(BuildContext context) {
    // final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Inner Pod',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        backgroundColor: border,
        actions: [
          FutureBuilder<bool>(
            future: isUserLoggedIn(),
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data ?? false;
              if (isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.logout, size: 24),
                  onPressed: () => logoutPopup(context, const InnerPod()),
                  tooltip: 'Logout',
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login, size: 24),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const SolidPopupLogin(),
                  ),
                  tooltip: 'Login',
                );
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.key, size: 24),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => SolidSecurityKeyManager(
                config: SolidSecurityKeyManagerConfig(
                  appWidget: widget,
                ),
                onKeyStatusChanged: (status) {},
              ),
            ),
            tooltip: 'Security Key',
          ),
          const SizedBox(width: 8),
          Center(
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse(_changelogUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'v$_appVersion',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24),
            onPressed: () => showAppAboutDialog(context),
            tooltip: 'About the app',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: _pages.asMap().entries.map((entry) {
              final index = entry.key;
              final page = entry.value;
              return AnimatedOpacity(
                key: ValueKey('page_$index'),
                opacity: _selectedIndex == index ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _selectedIndex != index,
                  child: page,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Text',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
