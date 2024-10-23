########################################################################
#
# Generic Makefile
#
# Time-stamp: <Thursday 2024-10-24 09:15:39 +1100 Graham Williams>
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
VER=
DATE=$(shell date +%Y-%m-%d)

# Identify a destination used by install.mk

DEST=/var/www/html/$(APP)

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
  teaudio		Short audio clips for testing
  gjaudio		GJ basic intro and session
  aiaudio		AI generated intro and session (Play Store)

  ginstall   Install to solidcommunity.au and local after a build
  tgz	     Upload the installer to solidcommunity.com
  apk	     Upload the installer to solidcommunity.com

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
	rsync -avzh installers/*.tar.gz solidcommunity.au:/var/www/html/installers/
	ssh solidcommunity.au chmod -R go+rX /var/www/html/installers/
	ssh solidcommunity.au chmod go=x /var/www/html/installers/

# Manage the audio tracks to use.

jmaudio:
	cp ignore/dong40v.ogg assets/sounds/dong.ogg
	cp ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.ogg
	cp ignore/session_guide_jm.ogg assets/sounds/session_guide.ogg
	cp ignore/session_intro_music.ogg assets/sounds/session_intro.ogg
	cp ignore/session_outro_music.ogg assets/sounds/session_outro.ogg

teaudio:
	cp ignore/testing_ding.ogg assets/sounds/dong.ogg
	cp ignore/testing_intro.ogg assets/sounds/intro.ogg
	cp ignore/testing_guide.ogg assets/sounds/session_guide.ogg
	cp ignore/testing_intro_music.ogg assets/sounds/session_intro.ogg
	cp ignore/testing_outro_music.ogg assets/sounds/session_outro.ogg

gjaudio:
	cp ignore/dongv50.ogg assets/sounds/dong.ogg
	cp ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.ogg
	cp ignore/session_guide_gjw_8db.ogg assets/sounds/session_guide.ogg
	cp ignore/silence.ogg assets/sounds/session_intro.ogg
	cp ignore/silence.ogg assets/sounds/session_outro.ogg

aiaudio:
	cp ignore/dong40v.ogg assets/sounds/dong.ogg
	cp ignore/intro_elevenlabs_emily.ogg assets/sounds/intro.ogg
	cp ignore/session_guide_elevenlabs_emily_80.ogg assets/sounds/session_guide.ogg
	cp ignore/silence.ogg assets/sounds/session_intro.ogg
	cp ignore/silence.ogg assets/sounds/session_outro.ogg

# Make apk on this machine to deal with signing. Then a ginstall of
# the built bundles from github, installed to solidcommunity.au and
# moved into ARCHIVE.

apk::
	rsync -avzh installers/$(APP).apk solidcommunity.au:/var/www/html/installers/
	ssh solidcommunity.au chmod a+r /var/www/html/installers/innerpod.apk
	mv -f installers/$(APP)-*.apk installers/ARCHIVE

ginstall: apk
	(cd installers; make $@)
