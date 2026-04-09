// A session timer with session logged to your Solid Pod.
//
// Time-stamp: <Thursday 2026-03-12 12:18:15 +1100 Graham Williams>
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

import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidui/solidui.dart';

import 'package:innerpod/widgets/history.dart';
import 'package:innerpod/widgets/instructions.dart';
import 'package:innerpod/widgets/timer.dart';

/// The primary widget for the app.

class InnerPod extends StatelessWidget {
  /// The theme notifier for toggling dark/light mode.

  /// The primary app widget.

  const InnerPod({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidLogin(
      title: 'MANAGE YOUR INNER POD',
      required: false,
      image: const AssetImage('assets/images/app_image.jpg'),
      logo: const AssetImage('assets/images/app_icon.png'),
      continueButtonStyle: const ContinueButtonStyle(
        text: 'Session',
        background: Colors.lightGreenAccent,
      ),
      infoButtonStyle: const InfoButtonStyle(
        tooltip: 'Browse to the InnerPod home page.',
      ),
      link: 'https://github.com/Amoghhosamane/innerpod/blob/dev/README.md',
      child: const Home(),
    );
  }
}

/// A widget for the actuall app's main home page.

class Home extends StatefulWidget {
  /// The theme notifier for toggling dark/light mode.

  /// Constructor for the home screen.

  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

///

class HomeState extends State<Home> {
  // We will populate the app version shortly.

  var _appVersion = '0.0.0';

  final String _changelogUrl =
      'https://github.com/gjwgit/innerpod/blob/dev/CHANGELOG.md';

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

    return SolidScaffold(
      extendBodyBehindAppBar: true,
      appBar: SolidAppBarConfig(
        title: 'Inner Pod',
        versionConfig: _appVersion != '0.0.0'
            ? SolidVersionConfig(
                changelogUrl: _changelogUrl,
              )
            : null,
      ),
      themeToggle: const SolidThemeToggleConfig(enabled: true),
      aboutConfig: SolidAboutConfig(
        applicationName: 'Inner Pod',
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '© 2024-2026 Togaware Pty Ltd',
        text: '''
Inner Pod can be used to time any fixed time session, optionally storing a
log of your sessions to a secure and private data store. The app is commonly
used for contemplative or silent meditation as is the tradition in many
cultures and religions. The progress circle provides a visual cue that the
session is active.

**OnLine** [https://innerpod.solidcommunity.au](https://innerpod.solidcommunity.au)

**GitHub** [https://github.com/gjwgit/innerpod](https://github.com/gjwgit/innerpod)

**Author** [Graham Williams](https://togaware.com/graham.williams.html)
''',
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SafeArea(
          // bottom: false,
          child: Stack(
            children: _pages.asMap().entries.map((entry) {
              final index = entry.key;
              final page = entry.value;
              return AnimatedOpacity(
                key: ValueKey('page_$index'),
                opacity: _selectedIndex == index ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: IgnorePointer(
                  ignoring: _selectedIndex != index,
                  child: page,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar:
          // 20260312 gjw Change the handling of the navigation bar depending on the
          // orientation. This is assuming the landscape is on a phone and so the
          // height is limited and the navigation bar will otherwise overlay the
          // timer. Not true if on desktop, but we'll deal with that another time.

          MediaQuery.of(context).orientation == Orientation.portrait
              ? Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          0,
                          Icons.timer_outlined,
                          Icons.timer_rounded,
                          'Home',
                        ),
                        _buildNavItem(
                          1,
                          Icons.menu_book_outlined,
                          Icons.menu_book_rounded,
                          'Text',
                        ),
                        _buildNavItem(
                          2,
                          Icons.history_outlined,
                          Icons.history_rounded,
                          'History',
                        ),
                      ],
                    ),
                  ),
                )
              : null, // 20260312 gjw Hide the navigation bar in landscape mode.
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
