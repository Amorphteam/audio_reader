import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'models/audio_track_model.dart';
import 'audio_player_screen.dart';
import 'cubit/audio_player_cubit.dart';
import 'interfaces/audio_player_interactions.dart';

/// Default implementation of AudioPlayerInteractions using modal bottom sheets
class DefaultAudioPlayerInteractions implements AudioPlayerInteractions {
  @override
  void openPlayer(
    BuildContext context, {
    required List<AudioTrack> tracks,
    int? startIndex,
  }) {
    final content = BlocProvider(
      create: (context) => AudioPlayerCubit(),
      child: AudioPlayerScreen(
        tracks: tracks,
        initialIndex: startIndex,
      ),
    );
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        useRootNavigator: true,
        context: context,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => content,
      );
    } else {
      showMaterialModalBottomSheet(
        context: context,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => content,
      );
    }
  }
}

/// Helper functions for audio player operations
/// 
/// This class provides convenient static methods for playing audio.
/// You can customize the behavior by implementing [AudioPlayerInteractions]
/// and setting it via [AudioHelper.setInteractions].
class AudioHelper {
  static AudioPlayerInteractions _interactions = DefaultAudioPlayerInteractions();
  
  /// Set custom interactions implementation
  static void setInteractions(AudioPlayerInteractions interactions) {
    _interactions = interactions;
  }
  
  /// Get current interactions implementation
  static AudioPlayerInteractions get interactions => _interactions;

  /// Open audio player with a single track
  static void playTrack(
    BuildContext context,
    AudioTrack track,
  ) {
    _interactions.playTrack(context, track);
  }

  /// Open audio player with a playlist
  static void playPlaylist(
    BuildContext context,
    List<AudioTrack> tracks, {
    int? startIndex,
  }) {
    _interactions.playPlaylist(context, tracks, startIndex: startIndex);
  }

  /// Create an AudioTrack from a URL
  static AudioTrack createTrack({
    required String id,
    required String title,
    required String url,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      url: url,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      duration: duration,
    );
  }
}
