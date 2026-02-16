# InnerPod: Getting Started Guide

## 🎉 Welcome

This guide will help you get started with contributing to InnerPod,
specifically focusing on the session recording and history features.

## 📋 What You Need to Know

### ✅ Good News: Features Already Implemented

The session recording and history features you mentioned are
**already implemented** in InnerPod! Here's what's working:

1. **Automatic Session Recording**
   - Sessions are automatically saved when completed
   - Data includes start time and end time
   - Stored encrypted in user's Solid Pod

2. **History Display**
   - View all past sessions in a table
   - Shows date, start time, and end time
   - Accessible via the History tab in the bottom navigation

3. **Solid Pod Integration**
   - Uses `solidpod` package from pub.dev
   - Data is encrypted and private
   - Works offline (Pod connection is optional)

### 📁 Key Files to Understand

| File | Purpose | Lines of Interest |
| :--- | :--- | :--- |
| `lib/widgets/timer.dart` | Timer & recording | 229-252 (_saveSession) |
| `lib/widgets/history.dart` | Display history | 31-60 (_loadSessions) |
| `lib/main.dart` | Entry & Solid login | 64-78 (SolidLogin) |
| `lib/home.dart` | Navigation | 110-113 (pages list) |

## 🚀 Quick Start

### Step 1: Install Flutter

**Windows Setup:**

```powershell
# 1. Download Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install

# 2. Extract to C:\src\flutter

# 3. Add to PATH (PowerShell as Administrator)
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path",
    "$currentPath;C:\src\flutter\bin", "User")

# 4. Restart terminal and verify
flutter --version
flutter doctor
```

**Detailed instructions:** See `.agent/workflows/setup-flutter.md`

### Step 2: Set Up the Project

```powershell
# Navigate to innerpod directory
cd c:\Desktop\innerpod

# Install dependencies
flutter pub get

# Check for issues
flutter doctor

# List available devices
flutter devices
```

### Step 3: Run the App

```powershell
# For Windows desktop
flutter run -d windows

# For web browser
flutter run -d chrome

# For Android (with device/emulator)
flutter run -d android
```

## 📚 Documentation Created for You

I've created three comprehensive guides to help you:

### 1. **DEVELOPMENT_GUIDE.md**

Complete development documentation covering:

- Project architecture overview
- Session recording implementation details
- Solid Pod integration explanation
- Code structure and organization
- Testing strategies
- Contribution guidelines

**When to use:** Understanding how the app works, architecture decisions,
and best practices

### 2. **SESSION_ENHANCEMENTS.md**

Enhancement ideas with implementation details:

- 10 potential improvements (from easy to advanced)
- Code examples for each enhancement
- Effort estimates and priority matrix
- Recommended implementation order

**When to use:** Planning new features, looking for contribution ideas

### 3. **.agent/workflows/setup-flutter.md**

Step-by-step Flutter setup workflow:

- Installing Flutter SDK on Windows
- Setting up development environment
- Configuring PATH variables
- Verifying installation
- Running the app

**When to use:** Setting up your development environment

## 🎯 Suggested Next Steps

### Option A: Get Familiar with the Codebase

1. **Set up Flutter** (use `/setup-flutter` workflow)
2. **Run the app** locally
3. **Explore the code:**
   - Read `lib/main.dart` to understand app structure
   - Study `lib/widgets/timer.dart` to see session recording
   - Review `lib/widgets/history.dart` to see data display
4. **Test the features:**
   - Create a Solid Pod account (optional)
   - Run a meditation session
   - View the history tab
   - Check the saved data

### Option B: Start Contributing

1. **Fork the repository** on GitHub
   - Visit: <https://github.com/gjwgit/innerpod>
   - Click "Fork" button

2. **Clone your fork**

   ```bash
   git clone https://github.com/YOUR_USERNAME/innerpod.git
   cd innerpod
   ```

3. **Pick a quick win** from SESSION_ENHANCEMENTS.md
   - Recommended first task: **Session Duration Display**
   - Estimated time: 30 minutes
   - High impact, low effort

4. **Create a branch**

   ```bash
   git checkout -b feature/session-duration
   ```

