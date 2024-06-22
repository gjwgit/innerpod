# InnerPod Installers

Flutter supports multiple platform targets and the app will run native
on Android, iOS, Linux, MacOS, and Windows, as well as directly in a
browser from the web. Flutter functionality is essentially identical
across all platforms so the experience across different platforms will
be very similar.

## Prerequisite

There are no specific prerequisites for InnerPod.

## Android Side Load

For this SolidCommunity app, from your Android device's browser, simply visit 
the Solid Community [Installer](https://solidcommunity.au/installers/innerpod.apk] 
for InnerPod.

On your Android device simply browse to this folder and click on the
`innerpod.apk` file. Your browser will ask if you are comfortable to
install the app locally. Choose to do so and you will have an Android
native install of the app.

## Linux tar Archive

Download [innerpod.tar.gz](https://solidcommunity.au/installers/innerpod.tar.gz)

To try it out:

```bash
wget https://solidcommunity.au/installers/innerpod.tar.gz
tar zxvf innerpod.tar.gz
innerpod/innerpod
```

To install for the local user and to make it known to Gnome and KDE,
with a desktop icon:

```bash
wget https://solidcommunity.au/installers/innerpod.tar.gz
tar zxvf innerpod.tar.gz -C ${HOME}/.local/share/
ln -s ${HOME}/.local/share/innerpod/innerpod ${HOME}/.local/bin/
wget https://raw.githubusercontent.com/gjwgit/innerpod/dev/installers/innerpod.desktop -O ${HOME}/.local/share/applications/innerpod.desktop
sed -i "s/USER/$(whoami)/g" ${HOME}/.local/share/applications/innerpod.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps/
wget https://github.com/gjwgit/innerpod/raw/dev/installers/innerpod.png -O ${HOME}/.local/share/icons/hicolor/256x256/apps/innerpod.png```

To install for any user on the computer:

```bash
wget https://solidcommunity.au/installers/innerpod.tar.gz
sudo tar zxvf innerpod.tar.gz -C /opt/
sudo ln -s /opt/innerpod/innerpod /usr/local/bin/
``` 

The `rattle.desktop` and app icon can be installed into
`/usr/local/share/applications/` and `/usr/local/share/icons/`
respectively.

Once installed you can run the app as Alt-F2 and type `APP` then
Enter.

## MacOS

The package file `innerpod.dmg` can be installed on MacOS. Download
the file and open it on your Mac. Then, holding the Control key click
on the app icon to display a menu. Choose `Open`. Then accept the
warning to then run the app. The app should then run without the
warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
InnerPod. Simply visit https://innerpod.solidcommunity.au.

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows Installer

Download and run the `innerpod.exe` to self install the app on
Windows.
