# Session Recording Enhancement Ideas

This document outlines potential enhancements to the InnerPod session recording and history features.

## 🎯 Quick Wins (Easy to Implement)

### 1. Session Duration Display

**Current State:** Only start and end times are shown  
**Enhancement:** Calculate and display session duration

**Implementation:**
```dart
// In lib/widgets/history.dart
_sessions = jsonList.map((item) {
  final start = DateTime.parse(item['start']);
  final end = DateTime.parse(item['end']);
  final duration = end.difference(start);
  
  return {
    'date': DateFormat('yyyy-MM-dd').format(start),
    'start': DateFormat('HH:mm:ss').format(start),
    'end': DateFormat('HH:mm:ss').format(end),
    'duration': '${duration.inMinutes} min ${duration.inSeconds % 60} sec',
  };
}).toList();

// Add duration column to DataTable
DataColumn(label: Text('Duration')),
// ...
DataCell(Text(session['duration']!)),
```

**Effort:** 🟢 Low (30 minutes)

---

### 2. Session Type Tracking

**Current State:** No distinction between Start/Intro/Guided sessions  
**Enhancement:** Track and display session type

**Implementation:**
```dart
// In lib/widgets/timer.dart, modify _saveSession()
final session = {
  'start': _startTime!.toIso8601String(),
  'end': endTime.toIso8601String(),
  'type': _sessionType, // Add this field
};

// Add state variable
String _sessionType = 'start'; // or 'intro', 'guided'

// Update in each button handler
onPressed: () {
  _sessionType = 'intro';
  _intro();
}
```

**Effort:** 🟢 Low (1 hour)

---

### 3. Total Statistics Display

**Current State:** No summary statistics  
**Enhancement:** Show total meditation time, session count, average duration

**Implementation:**
```dart
// In lib/widgets/history.dart
Widget _buildStatistics() {
  if (_sessions.isEmpty) return SizedBox.shrink();
  
  int totalMinutes = 0;
  for (var session in _sessions) {
    final start = DateTime.parse(session['start']);
    final end = DateTime.parse(session['end']);
    totalMinutes += end.difference(start).inMinutes;
  }
  
  final avgMinutes = totalMinutes ~/ _sessions.length;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Total Sessions: ${_sessions.length}'),
          Text('Total Time: ${totalMinutes ~/ 60}h ${totalMinutes % 60}m'),
          Text('Average Duration: $avgMinutes minutes'),
        ],
      ),
    ),
  );
}
```

**Effort:** 🟡 Medium (2 hours)

---

## 🚀 Medium Enhancements

### 4. Session Notes

**Enhancement:** Allow users to add notes after completing a session

**Data Format:**
```json
{
  "start": "2026-02-09T10:30:00.000Z",
  "end": "2026-02-09T10:50:00.000Z",
  "type": "guided",
  "notes": "Felt very peaceful today. Mind was calm."
}
```

**UI Flow:**
1. After session completes, show optional notes dialog
2. User can add/skip notes
3. Notes stored with session data
4. Display notes in history (expandable row or detail view)

**Implementation Locations:**
- `lib/widgets/timer.dart` - Add notes dialog after _complete()
- `lib/widgets/history.dart` - Display notes in expandable rows
- Consider creating `lib/widgets/session_notes_dialog.dart`

**Effort:** 🟡 Medium (4-6 hours)

---

### 5. Calendar View

**Enhancement:** Show sessions on a calendar with visual indicators

**Features:**
- Calendar grid showing current month
- Days with sessions highlighted
- Tap day to see sessions for that date
- Color coding by session type

**Packages to Use:**
- `table_calendar: ^3.0.9`

**Implementation:**
```dart
// New file: lib/widgets/calendar_view.dart
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  // Calendar implementation
}
```

**Effort:** 🟡 Medium (6-8 hours)

---

### 6. Export to CSV

**Enhancement:** Export session history to CSV file

