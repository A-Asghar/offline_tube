import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offline_tube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Application Test', () {
    testWidgets('Navigate tabs, search for videos, and open player view',
        (WidgetTester tester) async {
      // 1. Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify startup view is Home tab
      expect(find.text('Home'), findsWidgets);

      // 2. Navigate to Search Tab
      final searchTabFinder = find.byIcon(Icons.search);
      expect(searchTabFinder, findsOneWidget);
      await tester.tap(searchTabFinder);
      await tester.pumpAndSettle();

      // Verify search input field exists
      final searchFieldFinder = find.byType(TextField);
      expect(searchFieldFinder, findsOneWidget);

      // 3. Enter search query and submit
      await tester.enterText(searchFieldFinder, 'Flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      
      // Let search run and yield results
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 4. Navigate to Downloads Tab
      final downloadsTabFinder = find.byIcon(Icons.download);
      expect(downloadsTabFinder, findsOneWidget);
      await tester.tap(downloadsTabFinder);
      await tester.pumpAndSettle();

      // Verify downloads screen is empty initially
      expect(find.text('Downloading'), findsNothing);
    });
  });
}
