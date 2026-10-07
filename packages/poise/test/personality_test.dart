import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

Duration feltDuration(Feel feel) => switch (feel) {
  Move(:final perceivedDuration) => perceivedDuration,
  Fade(:final duration) => duration,
};

bool bounces(Feel feel) => switch (feel) {
  Move(:final bounce) => bounce > 0,
  Fade() => false,
};

Map<String, Feel> timedWords(PoiseMotion motion) => {
  'feedback': motion.feedback,
  'enter': motion.enter,
  'exit': motion.exit,
  'transition': motion.transition,
  'change': motion.change,
  'attention': motion.attention,
  'celebrate': motion.celebrate,
};

void main() {
  const personalities = {
    'calm': PoiseMotion.calm,
    'crisp': PoiseMotion.crisp,
    'playful': PoiseMotion.playful,
  };

  for (final MapEntry(key: name, value: motion) in personalities.entries) {
    group('$name keeps the promises every personality makes:', () {
      test('things leave faster than they arrive', () {
        expect(motion.exit.duration, lessThan(motion.enter.duration));
      });

      test('feedback feels like the quickest motion', () {
        for (final MapEntry(key: word, value: feel) in timedWords(
          motion,
        ).entries) {
          if (word == 'feedback') continue;
          expect(
            feltDuration(motion.feedback),
            lessThanOrEqualTo(feltDuration(feel)),
            reason: word,
          );
        }
      });

      test('exits never bounce', () {
        expect(bounces(motion.exit), isFalse);
      });
    });
  }

  for (final (name, motion) in [
    ('calm', PoiseMotion.calm),
    ('crisp', PoiseMotion.crisp),
  ]) {
    test('$name bounces only for attention', () {
      for (final MapEntry(key: word, value: feel) in timedWords(
        motion,
      ).entries) {
        expect(bounces(feel), word == 'attention', reason: word);
      }
    });
  }

  test('crisp is quicker than calm everywhere', () {
    final calm = timedWords(PoiseMotion.calm);
    for (final MapEntry(key: word, value: crispFeel) in timedWords(
      PoiseMotion.crisp,
    ).entries) {
      if (calm[word] case final calmFeel?) {
        expect(
          feltDuration(crispFeel),
          lessThan(feltDuration(calmFeel)),
          reason: word,
        );
      } else {
        fail('calm has no $word');
      }
    }
  });

  test('playful bounces on touch, arrival and celebration', () {
    const playful = PoiseMotion.playful;
    expect([
      playful.feedback,
      playful.enter,
      playful.celebrate,
    ], everyElement(predicate<Feel>(bounces, 'bounces')));
  });

  group('reduced', () {
    const reduced = PoiseMotion.reduced;

    test('nothing travels except what the finger is driving', () {
      final timed = [
        reduced.feedback,
        reduced.enter,
        reduced.exit,
        reduced.transition,
        reduced.change,
        reduced.attention,
        reduced.celebrate,
        reduced.loop,
      ];
      expect(timed, everyElement(isA<Fade>()));
    });

    test('a released drag settles without bouncing', () {
      expect(reduced.follow.bounce, 0);
    });

    test('groups arrive together', () {
      expect(reduced.stagger, Duration.zero);
    });

    test('says so, so loops can hold still', () {
      expect(reduced.reducesMotion, isTrue);
      expect(PoiseMotion.calm.reducesMotion, isFalse);
    });
  });

  test('copyWith keeps a reduced personality reduced', () {
    final adjusted = PoiseMotion.reduced.copyWith(
      stagger: const Duration(milliseconds: 10),
    );
    expect(adjusted.reducesMotion, isTrue);
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