**Implementation:**
```dart
// In lib/widgets/history.dart
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> _exportToCSV() async {
  List<List<dynamic>> rows = [
    ['Date', 'Start Time', 'End Time', 'Duration', 'Type'],
  ];
  
  for (var session in _sessions) {
    rows.add([
      session['date'],
      session['start'],
      session['end'],
      session['duration'],
      session['type'] ?? 'start',
    ]);
  }
  
  String csv = const ListToCsvConverter().convert(rows);
  
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/innerpod_sessions.csv';
  final file = File(path);
  await file.writeAsString(csv);
  
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Exported to $path')),
  );
}
```

**Dependencies to Add:**
```yaml
dependencies:
  csv: ^6.0.0
  path_provider: ^2.1.0
```

**Effort:** 🟡 Medium (3-4 hours)

---

## 🎨 Advanced Features

### 7. Data Visualization Charts

**Enhancement:** Visual charts showing meditation patterns

**Chart Types:**
- Line chart: Sessions per week/month
- Bar chart: Session duration over time
- Pie chart: Session type distribution
- Heatmap: Meditation frequency calendar

**Packages:**
- `fl_chart: ^0.66.0` (recommended)
- `charts_flutter: ^0.12.0`

**Example:**
```dart
// lib/widgets/statistics_chart.dart
import 'package:fl_chart/fl_chart.dart';

class SessionsLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        // Chart configuration
      ),
    );
  }
}
```

**Effort:** 🔴 High (10-15 hours)

---

### 8. Streak Tracking

**Enhancement:** Track consecutive days of meditation

**Features:**
- Current streak counter
- Longest streak record
- Visual streak calendar
- Streak milestones (7 days, 30 days, 100 days)
- Motivational messages

**Implementation:**
```dart
// lib/utils/streak_calculator.dart
class StreakCalculator {
  static int calculateCurrentStreak(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0;
    
    // Sort sessions by date
    sessions.sort((a, b) => 
      DateTime.parse(b['start']).compareTo(DateTime.parse(a['start']))
    );
    
    int streak = 0;
    DateTime lastDate = DateTime.now();
    
    for (var session in sessions) {
      final sessionDate = DateTime.parse(session['start']);
      final daysDiff = lastDate.difference(sessionDate).inDays;
      
      if (daysDiff <= 1) {
        streak++;
        lastDate = sessionDate;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  static int calculateLongestStreak(List<Map<String, dynamic>> sessions) {
    // Implementation for longest streak
  }
}
```

**Effort:** 🔴 High (8-12 hours)

---

### 9. Offline Queue & Sync

**Enhancement:** Queue sessions when offline, sync when connection restored

**Architecture:**
```
┌─────────────────────────────────────┐
│     Session Completes               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Check Internet Connection         │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌─────────────┐  ┌─────────────────┐
│  Online     │  │  Offline        │
│  Save to    │  │  Save to Local  │
│  Pod        │  │  Queue          │
└─────────────┘  └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │  Connection     │
                 │  Restored       │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │  Sync Queue     │
                 │  to Pod         │
                 └─────────────────┘
```

**Implementation:**
```dart
// lib/services/session_sync_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionSyncService {
  static const String _queueKey = 'session_queue';
  
  static Future<void> saveSession(Map<String, String> session) async {
    final connectivity = await Connectivity().checkConnectivity();
    
    if (connectivity != ConnectivityResult.none) {
      // Online: Save directly to Pod
      await _saveToPod(session);
    } else {
      // Offline: Add to queue
      await _addToQueue(session);
    }
  }
  
  static Future<void> syncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);
    
    if (queueJson == null) return;
    
    List<dynamic> queue = jsonDecode(queueJson);
    
    for (var session in queue) {
      try {
        await _saveToPod(session);
      } catch (e) {
        debugPrint('Failed to sync session: $e');
        return; // Stop syncing if one fails
      }
    }
    
    // Clear queue after successful sync
    await prefs.remove(_queueKey);
  }
  
  static Future<void> _saveToPod(Map<String, dynamic> session) async {
    String? content = await readPod('sessions.json');
    List<dynamic> sessions = [];
    if (content != null && content.isNotEmpty) {
      sessions = jsonDecode(content);
    }
    sessions.add(session);
    await writePod('sessions.json', jsonEncode(sessions));
  }
  
  static Future<void> _addToQueue(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);
    
    List<dynamic> queue = [];
    if (queueJson != null) {
      queue = jsonDecode(queueJson);
    }
    
    queue.add(session);
    await prefs.setString(_queueKey, jsonEncode(queue));
  }
}
```

