# InnerPod Development Guide

## 📚 Table of Contents

1. [Project Overview](#project-overview)
2. [Session Recording Architecture](#session-recording-architecture)
3. [Solid Pod Integration](#solid-pod-integration)
4. [Development Setup](#development-setup)
5. [Key Features](#key-features)
6. [Code Structure](#code-structure)
7. [Testing](#testing)
8. [Contributing](#contributing)

## Project Overview

InnerPod is a meditation timer app built with Flutter that:

- Provides guided and unguided meditation sessions
- Records session data to encrypted Solid Pods
- Displays session history
- Works offline (Pod connection is optional)

**Tech Stack:**

- **Framework:** Flutter 3.2.5+
- **Language:** Dart
- **Storage:** Solid Pod (encrypted, decentralized)
- **Key Packages:**
  - `solidpod: ^0.7.4` - Solid Pod integration
  - `circular_countdown_timer: ^0.2.3` - Timer UI
  - `audioplayers: ^6.1.0` - Audio playback
  - `intl: ^0.20.2` - Date/time formatting

## Session Recording Architecture

### How It Works

```text
┌─────────────────────────────────────────────────────────────┐
│                     User Starts Session                      │
│                  (Start/Intro/Guided button)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Timer Widget (_startTime recorded)              │
│                   Session in Progress                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Session Completes                          │
│              _complete() method is called                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  _saveSession() Method                       │
│  1. Check if user is logged into Pod                        │
│  2. Read existing sessions.ttl from Pod                     │
│  3. Parse TTL data of sessions                              │
│  4. Append new session {start, end} as RDF                  │
│  5. Write back to Pod (encrypted)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    History Widget                            │
│  - Reads sessions.ttl from Pod                              │
│  - Displays in DataTable format                             │
│  - Shows: Date, Start Time, End Time                        │
└─────────────────────────────────────────────────────────────┘
```

### Data Format

Sessions are stored in `sessions.ttl` on the user's Solid Pod:

```ttl
@prefix : <#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.

:session_1739097000000 a :Session;
    :start "2026-02-09T10:30:00.000Z"^^xsd:dateTime;
    :end "2026-02-09T10:50:00.000Z"^^xsd:dateTime.

:session_1739175300000 a :Session;
    :start "2026-02-10T08:15:00.000Z"^^xsd:dateTime;
    :end "2026-02-10T08:35:00.000Z"^^xsd:dateTime.
```

**Format Details:**

- ISO 8601 timestamp format
- UTC timezone
- Millisecond precision

### Key Code Locations

#### 1. Session Recording (`lib/widgets/timer.dart`)

```dart
// Lines 229-252: Session saving logic
Future<void> _saveSession() async {
  if (_startTime == null) return;

  final endTime = DateTime.now();
  final session = {
    'start': _startTime!.toIso8601String(),
    'end': endTime.toIso8601String(),
  };

  try {
    // Read existing sessions from Pod
    String? content = await readPod('sessions.ttl');

    // Append new session using helper
    String newContent = addSession(content, session);

    // Write back to Pod
    await writePod('sessions.ttl', newContent);
    logMessage('Session saved to Pod');
  } catch (e) {
    logMessage('Error saving session to Pod: $e');
  }

  _startTime = null;
}
```

#### 2. History Display (`lib/widgets/history.dart`)

```dart
// Lines 31-60: Loading sessions from Pod
Future<void> _loadSessions() async {
  setState(() {
    _isLoading = true;
  });

  try {
    String? content = await readPod('sessions.ttl');
    List<dynamic> jsonList = parseSessions(content);
    if (jsonList.isNotEmpty) {
      setState(() {
        _sessions = jsonList.map((item) {
          final start = DateTime.parse(item['start']);
          final end = DateTime.parse(item['end']);
          return {
            'date': DateFormat('yyyy-MM-dd').format(start),
            'start': DateFormat('HH:mm:ss').format(start),
            'end': DateFormat('HH:mm:ss').format(end),
          };
        }).toList();
      });
    }
  } catch (e) {
    debugPrint('Error loading sessions: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

## Solid Pod Integration

### What is a Solid Pod?

Solid (Social Linked Data) is a decentralized web platform where:

- Users own their data
- Data is stored in personal "Pods" (Personal Online Data stores)
- Apps request permission to access data
- Data is encrypted and private by default

### How InnerPod Uses Solid Pods

1. **Optional Login** (`lib/main.dart`):

   ```dart
   SolidLogin(
     title: 'MANAGE YOUR INNER POD',
     required: false,  // App works without login
     child: Home(),
   )
   ```

2. **Reading Data**:

   ```dart
   String? content = await readPod('sessions.ttl');
   ```

3. **Writing Data**:

   ```dart
   await writePod('sessions.ttl', newContent);
   ```

### Benefits of Solid Pod Storage

- ✅ **Privacy:** Data is encrypted and only accessible to the user
- ✅ **Ownership:** Users control their data, not the app developer
- ✅ **Portability:** Data can be accessed by other Solid-compatible apps
- ✅ **Decentralized:** No central server storing user data
- ✅ **Secure:** Uses WebID authentication

## Development Setup

### Prerequisites

1. **Flutter SDK** (3.2.5 or higher)
2. **Dart SDK** (included with Flutter)
3. **Git**
4. **IDE:** VS Code or Android Studio
5. **Platform-specific tools:**
   - Windows: Visual Studio 2022 with C++ desktop development
   - Android: Android Studio + Android SDK
   - Web: Chrome browser

### Getting Started

```bash
# 1. Fork the repository on GitHub
# Visit: https://github.com/gjwgit/innerpod

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/innerpod.git
cd innerpod

# 3. Install dependencies
flutter pub get

# 4. Check setup
flutter doctor

# 5. Run the app
flutter run -d windows  # or chrome, android, etc.
```

## Key Features

### 1. Timer Widget (`lib/widgets/timer.dart`)

**Responsibilities:**

- Countdown timer display
- Session management (start, pause, resume, reset)
- Audio playback (bells, guided meditation)
- Session recording

**Key Methods:**

- `_intro()` - Plays intro audio then starts session
- `_guided()` - Plays full guided meditation
- `_complete()` - Called when session ends
- `_saveSession()` - Saves session data to Pod

### 2. History Widget (`lib/widgets/history.dart`)

**Responsibilities:**

- Display past sessions in a table
- Load sessions from Solid Pod
- Refresh functionality

**Features:**

- Date formatting (yyyy-MM-dd)
- Time formatting (HH:mm:ss)
- Loading state indicator
- Empty state message
- Pull-to-refresh

### 3. Home Widget (`lib/home.dart`)

**Responsibilities:**

- Navigation between tabs (Home, Instructions, History)
- App bar with version info
- About dialog

## Code Structure

```text
innerpod/
├── lib/
│   ├── main.dart                 # App entry point, Solid login
│   ├── home.dart                 # Main navigation & app bar
│   ├── widgets/
│   │   ├── timer.dart           # Timer & session recording
│   │   ├── history.dart         # Session history display
│   │   ├── instructions.dart    # Help/instructions
│   │   ├── app_button.dart      # Custom button widget
│   │   └── app_circular_countdown_timer.dart
│   ├── constants/
│   │   ├── colours.dart         # Color definitions
│   │   ├── audio.dart           # Audio file paths
│   │   └── spacing.dart         # Layout constants
│   └── utils/
│       ├── ding_dong.dart       # Bell sound helper
│       ├── log_message.dart     # Logging utility
│       └── word_wrap.dart       # Text formatting
├── assets/
│   ├── images/                  # App icons & images
│   └── sounds/                  # Audio files
├── pubspec.yaml                 # Dependencies
└── README.md                    # Documentation
```

## Testing

### Manual Testing Checklist

#### Session Recording

- [ ] Start a session without Pod login (should not crash)
- [ ] Start a session with Pod login (should save)
- [ ] Complete multiple sessions (should append to list)
- [ ] Check sessions.json in Pod (should be valid JSON)

#### History Display

- [ ] View history without Pod login (should show empty state)
- [ ] View history with sessions (should display table)
- [ ] Refresh history (should reload data)
- [ ] Check date/time formatting (should be readable)

#### Edge Cases

- [ ] Network interruption during save
- [ ] Corrupted sessions.json file
- [ ] Very long session (hours)
- [ ] Session started but app closed before completion

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## Contributing

### Workflow

1. **Fork & Clone**

   ```bash
   git clone https://github.com/YOUR_USERNAME/innerpod.git
   ```

2. **Create Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation

4. **Test**

   ```bash
   flutter test
   flutter analyze
   dart format .
   ```

5. **Commit**

   ```bash
   git add .
   git commit -m "feat: add session duration calculation"
   ```

6. **Push & PR**

   ```bash
   git push origin feature/your-feature-name
   # Create Pull Request on GitHub
   ```

### Code Style

- Follow [Dart style guide](https://dart.dev/effective-dart/style)
- Use `dart format .` before committing
- Add doc comments for public APIs
- Keep functions focused and small

### Potential Enhancements

Here are some ideas for improving the session recording feature:

1. **Session Duration Display**
   - Calculate and display session duration in history
   - Show statistics (total time, average session length)

2. **Session Types**
   - Track session type (Start, Intro, Guided)
   - Filter history by session type

3. **Session Notes**
   - Allow users to add notes after a session
   - Display notes in history

4. **Data Visualization**
   - Charts showing meditation frequency
   - Calendar view of sessions
   - Streak tracking

5. **Export Functionality**
   - Export sessions to CSV
   - Share session data

6. **Offline Support**
   - Queue sessions when offline
   - Sync to Pod when connection restored

7. **Session Reminders**
   - Daily meditation reminders
   - Customizable notification times

8. **Enhanced Encryption**
   - Additional encryption layer for sensitive notes
   - Backup/restore functionality

## Resources

### Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
- [Solid Project](https://solidproject.org/)
- [solidpod Package](https://pub.dev/packages/solidpod)

### InnerPod Specific

- [GitHub Repository](https://github.com/gjwgit/innerpod)
- [Online Demo](https://innerpod.solidcommunity.au)
- [Changelog](https://github.com/gjwgit/innerpod/blob/dev/CHANGELOG.md)

### Community

- [Flutter Community](https://flutter.dev/community)
- [Solid Community](https://forum.solidproject.org/)

---

Happy Coding! 🧘‍♂️

For questions or issues, please open an issue on GitHub or contact the maintainers.
