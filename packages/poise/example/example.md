# poise in an app

Choose a personality once, above the app.

```dart
import 'package:poise/poise.dart';

PoiseScope(
  motion: PoiseMotion.crisp,
  child: const App(),
)
```

Then say the word, wherever something moves. The code never picks a duration or a curve.

```dart
final enter = context.motion.enter;

AnimatedSlide(
  offset: shown ? Offset.zero : const Offset(0, 0.3),
  duration: enter.duration,
  curve: enter.curve,
  child: card,
)
```

A `Move` is a spring, so for anything a finger can grab, hand its `spring` to a `SpringSimulation` and the motion carries on from the finger's speed.

```dart
final follow = context.motion.follow;

controller.animateWith(
  SpringSimulation(follow.spring, controller.value, target, velocity),
);
```

Adjust one word and keep the rest.

```dart
final motion = PoiseMotion.calm.copyWith(
  enter: const Move(perceivedDuration: Duration(milliseconds: 260), bounce: 0.1),
);
```

When the phone asks for less motion, `context.motion` is already `PoiseMotion.reduced`. There is nothing to check.

## See it running

The gallery in the [poise repository](https://github.com/jeremyessien/poise) is the example: Gather, a small events app built entirely from poise's recipes, with a dial that switches its personality live and a page for every recipe and word.

![Gather playing its tour](https://raw.githubusercontent.com/jeremyessien/poise/main/docs/media/tour.gif)

```
git clone https://github.com/jeremyessien/poise.git
cd poise/gallery
flutter run
```
