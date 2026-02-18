/// A reusable markdown body widget with selectable text and clickable links.
//
// Time-stamp: <2025-02-18 20:40:00 Graham Williams>
//
/// Copyright (C) 2024, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
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
