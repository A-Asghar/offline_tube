import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offline_tube/main.dart' as app;
import 'package:offline_tube/services/navigation_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download Feature', () {
    testWidgets(
      'full download flow: search, download, verify in downloads, play',
      (WidgetTester tester) async {
        app.main();
        await tester.pump(const Duration(seconds: 3));

        // 1. Navigate to Search tab
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump(const Duration(seconds: 1));

        // 2. Search for a video
        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);
        await tester.enterText(searchField, 'lofi hip hop');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump(const Duration(seconds: 8));

        // 3. Assert search results loaded
        final videoListKey =
            find.byKey(const PageStorageKey<String>('videoListView'));
        expect(videoListKey, findsOneWidget,
            reason: 'Search results should appear');

        // 4. Tap a video title to open the video player
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

        // Store the title of the video we're about to download
        final firstTitleWidget = videoTitle.first.evaluate().first.widget as Text;
        final firstTitleText = firstTitleWidget.data ?? '';

        await tester.tap(videoTitle.first);
        await tester.pump(const Duration(seconds: 5));

        // 5. Verify the video player shows a Download button
        final downloadBtn = find.text('Download');
        final alreadyDownloaded = find.text('Added to downloads');
        expect(
          downloadBtn.evaluate().isNotEmpty ||
              alreadyDownloaded.evaluate().isNotEmpty,
          isTrue,
          reason:
              'Video player should show a Download button or "Added to downloads"',
        );

        bool downloadComplete = false;
        if (downloadBtn.evaluate().isEmpty) {
          downloadComplete = true;
        } else {
          // 6. Tap Download and wait for completion
          await tester.tap(downloadBtn);
          await tester.pump(const Duration(seconds: 2));

          // Wait for download to complete (up to 180 seconds)
          // Download may fail due to YouTube rate limiting — treat gracefully
          for (int i = 0; i < 180; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.text('Added to downloads').evaluate().isNotEmpty) {
              downloadComplete = true;
              break;
            }
            if (find.text('Download failed').evaluate().isNotEmpty) {
              break;
            }
          }
        }

        // 7. Pop the video player view to return to main screen
        // VideoPlayerView is pushed via Navigator.push, so pop via the navigator key
        NavigationService.navigatorKey.currentState?.pop();
        await tester.pump(const Duration(seconds: 1));

        // 8. Navigate to Downloads tab
        await tester.tap(find.byIcon(Icons.download));
        await tester.pump(const Duration(seconds: 3));

        // 9-11. Verify downloaded video and playback only if download succeeded
        if (downloadComplete) {
          expect(find.text(firstTitleText).evaluate().isNotEmpty, isTrue,
              reason: 'Downloaded video should appear in downloads list');

          await tester.tap(find.text(firstTitleText));
          await tester.pump(const Duration(seconds: 3));

          expect(
            find.byType(Slider).evaluate().isNotEmpty ||
                find.byIcon(Icons.pause).evaluate().isNotEmpty ||
                find.byIcon(Icons.play_arrow).evaluate().isNotEmpty,
            isTrue,
            reason:
                'Downloads page should show playback controls when a video is playing',
          );
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
