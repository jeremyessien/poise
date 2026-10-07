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
