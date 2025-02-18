########################################################################
#
# Makefile template for Installations
#
# Time-stamp: <Tuesday 2024-11-12 08:16:22 +1100 >
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# Define PROD and MINE if not already defined.

PROD ?= $(DEST)
MINE ?= $(DEST:$(APP)=$(USER))

# Only allow prod if in main branch.

BRANCH := $(shell git branch --show-current)

ifeq ($(BRANCH),main)
  PROD ?= $(DEST)
else
  PROD ?= $(MINE)
endif

define INSTALL_HELP
installs:

  prod     Install $(APP) into $(PROD)
  install  Install $(APP) into $(MINE)

endef
export INSTALL_HELP

help::
	@echo "$$INSTALL_HELP"

########################################################################
# LOCAL TARGETS

# Only when the dev branch is present will the app be installed into
# the appname folder on the server. Otherwise the developer's username
# is used as the install destination.

install: $(USER).install

ifeq ($(BRANCH),dev)
prod: $(APP).install
else
prod: $(USER).install
endif

# 20241112 gjw Depend on weaudio for now to combine guide and intro
# into guide and replace intro with 1s silence. For some reason the
# intro is not heard after the guide, though it is being played - it
# is 3m of silence? This required a local copy of ignore.
#
# 20250218 gjw The default app now concat's the guide and intro music
# into one mp3 file to play to avoid the issue of the intro music being
# missed.

%.install: 
	cp web/index.html web/index.html.bak
	perl -pi -e 's|^  <base href=.*$$|  <base href="/$*/">|' web/index.html
	flutter build web
	mv web/index.html.bak web/index.html
	if [ ! -e $(DEST:$(APP)=$*) ]; then \
		sudo mkdir $(DEST:$(APP)=$*); \
	fi
	sudo rsync -azvh build/web/ $(DEST:$(APP)=$*) --exclude *~ --exclude *.bak
	sudo chmod -R a+rX $(DEST:$(APP)=$*)
