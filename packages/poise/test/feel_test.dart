import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

void main() {
  const bounces = [0.0, 0.15, 0.3, 0.5];
  const perceivedDurations = [
    Duration(milliseconds: 150),
    Duration(milliseconds: 300),
    Duration(milliseconds: 500),
  ];

  final moves = [
    for (final perceivedDuration in perceivedDurations)
      for (final bounce in bounces)
        Move(perceivedDuration: perceivedDuration, bounce: bounce),
  ];

  String describe(Move move) =>
      '${move.perceivedDuration.inMilliseconds}ms, bounce ${move.bounce}';

  group('Move', () {
    test('lands on the target without a visible snap at the end', () {
      for (final move in moves) {
        final justBeforeTheEnd = move.curve.transform(0.999);
        expect(justBeforeTheEnd, closeTo(1, 0.002), reason: describe(move));
      }
    });

    test('starts where it should', () {
      for (final move in moves) {
        expect(
          move.curve.transform(0.001),
          closeTo(0, 0.01),
          reason: describe(move),
        );
      }
    });

    test('runs at least as long as it is perceived to take', () {
      for (final move in moves) {
        expect(
          move.settleDuration,
          greaterThanOrEqualTo(move.perceivedDuration),
          reason: describe(move),
        );
      }
    });

    test('overshoots only when it has bounce', () {
      for (final move in moves) {
        final peak = [
          for (var step = 0; step <= 1000; step++)
            move.curve.transform(step / 1000),
        ].reduce((a, b) => a > b ? a : b);

        if (move.bounce == 0) {
          expect(peak, lessThanOrEqualTo(1.001), reason: describe(move));
        } else {
          expect(peak, greaterThan(1.001), reason: describe(move));
        }
      }
    });
  });

  group('Fade', () {
    test('default curve never overshoots', () {
      const fade = Fade(duration: Duration(milliseconds: 200));
      for (var step = 0; step <= 1000; step++) {
        expect(fade.curve.transform(step / 1000), lessThanOrEqualTo(1));
      }
    });
  });
}
