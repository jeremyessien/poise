import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

void main() {
  group('calm', () {
    const calm = PoiseMotion.calm;

    final timedWords = {
      'feedback': calm.feedback,
      'enter': calm.enter,
      'exit': calm.exit,
      'transition': calm.transition,
      'change': calm.change,
      'attention': calm.attention,
      'celebrate': calm.celebrate,
    };

    test('things leave faster than they arrive', () {
      expect(calm.exit.duration, lessThan(calm.enter.duration));
    });

    test('feedback feels like the quickest motion', () {
      Duration feltDuration(Feel feel) => switch (feel) {
        Move(:final perceivedDuration) => perceivedDuration,
        Fade(:final duration) => duration,
      };

      for (final MapEntry(key: word, value: feel) in timedWords.entries) {
        if (word == 'feedback') continue;
        expect(
          feltDuration(calm.feedback),
          lessThanOrEqualTo(feltDuration(feel)),
          reason: word,
        );
      }
    });

    test('only attention bounces', () {
      for (final MapEntry(key: word, value: feel) in timedWords.entries) {
        final bounces = switch (feel) {
          Move(:final bounce) => bounce > 0,
          Fade() => false,
        };
        expect(bounces, word == 'attention', reason: word);
      }
    });
  });

  test('copyWith changes one word and keeps the rest', () {
    const slowerEnter = Move(perceivedDuration: Duration(milliseconds: 500));
    final adjusted = PoiseMotion.calm.copyWith(enter: slowerEnter);

    expect(adjusted.enter, same(slowerEnter));
    expect(adjusted.exit, same(PoiseMotion.calm.exit));
    expect(adjusted.follow, same(PoiseMotion.calm.follow));
    expect(adjusted.stagger, PoiseMotion.calm.stagger);
  });
}
