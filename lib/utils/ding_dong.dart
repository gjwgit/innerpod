import 'package:innerpod/constants/audio.dart.~4~';

/// Encapsulate the playing of the dong into its own function because of the
/// need for it to be async through the await and it is called upon multiple
/// times.

Future<void> dingDong(player) async {
  // Always stop the player first in case there is some other audio still
  // playing.
  await player.stop();
  await player.play(dong);
}
