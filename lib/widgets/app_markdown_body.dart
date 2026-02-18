/// A reusable markdown body widget with selectable text and clickable links.
//
// Time-stamp: <2025-02-18 20:40:00 Graham Williams>
//
/// Copyright (C) 2024-2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0.
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

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable markdown body widget with selectable text and clickable links.
class AppMarkdownBody extends StatelessWidget {
  /// The markdown text to display.
  final String data;

  /// Whether the text should be selectable.
  final bool selectable;

  /// The text style for the markdown.
  final MarkdownStyleSheet? styleSheet;

  /// Constructor
  const AppMarkdownBody({
    required this.data,
    this.selectable = true,
    this.styleSheet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      softLineBreak: true,
      styleSheet: styleSheet,
      onTapLink: (text, href, title) async {
        if (href != null) {
          final url = Uri.parse(href);
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              debugPrint('Could not launch $href');
            }
          } catch (e) {
            debugPrint('Error launching $href: $e');
          }
        }
      },
    );
  }
}
