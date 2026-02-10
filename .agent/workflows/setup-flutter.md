---
description: How to set up Flutter development environment on Windows
---

# Flutter Setup Workflow for Windows

## 1. Install Flutter SDK

### Option A: Using Git (Recommended)
```powershell
# Navigate to a directory where you want to install Flutter (e.g., C:\src)
cd C:\
mkdir src
cd src

# Clone the Flutter repository
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to your PATH
# Add C:\src\flutter\bin to your system PATH environment variable
```

### Option B: Download ZIP
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your system PATH

### Add to PATH (PowerShell as Administrator)
```powershell
# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Add Flutter to PATH (adjust path if you installed elsewhere)
[Environment]::SetEnvironmentVariable(
    "Path",
    "$currentPath;C:\src\flutter\bin",
    "User"
)
```

## 2. Verify Flutter Installation

// turbo
```powershell
# Restart your terminal, then run:
flutter --version
```

// turbo
```powershell
# Check for any missing dependencies
flutter doctor
```

## 3. Install Required Dependencies

Based on `flutter doctor` output, you may need to install:

### Visual Studio (for Windows desktop development)
- Download Visual Studio 2022 Community: https://visualstudio.microsoft.com/downloads/
- During installation, select "Desktop development with C++"

### Android Studio (for Android development)
- Download from: https://developer.android.com/studio
- Install Android SDK and Android SDK Command-line Tools

### Chrome (for web development)
- Already installed on most systems

## 4. Accept Android Licenses (if developing for Android)

```powershell
flutter doctor --android-licenses
```

## 5. Set Up InnerPod Project

// turbo
```powershell
# Navigate to the innerpod directory
cd c:\Desktop\innerpod

# Get all Flutter dependencies
flutter pub get
```

## 6. Verify Project Setup

// turbo
```powershell
# Check for any issues
flutter doctor -v

# List available devices
flutter devices
```

## 7. Build and Run the App

### For Windows Desktop:
// turbo
```powershell
flutter run -d windows
```

### For Web:
```powershell
flutter run -d chrome
```

### For Android (with device connected or emulator running):
```powershell
flutter run -d android
```

## 8. Build Release Version

### Windows:
```powershell
flutter build windows
```

### Web:
```powershell
flutter build web
```

### Android:
```powershell
flutter build apk
```

## Troubleshooting

### Issue: Flutter command not found
- Solution: Restart your terminal after adding Flutter to PATH
- Or manually add to current session: `$env:Path += ";C:\src\flutter\bin"`

### Issue: Missing Visual Studio
- Solution: Install Visual Studio 2022 with C++ desktop development workload

### Issue: Android licenses not accepted
- Solution: Run `flutter doctor --android-licenses` and accept all

### Issue: Pub get fails
- Solution: Check internet connection, try `flutter pub cache repair`

## Next Steps

Once Flutter is set up:
1. Fork the innerpod repository on GitHub
2. Clone your fork locally
3. Create a new branch for your changes
4. Make your modifications
5. Test thoroughly
6. Submit a pull request

## Useful Commands

```powershell
# Update Flutter SDK
flutter upgrade

# Clean build artifacts
flutter clean

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Format code
dart format .

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```
