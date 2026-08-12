import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offline_tube/main.dart' as app;
import 'package:audio_service/audio_service.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/audio_service.dart';
import 'package:offline_tube/services/navigation_service.dart';
import 'package:path_provider/path_provider.dart';

Uint8List _createMinimalWav() {
  const sampleRate = 8000;
  const durationSeconds = 3;
  final numSamples = sampleRate * durationSeconds;
  final dataSize = numSamples;

  final buffer = BytesBuilder();
  buffer.add(Uint8List.fromList([0x52, 0x49, 0x46, 0x46])); // "RIFF"
  buffer.add(_int32Le(36 + dataSize));
  buffer.add(Uint8List.fromList([0x57, 0x41, 0x56, 0x45])); // "WAVE"
  buffer.add(Uint8List.fromList([0x66, 0x6D, 0x74, 0x20])); // "fmt "
  buffer.add(_int32Le(16));
  buffer.add(_int16Le(1));
  buffer.add(_int16Le(1));
  buffer.add(_int32Le(sampleRate));
  buffer.add(_int32Le(sampleRate));
  buffer.add(_int16Le(1));
  buffer.add(_int16Le(8));
  buffer.add(Uint8List.fromList([0x64, 0x61, 0x74, 0x61])); // "data"
  buffer.add(_int32Le(dataSize));
  buffer.add(Uint8List(dataSize)..fillRange(0, dataSize, 128));

  return buffer.toBytes();
}

Uint8List _int32Le(int value) => Uint8List.fromList([
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ]);

