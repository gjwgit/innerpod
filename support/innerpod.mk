########################################################################
#
# Makefile template for InnerPod
#
# Copyright 2021-2025 (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

ifeq ($(VER),)
  VER = $(if $(wildcard pubspec.yaml),$(shell egrep '^version:' pubspec.yaml | cut -d' ' -f2),)
endif

define INNERPOD_HELP
audio:

  jmaudio		AI intro and JM session
  weaudio		AI intro and JM session as single intro
  teaudio		Short audio clips for testing
  gjaudio		GJ basic intro and session
  aiaudio		AI generated intro and session (Play Store)

endef
export INNERPOD_HELP

help::
	@echo "$$INNERPOD_HELP"

# Manage the audio tracks to use.

# 	ffmpeg -y -v 0 -i ignore/tibet.mp3 assets/sounds/dong.mp3

jmaudio:
	ffmpeg -y -v 0 -i ignore/dong40v.ogg assets/sounds/dong.mp3
	ffmpeg -y -v 0 -i ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.mp3
	ffmpeg -y -v 0 -i ignore/session_guide_jm.ogg assets/sounds/session_guide.mp3
	ffmpeg -y -v 0 -i ignore/session_intro_music.ogg assets/sounds/session_intro.mp3
	ffmpeg -y -v 0 -i ignore/session_outro_music.ogg assets/sounds/session_outro.mp3

# 20241112 gjw For some reason web version has no sound for
# intro. Combine JM and intro into one for now.

weaudio:
	ffmpeg -y -v 0 -i ignore/dong40v.ogg assets/sounds/dong.mp3
	ffmpeg -y -v 0 -i ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.mp3
	ffmpeg -y -v 0 -i ignore/session_outro_music.ogg assets/sounds/session_outro.mp3
	ffmpeg -y -i ignore/session_guide_jm.ogg \
	          -i ignore/session_intro_music.ogg \
                  -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1[out]" \
                  -map "[out]" -codec:a \
                  libmp3lame assets/sounds/session_guide.mp3

# 20250218 gjw Other attempts to concat. Filed to get the duration in
# the output!
#
# ffmpeg -f concat -safe 0 -i ignore/concat_jm_intro.txt -c copy assets/sounds/session_guide.mp3
# sox ignore/session_guide_jm.ogg ignore/session_intro_music.ogg assets/sounds/session_guide.mp3
# sox -n -r 44100 -c 2 assets/sounds/session_intro.mp3 trim 0 1

teaudio:
	ffmpeg -y -v 0 -i ignore/testing_ding.ogg assets/sounds/dong.mp3
	ffmpeg -y -v 0 -i ignore/testing_intro.ogg assets/sounds/intro.mp3
	ffmpeg -y -v 0 -i ignore/testing_guide.ogg assets/sounds/session_guide.mp3
	ffmpeg -y -v 0 -i ignore/testing_intro_music.ogg assets/sounds/session_intro.mp3
	ffmpeg -y -v 0 -i ignore/testing_outro_music.ogg assets/sounds/session_outro.mp3

gjaudio:
	ffmpeg -y -v 0 -i ignore/dongv50.ogg assets/sounds/dong.mp3
	ffmpeg -y -v 0 -i ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.mp3
	ffmpeg -y -v 0 -i ignore/session_guide_gjw_8db.ogg assets/sounds/session_guide.mp3
	ffmpeg -y -v 0 -i ignore/silence.ogg assets/sounds/session_intro.mp3
	ffmpeg -y -v 0 -i ignore/silence.ogg assets/sounds/session_outro.mp3

aiaudio:
	ffmpeg -y -v 0 -i ignore/dong40v.ogg assets/sounds/dong.ogg
	ffmpeg -y -v 0 -i ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.ogg
	ffmpeg -y -v 0 -i ignore/session_guide_elevenlabs_emily_80.ogg assets/sounds/session_guide.ogg
	ffmpeg -y -v 0 -i ignore/silence.ogg assets/sounds/session_intro.ogg
	ffmpeg -y -v 0 -i ignore/silence.ogg assets/sounds/session_outro.ogg
