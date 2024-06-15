# Innerpod Installers

Flutter supports multiple platform targets and Flutter based apps will
run native on Android, iOS, Linux, MacOS, and Windows, as well as
directly in a browser from the web. While the Flutter functionality is
in theory identical across all platforms, innerpod relies on running R
locally and so it requires R to be installed on your platform. At
present R is supported on the desktops (Linux, MacOS, and Windows).

## Prerequisite

Install R. See the instructions from the [R
Project](https://cloud.r-project.org/).

## Linux tar Archive

Download [innerpod.tar.gz](https://solidcommunity.au/installers/innerpod.tar.gz)

```bash
wget https://solidcommunity.au/installers/innerpod.tar.gz
```

Then, to simply try it out locally:

```bash
tar zxvf innerpod.tar.gz
innerpod/innerpod
```

Or, to install for the current user:

```bash
tar zxvf innerpod.tar.gz -C ${HOME}/.local/share/
ln -s ${HOME}/.local/share/innerpod/innerpod ${HOME}/.local/bin/
```

Or, for a system-wide install:

```bash
sudo tar zxvf innerpod.tar.gz -C /opt/
sudo ln -s /opt/innerpod/innerpod /usr/local/bin/
``` 

Once installed you can run the app as Alt-F2 and type `innerpod` then
Enter.

## MacOS

The package file `innerpod.dmg` can be installed on MacOS. Download
the file and open it on your Mac. Then, holding the Control key click
on the app icon to display a menu. Choose `Open`. Then accept the
warning to then run the app. The app should then run without the
warning next time.

## Windows Installer

Download and run the `innerpod.exe` to self install the app on
Windows.
