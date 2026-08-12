import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offline_tube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bottom Navigation Bar', () {
    testWidgets('all 3 navigation options are available and navigable',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify all 3 BottomNavigationBarItems are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);

      // 2. Home tab should be active by default
      final homeIcon = find.byIcon(Icons.home);
      expect(homeIcon, findsOneWidget);

      // 3. Navigate to Search tab
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      // Verify the SearchView's TextField appeared
      expect(find.byType(TextField), findsOneWidget);

      // 4. Navigate to Downloads tab
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();
      // Verify we're on the Downloads screen
      expect(find.text('Downloads'), findsOneWidget);

      // 5. Navigate back to Home tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      // Verify we're back on the Home screen
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
