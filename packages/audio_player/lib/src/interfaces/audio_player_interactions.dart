import 'package:flutter/material.dart';
import '../models/audio_track_model.dart';

/// Interface for app-specific interactions with the audio player.
/// 
/// Implement this interface in your app to customize behavior like:
/// - Navigation when opening the player
/// - Custom bottom sheet presentation
/// - Analytics tracking
/// - Error handling
abstract class AudioPlayerInteractions {
  /// Called when the audio player should be opened.
  /// 
  /// [context] - The build context
  /// [tracks] - List of tracks to play
  /// [startIndex] - Optional starting track index
  void openPlayer(
    BuildContext context, {
    required List<AudioTrack> tracks,
    int? startIndex,
  });

  /// Called when a single track should be played.
  /// 
  /// Default implementation calls [openPlayer] with a single track.
  void playTrack(BuildContext context, AudioTrack track) {
    openPlayer(context, tracks: [track]);
  }

  /// Called when a playlist should be played.
  /// 
  /// Default implementation calls [openPlayer] with the tracks.
  void playPlaylist(
    BuildContext context,
    List<AudioTrack> tracks, {
    int? startIndex,
  }) {
    openPlayer(context, tracks: tracks, startIndex: startIndex);
  }
}
