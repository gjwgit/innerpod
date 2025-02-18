#!/bin/bash

APP=$(pwd | rev | cut -d'/' -f2 | rev)

## 20250210 gjw Grab the version from pubspec.

VER=$(egrep '^version:' ../pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)

echo "NOT PROPERLY CONFIGURED YET - IT INSTALLS data and lib INTO /usr/bin/ ??"

exit 1

# Build the release.

(cd ..; flutter build linux --release)

# Create debian package structure.

mkdir -p ${APP}_${VER}_amd64/DEBIAN
mkdir -p ${APP}_${VER}_amd64/usr/bin
mkdir -p ${APP}_${VER}_amd64/usr/share/applications
mkdir -p ${APP}_${VER}_amd64/usr/share/icons/hicolor/512x512/apps

# Create control file.

cat > ${APP}_${VER}_amd64/DEBIAN/control << EOL
Package: innerpod
Version: ${VER}
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: Graham Williams <graham.williams@togaware.com>
Description: A meditation timer
 A detailed description of Innerpod
 spanning multiple lines if needed.
EOL

# Create desktop entry.

cat > ${APP}_${VER}_amd64/usr/share/applications/innerpod.desktop << EOL
[Desktop Entry]
Name=Innerpod
Comment=Innerpod Meditation Timer
Exec=/usr/bin/innerpod
Icon=innerpod
Terminal=false
Type=Application
Categories=Utility;
EOL

# Copy the built flutter application.

cp -r ../build/linux/x64/release/bundle/* innerpod_${VER}_amd64/usr/bin/

# Copy the app icon (assuming you have an icon file named ${APP}.png).

cp innerpod.png innerpod_${VER}_amd64/usr/share/icons/hicolor/512x512/apps/

# Set correct permissions.

chmod 755 innerpod_${VER}_amd64/usr/bin/innerpod
chmod -R 755 innerpod_${VER}_amd64/DEBIAN
find innerpod_${VER}_amd64/usr -type d -exec chmod 755 {} \;
find innerpod_${VER}_amd64/usr -type f -exec chmod 644 {} \;
chmod 755 innerpod_${VER}_amd64/usr/bin/innerpod

# Build the debian package.

dpkg-deb --build innerpod_${VER}_amd64

# Cleanup.

#### rm -rf innerpod_${VER}_amd64
