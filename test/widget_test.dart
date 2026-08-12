import 'package:flutter_test/flutter_test.dart';
import 'package:offline_tube/util/util.dart';

void main() {
  group('Utility functions tests', () {
    test('formatDuration tests', () {
      expect(formatDuration(const Duration(seconds: 5)), '00:05');
      expect(formatDuration(const Duration(minutes: 2, seconds: 15)), '02:15');
      expect(formatDuration(const Duration(hours: 1, minutes: 5, seconds: 9)), '01:05:09');
    });

    test('formatCount tests', () {
      expect(formatCount(500), '500');
      expect(formatCount(1500), '1.50K');
      expect(formatCount(2500000), '2.50M');
      expect(formatCount(3000000000), '3.00B');
    });

    test('cutText tests', () {
      expect(cutText(size: 10, text: 'Hello World'), 'Hello Worl...');
      expect(cutText(size: 20, text: 'Short'), 'Short');
    });
  });
}
