import 'package:flutter/widgets.dart';

import '../words.dart';
import 'breathe.dart';
import 'cascade.dart';
import 'count.dart';
import 'drag.dart';
import 'pop.dart';
import 'press.dart';
import 'screens.dart';
import 'shake.dart';
import 'travel.dart';

Widget demoFor(MotionWord word, Listenable play) => switch (word) {
  MotionWord.feedback => PressDemo(play: play),
  MotionWord.enter => TravelDemo(
    direction: TravelDirection.arriving,
    play: play,
  ),
  MotionWord.exit => TravelDemo(direction: TravelDirection.leaving, play: play),
  MotionWord.transition => ScreenChangeDemo(play: play),
  MotionWord.change => CountDemo(play: play),
  MotionWord.attention => ShakeDemo(play: play),
  MotionWord.celebrate => PopDemo(play: play),
  MotionWord.follow => DragDemo(play: play),
  MotionWord.loop => LoopDemo(play: play),
  MotionWord.stagger => StaggerDemo(play: play),
};
