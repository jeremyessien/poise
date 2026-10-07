import 'package:flutter/material.dart';

import '../theme.dart';
import '../words.dart';
import 'travel.dart';

Widget demoFor(MotionWord word, Listenable play) => switch (word) {
  MotionWord.enter => TravelDemo(
    direction: TravelDirection.arriving,
    play: play,
  ),
  MotionWord.exit => TravelDemo(direction: TravelDirection.leaving, play: play),
  MotionWord.feedback ||
  MotionWord.transition ||
  MotionWord.change ||
  MotionWord.attention ||
  MotionWord.celebrate ||
  MotionWord.follow ||
  MotionWord.loop ||
  MotionWord.stagger => const _NotBuiltYet(),
};

final class _NotBuiltYet extends StatelessWidget {
  const _NotBuiltYet();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        'Demo coming soon',
        textAlign: TextAlign.center,
        style: GalleryType.group,
      ),
    ),
  );
}
