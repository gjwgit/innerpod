# InnerPod Installers

Flutter supports multiple platform targets. Flutter based apps can run
native on Android, iOS, Linux, MacOS, and Windows, as well as directly
in a browser from the web. Flutter functionality is essentially
identical across all platforms so the experience across different
platforms will be very similar.

Visit the
[CHANGELOG](https://github.com/gjwgit/innerpod/blob/dev/CHANGELOG.md)
for the latest updates.

## Prerequisite

There are no specific prerequisites for installing and running
InnerPod.

## Android

The official Android app is available on the [Google Play
Store](https://play.google.com/store/apps/details?id=com.togaware.innerpod).

You can also side load the latest version of the app by visiting the
[Installer](https://solidcommunity.au/installers/innerpod.apk) from
your Android device's browser. This will download the app to your
Android device where you can click on the `innerpod.apk` file. Your
browser will ask if you are comfortable to install the app locally. If
you are comfortable with side loading the app then choose to do so.

## Linux

### Zip Install

Download [innerpod-dev-linux.zip](https://solidcommunity.au/installers/innerpod-dev-linux.zip)

To try it out:

```bash
wget https://solidcommunity.au/installers/innerpod-dev-linux.zip -O innerpod-dev-linux.zip
unzip innerpod-dev-linux.zip -d innerpod
./innerpod/innerpod
```

To install for the local user and to make it known to GNOME and KDE,
with a desktop icon for their desktop, begin by downloading the **zip** and
installing that into a local folder:

```bash
unzip innerpod-dev-linux.zip -d ${HOME}/.local/share/innerpod
```

Then set up your local installation (only required once):

```bash
ln -s ${HOME}/.local/share/innerpod/innerpod ${HOME}/.local/bin/
wget https://raw.githubusercontent.com/gjwgit/innerpod/dev/installers/innerpod.desktop -O ${HOME}/.local/share/applications/innerpod.desktop
sed -i "s/USER/$(whoami)/g" ${HOME}/.local/share/applications/innerpod.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps/
wget https://github.com/gjwgit/innerpod/raw/dev/installers/innerpod.png -O ${HOME}/.local/share/icons/hicolor/256x256/apps/innerpod.png
```

To install for any user on the computer:

```bash
sudo unzip innerpod-dev-linux.zip -d /opt/innerpod
sudo ln -s /opt/innerpod/innerpod /usr/local/bin/
``` 

The
[innerpod.desktop](https://solidcommunity.au/installers/innerpod.desktop)
and [app icon](https://solidcommunity.au/installers/innerpod.png) can
be installed into `/usr/local/share/applications/` and
`/usr/local/share/icons/` respectively.

Once installed you can run the app from the GNOME desktop through
Alt-F2 and type `innerpod` then Enter.

## MacOS

The zip file
[innerpod-dev-macos.zip](https://solidcommunity.au/installers/innerpod-dev-macos.zip)
can be installed on MacOS. Download the file and open it on your
Mac. Then, holding the Control key click on the app icon to display a
menu. Choose `Open`. Then accept the warning to then run the app. The
app should then run without the warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
InnerPod. Simply visit https://innerpod.solidcommunity.au.

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows Installer

Download and run the self extracting archive
[innerpod-dev-windows-inno.exe](https://solidcommunity.au/installers/innerpod-dev-windows-inno.exe)
to self install the app on Windows.
