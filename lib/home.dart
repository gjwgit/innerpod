// A session timer with session logged to your Solid Pod.
//
// Time-stamp: <Thursday 2026-04-09 20:13:49 +1000 Graham Williams>
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
import 'package:solidpod/solidpod.dart' show getWebId;
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
      // loginButtonStyle: LoginButtonStyle(visible: true),
      // continueButtonStyle: ContinueButtonStyle(visible: true),
      // registerButtonStyle: RegisterButtonStyle(visible: false),
      // infoButtonStyle: InfoButtonStyle(visible: true),
      link: 'https://github.com/Amoghhosamane/innerpod/blob/dev/README.md',
      child: Home(),
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
  String? _webId;

  final String _changelogUrl =
      'https://github.com/gjwgit/innerpod/blob/dev/CHANGELOG.md';

  // Helper function to load the app name and version.

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final webId = await getWebId();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
        _webId = webId;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Get the app name and version.

    _loadAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    // final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return SolidScaffold(
      showLogout: false,
      appBar: SolidAppBarConfig(
        title: 'Inner Pod',
        versionConfig: _appVersion != '0.0.0'
            ? SolidVersionConfig(
                changelogUrl: _changelogUrl,
              )
            : null,
      ),
      themeToggle: const SolidThemeToggleConfig(enabled: true),
      statusBar: SolidStatusBarConfig(
        serverInfo: _webId != null ? SolidServerInfo.fromWebId(_webId!) : null,
        loginStatus: SolidLoginStatus(
          webId: _webId,
        ),
        securityKeyStatus: const SolidSecurityKeyStatus(
          title: 'InnerPod Security Keys',
        ),
      ),
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
      menu: const [
        SolidMenuItem(
          title: 'Session',
          icon: Icons.timer_outlined,
          tooltip: '**Session**\n\nTimer and session controls.',
          child: Timer(),
        ),
        SolidMenuItem(
          title: 'Text',
          icon: Icons.menu_book_outlined,
          tooltip: '**Text**\n\nGuide, prayers and wisdom.',
          child: Instructions(),
        ),
        SolidMenuItem(
          title: 'History',
          icon: Icons.history_outlined,
          tooltip: '**History**\n\nPast sessions logged to your Pod.',
          child: History(),
        ),
      ],
    );
  }
}