**Dependencies:**
```yaml
dependencies:
  connectivity_plus: ^5.0.0
  shared_preferences: ^2.2.0
```

**Effort:** 🔴 High (12-16 hours)

---

### 10. Session Reminders

**Enhancement:** Daily notifications to remind users to meditate

**Features:**
- Customizable reminder time
- Multiple reminders per day
- Smart reminders (skip if already meditated)
- Motivational quotes in notifications

**Implementation:**
```dart
// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }
  
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0,
      'Time to Meditate',
      'Take a moment for your inner peace 🧘',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meditation_reminder',
          'Meditation Reminders',
          channelDescription: 'Daily meditation reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}
```

**Dependencies:**
```yaml
dependencies:
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.0
```

**Effort:** 🔴 High (10-14 hours)

---

## 📊 Implementation Priority Matrix

| Feature | Impact | Effort | Priority |
|---------|--------|--------|----------|
| Session Duration | High | Low | ⭐⭐⭐⭐⭐ |
| Session Type | High | Low | ⭐⭐⭐⭐⭐ |
| Total Statistics | High | Medium | ⭐⭐⭐⭐ |
| Session Notes | Medium | Medium | ⭐⭐⭐ |
| Export CSV | Medium | Medium | ⭐⭐⭐ |
| Calendar View | High | Medium | ⭐⭐⭐⭐ |
| Charts | Medium | High | ⭐⭐ |
| Streak Tracking | High | High | ⭐⭐⭐⭐ |
| Offline Sync | High | High | ⭐⭐⭐⭐ |
| Reminders | Medium | High | ⭐⭐⭐ |

## 🎯 Recommended Implementation Order

### Phase 1: Quick Wins (Week 1)
1. Session Duration Display
2. Session Type Tracking
3. Total Statistics Display

### Phase 2: Enhanced UX (Week 2-3)
4. Session Notes
5. Export to CSV
6. Calendar View

### Phase 3: Advanced Features (Week 4-6)
7. Streak Tracking
8. Offline Queue & Sync
9. Data Visualization Charts
10. Session Reminders

---

## 🛠️ Development Tips

### Testing Session Recording

```dart
// Create test sessions programmatically
Future<void> _createTestSessions() async {
  final testSessions = [
    {
      'start': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'end': DateTime.now().subtract(Duration(days: 5, minutes: -20)).toIso8601String(),
      'type': 'start',
    },
    {
      'start': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
      'end': DateTime.now().subtract(Duration(days: 4, minutes: -25)).toIso8601String(),
      'type': 'guided',
    },
    // Add more test sessions
  ];
  
  await writePod('sessions.json', jsonEncode(testSessions));
}
```

### Debugging Pod Storage

```dart
// Read and print current sessions
Future<void> _debugSessions() async {
  String? content = await readPod('sessions.json');
  debugPrint('Current sessions: $content');
}
```

### Performance Considerations

- Cache session data locally to reduce Pod reads
- Implement pagination for large session lists
- Use `ListView.builder` for efficient rendering
- Consider lazy loading for charts

---

## 📝 Notes

- All enhancements should maintain backward compatibility with existing session data
- Consider data migration strategies when changing session format
- Test thoroughly with and without Pod connection
- Ensure offline functionality remains robust
- Follow existing code style and patterns

---

**Questions or suggestions?** Open an issue on GitHub!
