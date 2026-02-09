# Audio Player Package

A reusable Flutter audio player package with background playback, notifications, and lock screen controls.

## Features

- 🎵 Background audio playback
- 📱 Media notifications (Android & iOS)
- 🔒 Lock screen controls
- 🎛️ Playback speed control
- 📋 Playlist support
- 🎨 Beautiful UI with blur effects
- 🔄 Auto-play next track
- ⏪⏩ 15-second seek controls

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  audio_player:
    path: ../audio_player_package/packages/audio_player
```

Or if published to GitHub:

```yaml
dependencies:
  audio_player:
    git:
      url: https://github.com/yourusername/audio_player_package.git
      path: packages/audio_player
      ref: v0.1.0
```

## Usage

### Basic Setup

1. Initialize the audio service in your app:


```dart
import 'package:audio_player/audio_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Audio service will be initialized lazily when needed
  runApp(MyApp());
}
```

2. Configure Android notification (in your app's `android/app/src/main/res/drawable/`):
   - Copy `ic_notification.xml` from the package or create your own
   - Update the `androidNotificationIcon` in `AudioServiceConfig` if using a different name

3. Configure iOS (in `ios/Runner/Info.plist`):
   - Ensure `UIBackgroundModes` includes `audio`:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>audio</string>
   </array>
   ```

### Playing Audio

```dart
import 'package:audio_player/audio_player.dart';

// Create a track
final track = AudioHelper.createTrack(
  id: 'track1',
  title: 'My Song',
  url: 'https://example.com/song.mp3',
  artist: 'Artist Name',
  artworkUrl: 'https://example.com/artwork.jpg',
);

// Play a single track
AudioHelper.playTrack(context, track);

// Play a playlist
final tracks = [track1, track2, track3];
AudioHelper.playPlaylist(context, tracks, startIndex: 0);
```

### Custom Interactions

Implement `AudioPlayerInteractions` to customize how the player opens:

```dart
class MyAudioInteractions implements AudioPlayerInteractions {
  @override
  void openPlayer(BuildContext context, {required List<AudioTrack> tracks, int? startIndex}) {
    // Custom navigation or presentation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AudioPlayerCubit(),
          child: AudioPlayerScreen(
            tracks: tracks,
            initialIndex: startIndex,
          ),
        ),
      ),
    );
  }
}

// Set it globally
AudioHelper.setInteractions(MyAudioInteractions());
```

### Mini Player Widget

Add the mini player to your scaffold:

```dart
Scaffold(
  body: YourContent(),
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      YourBottomNav(),
      AudioPlayerMini(), // Add mini player
    ],
  ),
)
```

### Custom Audio Service Configuration

```dart
import 'package:audio_player/audio_player.dart';

// Initialize with custom config
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

## API Reference

### AudioTrack

```dart
AudioTrack({
  required String id,
  required String title,
  required String url,
  String? artist,
  String? album,
  String? artworkUrl,
  Duration? duration,
  bool isPlaying = false,
})
```

### AudioHelper

- `playTrack(BuildContext, AudioTrack)` - Play a single track
- `playPlaylist(BuildContext, List<AudioTrack>, {int? startIndex})` - Play a playlist
- `createTrack({...})` - Create an AudioTrack
- `setInteractions(AudioPlayerInteractions)` - Set custom interactions

### AudioPlayerCubit

- `initialize()` - Initialize the audio handler
- `loadTracks(List<AudioTrack>, {int? startIndex})` - Load tracks
- `togglePlayPause()` - Toggle play/pause
- `skipToNext()` - Skip to next track
- `skipToPrevious()` - Skip to previous track
- `seek(Duration)` - Seek to position
- `seekForward15()` - Seek forward 15 seconds
- `seekBackward15()` - Seek backward 15 seconds
- `setSpeed(double)` - Set playback speed (0.5x - 3.0x)

## License

MIT
