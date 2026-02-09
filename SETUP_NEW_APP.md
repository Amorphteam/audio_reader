# Setting Up Audio Player Package in a New App

This guide will walk you through adding the audio player package to a new Flutter app.

## Step 1: Add Package Dependency

Add the package to your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Audio Player Package
  audio_player:
    git:
      url: https://github.com/Amorphteam/audio_reader.git
      ref: v0.0.1-beta
      path: packages/audio_player
  
  # Required dependencies (if not already in your pubspec.yaml)
  flutter_bloc: ^8.0.0
  modal_bottom_sheet: ^3.0.0
```

Then run:
```bash
flutter pub get
```

## Step 2: Android Setup

### 2.1 Add Notification Icon

Copy the notification icon to your Android app:

```bash
# Copy from package (if you have it locally)
cp ../audio_player_package/packages/audio_player/android/app/src/main/res/drawable/ic_notification.xml \
   android/app/src/main/res/drawable/

# Or create your own notification icon
```

Create `android/app/src/main/res/drawable/ic_notification.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M8,5v14l11,-7z"/>
</vector>
```

### 2.2 Update AndroidManifest.xml (if needed)

The `audio_service` package should handle permissions automatically, but verify your `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

## Step 3: iOS Setup

Add background audio capability in `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## Step 4: Create Audio Integration

Create the integration folder structure:

```
lib/
  └── audio_integration/
      ├── audio_adapter_factory.dart
      └── player_adapters.dart
```

### 4.1 Create `lib/audio_integration/player_adapters.dart`:

```dart
import 'package:audio_player/audio_player.dart' as audio_player;
import 'package:flutter/material.dart';
import '../route_generator.dart'; // Adjust path to your route_generator

/// Creates the audio player interactions implementation for the app.
audio_player.AudioPlayerInteractions createAudioPlayerInteractions() {
  return AppAudioPlayerInteractions();
}

class AppAudioPlayerInteractions implements audio_player.AudioPlayerInteractions {
  @override
  void openPlayer(
    BuildContext context, {
    required List<audio_player.AudioTrack> tracks,
    int? startIndex,
  }) {
    // Use route_generator for consistent navigation
    Navigator.pushNamed(
      context,
      '/audioPlayer',
      arguments: {
        'tracks': tracks,
        'initialIndex': startIndex,
      },
    );
  }

  @override
  void playTrack(BuildContext context, audio_player.AudioTrack track) {
    openPlayer(context, tracks: [track]);
  }

  @override
  void playPlaylist(
    BuildContext context,
    List<audio_player.AudioTrack> tracks, {
    int? startIndex,
  }) {
    openPlayer(context, tracks: tracks, startIndex: startIndex);
  }
}
```

### 4.2 Create `lib/audio_integration/audio_adapter_factory.dart`:

```dart
library audio_adapter_factory;

