/// BellDialog — choose which bell sounds the beginning and end of a session.
///
/// The choice is saved as soon as it is made, so the dialog has no Save
/// button. Each bell can be previewed without selecting it.
///
// Time-stamp: <2026-08-27>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:innerpod/constants/audio.dart';
import 'package:innerpod/constants/bells.dart';
import 'package:innerpod/models/bell.dart';
import 'package:innerpod/utils/bell_prefs.dart';

/// Show the bell chooser. The chosen bell is saved on selection.

Future<void> showBellDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (context) => const _BellChooser(),
    );

class _BellChooser extends StatefulWidget {
  const _BellChooser();

  @override
  State<_BellChooser> createState() => _BellChooserState();
}

class _BellChooserState extends State<_BellChooser> {
  // A player of our own so a preview never disturbs the session player.

  final AudioPlayer _player = AudioPlayer();

  Bell? _selected;

  // The id of the bell currently being previewed, so its button can offer to
  // stop it again.

  String? _playing;

  @override
  void initState() {
    super.initState();
    BellPrefs.selected().then((bell) {
      if (mounted) setState(() => _selected = bell);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
  }

  @override
  void dispose() {
    // Stops the preview as well as freeing the player, so closing the dialog
    // part way through a bell leaves silence behind.

    _player.dispose();
    super.dispose();
  }

  Future<void> _previewBell(Bell bell) async {
    final wasPlaying = _playing == bell.id;
    await _player.stop();
    if (mounted) setState(() => _playing = null);
    if (wasPlaying) return;
    await _player.setVolume(bellVolume);
    await _player.play(AssetSource(bell.asset));
    if (mounted) setState(() => _playing = bell.id);
  }

  Future<void> _choose(String? id) async {
    final bell = bellById(id);
    setState(() => _selected = bell);
    await BellPrefs.select(bell);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Session Bell'),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: RadioGroup<String>(
              groupValue: _selected?.id,
              onChanged: _choose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final bell in bells)
                    RadioListTile<String>(
                      value: bell.id,
                      title: Text(bell.label),
                      subtitle: Text(bell.description),
                      secondary: MarkdownTooltip(
                        message: '''

                        **Preview ${bell.label}**

                        Tap to hear this bell without selecting it. Tap again
                        to stop it part way through.

                        ''',
                        child: IconButton(
                          icon: Icon(
                            _playing == bell.id
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                          ),
                          onPressed: () => _previewBell(bell),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
}