5. **Implement the feature**
   - Follow the code examples in SESSION_ENHANCEMENTS.md
   - Test thoroughly
   - Commit your changes

6. **Submit a Pull Request**
   - Push to your fork
   - Create PR on original repository
   - Describe your changes

## 💡 Quick Reference

### Running Commands

```powershell
# Install dependencies
flutter pub get

# Run app (Windows)
flutter run -d windows

# Build release
flutter build windows

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Project Structure

```text
innerpod/
├── lib/
│   ├── main.dart              # App entry point
│   ├── home.dart              # Main navigation
│   ├── widgets/
│   │   ├── timer.dart         # ⭐ Session recording
│   │   └── history.dart       # ⭐ Session history
│   ├── constants/
│   └── utils/
├── assets/                    # Images & sounds
├── pubspec.yaml              # Dependencies
└── README.md                 # Project info
```

### Key Packages Used

```yaml
solidpod: ^0.7.4              # Solid Pod integration
circular_countdown_timer: ^0.2.3  # Timer UI
audioplayers: ^6.1.0          # Audio playback
intl: ^0.20.2                 # Date/time formatting
```

## 🔍 Understanding Session Recording

### How It Works (Simplified)

```text
1. User starts session
   ↓
2. App records start time
   ↓
3. Timer counts down
   ↓
4. Session completes
   ↓
5. App records end time
   ↓
6. Data saved to Pod (if logged in)
   {
     "start": "2026-02-09T10:30:00.000Z",
     "end": "2026-02-09T10:50:00.000Z"
   }
   ↓
7. History tab displays all sessions
```

### Data Storage

**Location:** User's Solid Pod
**File:** `sessions.json`
**Format:** JSON array of session objects
**Encryption:** Handled by Solid Pod

**Example:**

```json
[
  {
    "start": "2026-02-09T10:30:00.000Z",
    "end": "2026-02-09T10:50:00.000Z"
  },
  {
    "start": "2026-02-10T08:15:00.000Z",
    "end": "2026-02-10T08:35:00.000Z"
  }
]
```

## 🎨 Easy First Contributions

### 1. Add Session Duration (30 min)

**File:** `lib/widgets/history.dart`
**Change:** Calculate and display session duration
**Difficulty:** 🟢 Beginner

### 2. Track Session Type (1 hour)

**File:** `lib/widgets/timer.dart`
**Change:** Add 'type' field (start/intro/guided)
**Difficulty:** 🟢 Beginner

### 3. Show Statistics (2 hours)

**File:** `lib/widgets/history.dart`
**Change:** Display total sessions, total time, average
**Difficulty:** 🟡 Intermediate

**See SESSION_ENHANCEMENTS.md for detailed implementation guides!**

## 🤝 Getting Help

### Resources

- **Flutter Docs:** <https://docs.flutter.dev/>
- **Dart Language:** <https://dart.dev/docs>
- **Solid Project:** <https://solidproject.org/>
- **InnerPod GitHub:** <https://github.com/gjwgit/innerpod>

### Common Issues

**Q: Flutter command not found**
A: Restart terminal after adding to PATH, or run:

```powershell
$env:Path += ";C:\src\flutter\bin"
```

**Q: Visual Studio required error**
A: Install Visual Studio 2022 with C++ desktop development workload

**Q: How do I test without a Solid Pod?**
A: App works offline! Just click "SESSION" on login screen

**Q: Where is session data stored locally?**
A: Only in Solid Pod. Without login, sessions aren't saved (by design)

## 🎯 Your Mission (If You Choose to Accept)

1. ✅ Set up Flutter development environment
2. ✅ Run InnerPod locally
3. ✅ Understand session recording architecture
4. ✅ Pick an enhancement from SESSION_ENHANCEMENTS.md
5. ✅ Implement and test
6. ✅ Submit a Pull Request
7. ✅ Celebrate! 🎉

## 📞 Contact

- **GitHub Issues:** <https://github.com/gjwgit/innerpod/issues>
- **Original Author:** Graham Williams
- **Project:** Togaware

---

**Happy coding! May your meditation sessions be peaceful and your code
bug-free! 🧘‍♂️✨**