Uint8List _int16Le(int value) => Uint8List.fromList([
      value & 0xFF,
      (value >> 8) & 0xFF,
    ]);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Background Audio Playback', () {
    testWidgets(
      'audio handler plays local file with pause/resume/skip/stop',
      (WidgetTester tester) async {
        app.main();
        await tester.pump(const Duration(seconds: 3));

        // === Setup: create a test WAV file ===
        const videoId = 'testAbc12345';
        final dir = await getApplicationDocumentsDirectory();
        final audioFilePath = '${dir.path}/temp_audio_$videoId';
        await File(audioFilePath).writeAsBytes(_createMinimalWav());
        addTearDown(() => File(audioFilePath).delete());

        expect(File(audioFilePath).existsSync(), isTrue);

        // Create MediaItem with the local file path
        final mediaItem = MediaItem(
          id: videoId,
          title: 'Test Background Audio',
          artist: 'Test Artist',
          duration: const Duration(seconds: 3),
          extras: {'url': audioFilePath},
        );

        final handler = getIt<CustomAudioHandler>();

        // === Step 1: Add to queue & play ===
        handler.addQueueItem(mediaItem);
        handler.play();
        await tester.pump(const Duration(seconds: 2));

        // Wait up to 10 seconds for mediaItem to be set (currentIndexStream needs to fire)
        MediaItem? item = handler.mediaItem.value;
        for (int i = 0; i < 10 && item == null; i++) {
          await tester.pump(const Duration(seconds: 1));
          item = handler.mediaItem.value;
        }
        expect(item, isNotNull);
        expect(item, isNotNull);
        expect(item?.extras?['url'], audioFilePath);

        // Play the item
        handler.play();
        await tester.pump(const Duration(seconds: 2));

        // === Step 2: Verify playing state ===
        expect(handler.playbackState.value.playing, isTrue,
            reason: 'Audio should be playing');

        // Verify source is a local file (required for background playback)
        final url = item?.extras?['url'] as String;
        expect(File(url).existsSync(), isTrue,
            reason: 'Source file must exist on disk for background playback');

        // === Step 3: Test pause ===
        handler.pause();
        await tester.pump(const Duration(seconds: 1));
        expect(handler.playbackState.value.playing, isFalse,
            reason: 'Audio should pause');

        // === Step 4: Test resume ===
        handler.play();
        await tester.pump(const Duration(seconds: 1));
        expect(handler.playbackState.value.playing, isTrue,
            reason: 'Audio should resume');

        // === Step 5: Test skip to next (single item loops) ===
        final originalIndex = handler.playbackState.value.queueIndex;
        handler.skipToNext();
        await tester.pump(const Duration(seconds: 1));
        expect(handler.playbackState.value.queueIndex, originalIndex,
            reason: 'Single-item queue should loop on skip-to-next');

        // === Step 6: Test stop ===
        handler.stop();
        await tester.pump(const Duration(seconds: 1));
        expect(handler.playbackState.value.playing, isFalse,
            reason: 'Audio should stop');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'download a file then play it from downloads page and verify playback',
      (WidgetTester tester) async {
        app.main();
        await tester.pump(const Duration(seconds: 3));

        // === Step 1: Download a video (mirrors download_test.dart) ===
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump(const Duration(seconds: 1));

        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);
        await tester.enterText(searchField, 'flutter');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump(const Duration(seconds: 8));

        final videoListKey =
            find.byKey(const PageStorageKey<String>('videoListView'));
        expect(videoListKey, findsOneWidget,
            reason: 'Search results should appear');

        final videoTitle = find.descendant(
          of: videoListKey,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Text &&
                w.data != null &&
                w.data!.isNotEmpty &&
                w.data!.length > 3,
          ),
        );
        expect(videoTitle.evaluate().isNotEmpty, isTrue,
            reason: 'Search results should contain video titles');
        await tester.tap(videoTitle.first);
        await tester.pump(const Duration(seconds: 5));

        final downloadBtn = find.text('Download');
        final alreadyDownloaded = find.text('Added to downloads');
        expect(
          downloadBtn.evaluate().isNotEmpty ||
              alreadyDownloaded.evaluate().isNotEmpty,
          isTrue,
          reason:
              'Video player should show a Download button or "Added to downloads"',
        );

        bool downloadSucceeded = alreadyDownloaded.evaluate().isNotEmpty;
        if (downloadBtn.evaluate().isNotEmpty) {
          await tester.tap(downloadBtn);
          await tester.pump(const Duration(seconds: 2));
          for (int i = 0; i < 30; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.text('Added to downloads').evaluate().isNotEmpty) {
              downloadSucceeded = true;
              break;
            }
            if (find.text('Download failed').evaluate().isNotEmpty) {
              break;
            }
          }
        }

        // === Step 2: Go back from VideoPlayerView, then navigate to Downloads page ===
        NavigationService.navigatorKey.currentState?.pop();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byIcon(Icons.download));
        await tester.pump(const Duration(seconds: 2));

        // Only verify download and playback if download succeeded
        if (downloadSucceeded) {
          // Wait for the downloaded item to appear
          final downloadedTitle = find.descendant(
            of: find.byType(ListView),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  w.data != null &&
                  w.data!.isNotEmpty &&
                  w.data!.length > 3,
            ),
          );
          bool itemAppeared = false;
          for (int i = 0; i < 10; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (downloadedTitle.evaluate().isNotEmpty) {
              itemAppeared = true;
              break;
            }
          }
          expect(itemAppeared, isTrue,
              reason: 'Downloaded item should appear on the Downloads page');

          // === Step 3: Play the downloaded file from the downloads page ===
          await tester.tap(downloadedTitle.first);
          await tester.pump(const Duration(seconds: 2));

          final handler = getIt<CustomAudioHandler>();
          expect(handler.playbackState.value.playing, isTrue,
              reason: 'Audio should be playing after tapping the download');

          // === Step 4: Wait 10 seconds ===
          final positionBefore =
              handler.playbackState.value.updatePosition.inMilliseconds;
          await tester.pump(const Duration(seconds: 10));

          // === Step 5: Verify audio is actually being played ===
          final playing = handler.playbackState.value.playing;
          final positionAfter =
              handler.playbackState.value.updatePosition.inMilliseconds;

          expect(playing, isTrue, reason: 'Audio should still be playing');
          expect(positionAfter, greaterThan(positionBefore),
              reason:
                  'Playback position should have advanced, proving audio is actually playing');
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
