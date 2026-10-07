import 'package:poise/poise.dart';

import 'words.dart';

extension WordFeel on MotionWord {
  Feel? feelIn(PoiseMotion motion) => switch (this) {
    MotionWord.feedback => motion.feedback,
    MotionWord.enter => motion.enter,
    MotionWord.exit => motion.exit,
    MotionWord.transition => motion.transition,
    MotionWord.change => motion.change,
    MotionWord.attention => motion.attention,
    MotionWord.celebrate => motion.celebrate,
    MotionWord.follow => motion.follow,
    MotionWord.loop => motion.loop,
    MotionWord.stagger => null,
  };
}

const curveWindowStretch = 0.8;

int feltMicros(Feel? feel) => switch (feel) {
  Move(:final perceivedDuration) => perceivedDuration.inMicroseconds,
  Fade(:final duration) => duration.inMicroseconds,
  null => 0,
};

double progressAt(MotionWord word, Feel feel, double t) => switch (word) {
  MotionWord.exit => 1 - feel.curve.transform(t),
  MotionWord.loop =>
    t < 0.5 ? feel.curve.transform(t * 2) : feel.curve.transform((1 - t) * 2),
  _ => feel.curve.transform(t),
};
