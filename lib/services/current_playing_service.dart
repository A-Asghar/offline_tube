import 'package:audio_service/audio_service.dart';
import 'package:stacked/stacked.dart';
import 'package:observable_ish/observable_ish.dart';

class CurrentPlayingService with ListenableServiceMixin {
  static final CurrentPlayingService _instance =
      CurrentPlayingService._internal();

  factory CurrentPlayingService() {
    return _instance;
  }

  CurrentPlayingService._internal() {
    listenToReactiveValues([
      progressBarState,
      playing,
    ]);
  }

  RxValue<ProgressBarState> progressBarState = RxValue<ProgressBarState>(
    const ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  RxValue<MediaItem?> playing = RxValue<MediaItem?>(null);

  RxValue<ButtonState> playPauseButtonState = RxValue<ButtonState>(
    ButtonState.playing,
  );
}

class ProgressBarState {
  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState {
  paused,
  playing,
  loading,
}
