########################################################################
#
# Generic Makefile
#
# Time-stamp: <Saturday 2025-02-22 05:14:32 +1100 Graham Williams>
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App is often the current directory name.
#
# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

APP=$(shell pwd | xargs basename)
VER = $(shell egrep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
DATE=$(shell date +%Y-%m-%d)

# Identify a destination used by install.mk

DEST=/var/www/html/$(APP)

# The host for the repository of packages, the path on the server to
# the download folder, and the URL to the downloads.

REPO=solidcommunity.au
RLOC=/var/www/html/installers/
DWLD=https://$(REPO)/installers

########################################################################
# Supported Makefile modules.

# Often the support Makefiles will be in the local support folder, or
# else installed in the local user's shares.

INC_BASE=$(HOME)/.local/share/make
INC_BASE=support

# Specific Makefiles will be loaded if they are found in
# INC_BASE. Sometimes the INC_BASE is shared by multiple local
# Makefiles and we want to skip specific makes. Simply define the
# appropriate INC to a non-existant location and it will be skipped.

INC_DOCKER=skip
INC_MLHUB=skip
INC_WEBCAM=skip

# Load any modules available.

INC_MODULE=$(INC_BASE)/modules.mk

ifneq ("$(wildcard $(INC_MODULE))","")
  include $(INC_MODULE)
endif

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP):

  jmaudio		AI intro and JM session
  weaudio		AI intro and JM session as single intro
  teaudio		Short audio clips for testing
  gjaudio		GJ basic intro and session
  aiaudio		AI generated intro and session (Play Store)

  ginstall   After a github build download bundles and upload to $(REPO)

  local	     Install to $(HOME)/.local/share/$(APP)
    tgz	     Upload the installer to $(REPO)
  apk	     Upload the installer to $(REPO)

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS

#
# Manage the production install on the remote server.
#

clean::
	rm -f README.html

# Linux: Upload to Solid Community installers for general access.

tgz::
	chmod a+r installers/*.tar.gz
	rsync -avzh installers/*.tar.gz $(REPO):/var/www/html/installers/
	ssh $(REPO) chmod -R go+rX /var/www/html/installers/
	ssh $(REPO) chmod go=x /var/www/html/installers/

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

# Make apk on this machine to deal with signing. Then a ginstall of
# the built bundles from github, installed to solidcommunity.au and
# moved into ARCHIVE.

apk::
	rsync -avzh installers/$(APP).apk $(REPO):$(RLOC)
	ssh $(REPO) chmod a+r $(RLOC)/$(APP).apk
	mv -f installers/$(APP)-*.apk installers/ARCHIVE
	rm -f installers/$(APP).apk

deb:
	(cd installers; make $@)
	rsync -avzh installers/$(APP)_$(VER)_amd64.deb $(REPO):$(RLOC)/$(APP)_amd64.deb
	ssh $(REPO) chmod a+r $(RLOC)/$(APP)_amd64.deb
	wget $(DWLD)/$(APP)_amd64.deb -O $(APP)_amd64.deb
	wajig install $(APP)_amd64.deb
	rm -f $(APP)_amd64.deb
	mv -f installers/$(APP)_*.deb installers/ARCHIVE

# 20250110 gjw A ginstall of the github built bundles, and the locally
# built apk installed to the repository and moved into ARCHIVE.
#
# 20250218 gjw Remove the deb build for now as it is placing the data
# and lib folders into /ust/bin/ which when we try to add another
# package also tries to do that, which is how I found the issue.
#
# 20250222 gjw Solved the issue by putting the package files into
# /usr/lib/rattle and then symlinked the executable to
# /usr/bin/rattle. This is working so add deb into the install and now
# utilise that for the default install on my machine.

ginstall: deb apk
	(cd installers; make $@)
