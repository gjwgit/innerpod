<!-- markdownlint-disable MD013 -->

# InnerPod Installers

Flutter supports multiple platform targets. Flutter based apps can run
native on Android, iOS, Linux, MacOS, and Windows, as well as directly
in a browser from the web. Flutter functionality is essentially
identical across all platforms so the experience across different
platforms will be very similar.

Visit the
[CHANGELOG](https://github.com/gjwgit/innerpod/blob/dev/CHANGELOG.md)
for the latest updates.

Run the app online: [**web**](https://innerpod.solidcommunity.au).

Download the latest version:

+ **Android**
  [apk](https://solidcommunity.au/installers/innerpod.apk);

+ **GNU/Linux**
  [deb](https://solidcommunity.au/installers/innerpod_amd64.deb) or
  [snap](https://solidcommunity.au/installers/innerpod_amd64.snap) or
  [flatpak](https://solidcommunity.au/installers/innerpod_amd64.flatpak) or
  [zip](https://solidcommunity.au/installers/innerpod-linux.zip);
+ **macOS**
  [dmg](https://solidcommunity.au/installers/innerpod-macos.dmg) or
  [zip](https://solidcommunity.au/installers/innerpod-macos.zip);
+ **Windows**
  [exe](https://solidcommunity.au/installers/innerpod-windows-inno.exe) or
  [zip](https://solidcommunity.au/installers/innerpod-windows.zip).

## Prerequisite

There are no specific prerequisites for installing and running the
app.

## Android

The official Android app is available on the [Google Play
Store](https://play.google.com/store/apps/details?id=com.togaware.innerpod).

You can also side load the latest version of the app by downloading the
[installer](https://solidcommunity.au/installers/innerpod.apk)
through your Android device's browser. This will download the app to
your Android device. Then visit the Downloads folder (choosing the
menu option in the browser) where you can click on the
`innerpod.apk` file. Your browser will ask if you would like to
installing the app locally.

## Linux

### Deb Install for Debian/Ubuntu

Download
[innerpod_amd64.deb](https://solidcommunity.au/installers/innerpod_amd64.deb)
and install:

```bash
wget https://solidcommunity.au/installers/innerpod_amd64.deb -O innerpod_amd64.deb
sudo dpkg --install innerpod_amd64.deb
```

### Linux Snap Install

Download
[innerpod_amd64.snap](https://solidcommunity.au/installers/innerpod_amd64.snap)
and install:

```bash
wget https://solidcommunity.au/installers/innerpod_amd64.snap -O innerpod_amd64.snap
sudo snap install --dangerous innerpod_amd64.snap
```

### Linux Flatpak Install

Download
[innerpod_amd64.flatpak](https://solidcommunity.au/installers/innerpod_amd64.flatpak)
and install for yourself. The GNOME runtime it needs is fetched from
Flathub if it is not already installed:

```bash
wget https://solidcommunity.au/installers/innerpod_amd64.flatpak -O innerpod_amd64.flatpak
flatpak install --user innerpod_amd64.flatpak
flatpak run com.togaware.innerpod
```

### Linux Zip Install

Download
[innerpod-linux.zip](https://solidcommunity.au/installers/innerpod-linux.zip)

To try it out:

```bash
wget https://solidcommunity.au/installers/innerpod-linux.zip -O innerpod-linux.zip
unzip innerpod-linux.zip -d innerpod
./innerpod/innerpod
```

To install for the local user and to make it known to GNOME and KDE
with a desktop icon for their desktop (which is automatically done
using the deb or snap installations), begin by downloading the **zip**
and installing that into a local folder:

```bash
unzip innerpod-linux.zip -d ${HOME}/.local/share/innerpod
```

Then set up your local installation (only required once):

```bash
ln -s ${HOME}/.local/share/innerpod/innerpod ${HOME}/.local/bin/
wget https://raw.githubusercontent.com/gjwgit/innerpod/dev/installers/app.desktop -O ${HOME}/.local/share/applications/innerpod.desktop
sed -i "s/USER/$(whoami)/g" ${HOME}/.local/share/applications/innerpod.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps/
wget https://github.com/gjwgit/innerpod/raw/dev/installers/app.png -O ${HOME}/.local/share/icons/hicolor/256x256/apps/innerpod.png
```

To install for any user on the computer:

```bash
sudo unzip innerpod-linux.zip -d /opt/innerpod
sudo ln -s /opt/innerpod/innerpod /usr/local/bin/
wget https://raw.githubusercontent.com/gjwgit/innerpod/dev/installers/app.desktop -O ${HOME}/usr/local/share/applications/innerpod.desktop
wget https://github.com/gjwgit/innerpod/raw/dev/installers/app.png -O ${HOME}/use/local/share/icons/innerpod.png
```

Once installed you can run the app from the GNOME desktop through
Alt-F2 and type `innerpod` then Enter.

## macOS

### macOS Zip Install

Download
[innerpod-macos.zip](https://solidcommunity.au/installers/innerpod-macos.zip).

Open the downloaded file on your Mac. Then, holding the Control key
click on the app icon to display a menu. Choose `Open`. Then accept
the warning (or give permission to install the app) to then run the
app. The app should run without the warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
InnerPod. Simply visit
[https://innerpod.solidcommunity.au](https://innerpod.solidcommunity.au).

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows

### Windows Self Extracting Archive

Download and run the self extracting archive
[innerpod-windows-inno.exe](https://solidcommunity.au/installers/innerpod-windows-inno.exe)
to self install the app on Windows.
