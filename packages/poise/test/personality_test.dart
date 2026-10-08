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

const timed = [
  MotionWord.feedback,
  MotionWord.enter,
  MotionWord.exit,
  MotionWord.transition,
  MotionWord.change,
  MotionWord.attention,
  MotionWord.celebrate,
];

Map<MotionWord, Feel> timedWords(PoiseMotion motion) => {
  for (final word in timed) word: motion.feelOf(word)!,
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
          if (word == MotionWord.feedback) continue;
          expect(
            feltDuration(motion.feedback),
            lessThanOrEqualTo(feltDuration(feel)),
            reason: word.name,
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
        expect(bounces(feel), word == MotionWord.attention, reason: word.name);
      }
    });
  }

  test('crisp is quicker than calm everywhere', () {
    final calm = timedWords(PoiseMotion.calm);
    for (final MapEntry(key: word, value: crispFeel) in timedWords(
      PoiseMotion.crisp,
    ).entries) {
      expect(
        feltDuration(crispFeel),
        lessThan(feltDuration(calm[word]!)),
        reason: word.name,
      );
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
      final feels = [
        for (final word in MotionWord.values)
          if (word != MotionWord.follow) reduced.feelOf(word),
      ]..removeWhere((feel) => feel == null);
      expect(feels, everyElement(isA<Fade>()));
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

  test('every word except stagger has a feel', () {
    for (final word in MotionWord.values) {
      expect(
        PoiseMotion.calm.feelOf(word),
        word == MotionWord.stagger ? isNull : isA<Feel>(),
        reason: word.name,
      );
    }
  });

  test('copyWith keeps a reduced personality reduced', () {
    final adjusted = PoiseMotion.reduced.copyWith(
      stagger: const Duration(milliseconds: 10),
    );
    expect(adjusted.reducesMotion, isTrue);
  });

  test('two personalities with the same feels are equal', () {
    PoiseMotion adjusted() => PoiseMotion.calm.copyWith(
      enter: const Move(perceivedDuration: Duration(milliseconds: 500)),
      change: const Fade(duration: Duration(milliseconds: 180)),
    );
    expect(adjusted(), equals(adjusted()));
    expect(adjusted().hashCode, adjusted().hashCode);
    expect(adjusted(), isNot(equals(PoiseMotion.calm)));
    expect(PoiseMotion.reduced.copyWith(), equals(PoiseMotion.reduced));
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
