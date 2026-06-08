# Inner Pod Change Log

Noted here are the high level changes for the app.  Each update
includes a short user-oriented description.  The next release is 1.9
following incremental updates through the 1.8.n series.

You can run the app in your browser from the
[**web**](https://innerpod.solidcommunity.au) or else download and
install locally the latest version from the [Solid Community
AU](https://solidcommunity.au) or directly: for **Android** as
[aab](https://solidcommunity.au/installers/innerpod.apk) or
[apk](https://solidcommunity.au/installers/innerpod.apk); for
**GNU/Linux** as
[deb](https://solidcommunity.au/installers/innerpod_amd64.deb) or
[snap](https://solidcommunity.au/installers/innerpod_amd64.snap) or
[zip](https://solidcommunity.au/installers/innerpod-linux.zip); for
**macOS** as
[dmg](https://solidcommunity.au/installers/innerpod-macos.dmg) or
[zip](https://solidcommunity.au/installers/innerpod-macos.zip); for
**Windows** as
[inno](https://solidcommunity.au/installers/innerpod-windows-inno.exe)
or [zip](https://solidcommunity.au/installers/innerpod-windows.zip).

Contributions are welcome. Visit
[github](https://github.com/gjwgit/innerpod) to submit an issue or, even
better, fork the repository yourself, update the code, and submit a
Pull Request. Coding documentation is
[available](https://solidcommunity.au/docs/innerpod/).

We make this project available for free so if you appreciate the app
then please show some ❤️ and tap on the star at
[GitHub](https://github.com/gjwgit/innerpod) to support our work.

## 1.9 Fine Tuning

+ Support offline logging [1.8.26 20260608 gjw]
+ Add visual history [1.8.25 20260608 gjw]
+ Updated solidui menus to bottom [1.8.24 20260606 gjw]
+ Allow editing date/time [1.8.23 20260603 gjw]
+ Bug fix to reset timer at session end [1.8.22 20260410 gjw]
+ Lint and HISTORY messaging fixes [1.8.21 20260410 gjw]
+ Fix button logic indicating session type [1.8.20 20260410 gjw]
+ Retain timer on rotating app [1.8.19 20260409 gjw]
+ Remove logout from app bar [1.8.18 20260409 gjw]
+ Add status bar and app info [1.8.17 20260409 gjw]
+ Migrate to SolidScaffold [1.8.16 20260409 gjw]
+ Save theme between instances with solidui 0.3.12 [1.8.15 20260409 gjw]
+ Add dark/light mode [1.8.14 20260408 gjw]
+ Fix missing version widget instance [1.8.13 20260408 gjw]
+ Remove bottom navigation on landscape [1.8.12 20260312 gjw]
+ Landscape timer at top. Gets chopped on phone [1.8.11 20260312 gjw]
+ Move to a slider for selection of duration [1.8.10 20260312 gjw]
+ Colour the selected button [1.8.9 20260312 amogh]
+ Prompt for security key when required [1.8.8 20260312 amogh]
+ Add a delete all history [1.8.7 20260312 amogh]
+ Add INTERENET permission for Android [1.8.6 20260302 gjw]
+ Volume of Tibetan bell to 0.7 and duration to 9s [1.8.5 20260302 gjw]
+ Updated choice of colour for the spin [1.8.4 20260227 gjw]
+ Ensure duration labels are visible [1.8.3 20260226 gjw]
+ Improved colour scheme [1.8.2 20260226 gjw]
+ Dong at half volume. Start timer with bells. [1.8.1 20260226 gjw]

## 1.8 Save Sessions and Update UI

+ Review and Incorporate outsanding PRs [1.8.0 20260226 gjw]
+ Bug fix - timer was resetting to default [1.7.13 20260223 amogh]
+ Default title is the session type [1.7.12 20260223 amogh]
+ Implement PAUSE/RESUME [1.7.11 20260223 amogh]
+ Fine tune colours [1.7.10 20260220 gjw]
+ Redesign and modernise [1.7.9 20260219 amogh]
+ Add title/description and support edit and delete [1.7.8 20260219 amogh]
+ Maintain timer countdown when navigating tabs [1.7.7 20260217]
+ Implement private logging of sessions [1.7.7 20260213 amogh]
+ Fix final audio not playing on Ubuntu with Zoom [1.7.7 20260217]
+ Review and set up installers [1.7.6 20251213 gjw]
+ Package for snap release [1.7.5 20251004 gjw]
+ For GUIDED concat audio then include in app [1.7.4 20250218 gjw]
+ Review audio. Add 5 minutes option. [1.7.3 20241114 gjw]
+ Updated Tibetan bell from freesound.org [1.7.2 20241101 gjw]
+ Use markdown for About with active url links [1.7.1 20241101 gjw]

## 1.7 Fine Tuning

+ Move to mp3 rather than ogg for wider OS support [1.7.0 20241025 gjw]
+ Quotes -> Wisdom [1.6.4 20241024 gjw]
+ Update installers [1.6.3 20241023 gjw]
+ Testing [1.6.2 20241023 gjw]
+ Review audio, quieten the bell. [1.6.1 20241023 gjw]

## 1.6 UX Updates

+ Improved tooltip style. [1.5.10]
+ Remove REST and RESUME - plan for them with PAUSE. [1.5.9]
+ Re-arrange buttons and colour code for reference. [1.5.8]
+ Scroll the timer page and improve layout [1.5.7]
+ Split GUIDED into: instructions, intro music, outro music [1.5.6]
+ Refactor code [1.5.5]
+ Move to DelayedTooltips. [1.5.4]
+ Add tooltips. Add version to topbar. [1.5.3]
+ Configure for linux install and update install instructions [1.5.2]
+ Add quotes [1.5.1]

## 1.5 Basic Funcationality

+ Add session length chooser [1.4.3]
+ Add Text page [1.4.2]
+ Restructure code [1.4.1]
+ Plain timer instead of neon countdown time [1.4.0]
+ Restore SolidLogin() in prep for saving session data.
+ Update audio to AI generated.
+ Skip SolidLogin for now.
+ The package solid has been renamed to solidpod.
+ Add GUIDED and RESET buttons.
+ Refine choice of colours.
+ Fine tuning
+ Add audio pause and resume.
+ Add SolidLogin() functionality.
+ This is a usable first release.
+ Add Intro to introduce how to meditate.
+ Rename buttons: Intro, Start, Pause, Resume.
+ Add Start and Stop buttons.
+ Do not start on app load.
+ Improve colour choices.
+ Basic working countdown timer.