export 'player_adapters.dart';
```

## Step 5: Add Route to Route Generator

Add the `/audioPlayer` route to your `route_generator.dart`:

```dart
import 'package:audio_player/audio_player.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// In your RouteGenerator.generateRoute() method:
case '/audioPlayer':
  if (args != null) {
    final List<AudioTrack> tracks = args['tracks'] as List<AudioTrack>;
    final int? initialIndex = args['initialIndex'] as int?;
    
    // Show as modal bottom sheet
    return MaterialPageRoute(
      builder: (context) {
        // Show bottom sheet immediately when route is pushed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final content = BlocProvider(
            create: (context) => AudioPlayerCubit(),
            child: AudioPlayerScreen(
              tracks: tracks,
              initialIndex: initialIndex,
            ),
          );
          
          if (Platform.isIOS) {
            showCupertinoModalBottomSheet(
              useRootNavigator: true,
              context: context,
              expand: true,
              backgroundColor: Colors.transparent,
              builder: (context) => content,
            ).then((_) {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          } else {
            showMaterialModalBottomSheet(
              context: context,
              expand: true,
              backgroundColor: Colors.transparent,
              builder: (context) => content,
            ).then((_) {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
        });
        
        return const SizedBox.shrink();
      },
      fullscreenDialog: false,
    );
  }
  return _errorRoute();
```

**Note**: Make sure your `MaterialApp` uses `onGenerateRoute: RouteGenerator.generateRoute`.

## Step 6: Initialize in main.dart

### Option A: Use Package Directly (Recommended - No Wrapper Needed)

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:audio_player/audio_player.dart' as audio_player;
import 'audio_integration/audio_adapter_factory.dart' as audio_adapters;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio helper with app-specific interactions
  audio_player.AudioHelper.initialize(
    audio_adapters.createAudioPlayerInteractions()
  );
  
  runApp(MyApp());
}
```

Then use directly:
```dart
import 'package:audio_player/audio_player.dart' as audio_player;

// Create track
final track = audio_player.AudioHelper.createTrack(
  id: '1', title: 'Song', url: 'https://...'
);

// Play track
audio_player.AudioHelper.playTrack(context, track);
```

**No wrapper needed!** The package's `AudioHelper` is sufficient.

## Step 7: Use the Audio Player

### 7.1 Play a Single Track

```dart
import 'package:audio_player/audio_player.dart' as audio_player;

// Create a track
final track = audio_player.AudioHelper.createTrack(
  id: 'track1',
  title: 'My Song',
  url: 'https://example.com/song.mp3',
  artist: 'Artist Name',
  artworkUrl: 'https://example.com/artwork.jpg',
);

// Play it (uses route_generator internally)
audio_player.AudioHelper.playTrack(context, track);
```

### 7.2 Play a Playlist

```dart
final tracks = [
  audio_player.AudioHelper.createTrack(id: '1', title: 'Song 1', url: 'https://...'),
  audio_player.AudioHelper.createTrack(id: '2', title: 'Song 2', url: 'https://...'),
];

// Play playlist (uses route_generator internally)
audio_player.AudioHelper.playPlaylist(context, tracks, startIndex: 0);
```

### 7.3 Add Mini Player Widget

Add to your scaffold:

```dart
import 'package:audio_player/audio_player.dart';

Scaffold(
  body: YourContent(),
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      YourBottomNav(),
      AudioPlayerMini(), // Mini player appears when audio is playing
    ],
  ),
)
```

## Step 8: Customize (Optional)

### Custom Audio Service Configuration

If you want to customize the notification settings:

```dart
import 'package:audio_player/audio_player.dart';
import 'package:flutter/material.dart';

// In your app initialization
await AudioServiceManager().initialize(
  config: AudioServiceConfig(
    androidNotificationChannelId: 'com.yourapp.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationChannelDescription: 'Audio playback controls',
    androidNotificationIcon: 'drawable/ic_notification',
    notificationColor: Colors.blue,
  ),
);
```

### Custom Navigation

Modify `lib/audio_integration/player_adapters.dart` to customize how the player opens. Currently it uses `Navigator.pushNamed('/audioPlayer')` which shows as a bottom sheet via route_generator. You can change it to:

- Full-screen route: `Navigator.pushNamed('/audioPlayer', ...)` and modify route_generator to return a full-screen route
- Direct bottom sheet: Use `showCupertinoModalBottomSheet` or `showMaterialModalBottomSheet` directly
- Custom navigation: Any navigation pattern you prefer

## Summary Checklist

- [ ] Added package to `pubspec.yaml`
- [ ] Ran `flutter pub get`
- [ ] Added Android notification icon (`ic_notification.xml`)
- [ ] Added iOS background mode (`UIBackgroundModes` → `audio`)
- [ ] Created `audio_integration` folder with adapters
- [ ] Added `/audioPlayer` route to `route_generator.dart`
- [ ] Initialized in `main.dart` (with interactions)
- [ ] Tested playing a track

## Troubleshooting

### Notification not showing on Android
- Verify `ic_notification.xml` exists in `android/app/src/main/res/drawable/`
- Check notification permissions are granted
- Verify `androidNotificationIcon` matches your icon name

### Audio stops when app backgrounds
- Ensure iOS `Info.plist` has `UIBackgroundModes` → `audio`
- Check Android manifest has proper permissions

### Package not found
- Verify the GitHub URL and tag are correct
- Run `flutter pub get` again
- Check your internet connection

## Example: Complete Integration

See the `z_platform` app for a complete working example:
- Integration: `lib/audio_integration/player_adapters.dart`
- Route: `lib/route_generator.dart` (see `/audioPlayer` case)
- Usage: `lib/screen/library/library_screen.dart`
- Initialization: `lib/main.dart`
