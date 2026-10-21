# poise

Motion for Flutter apps, built so your AI agent already knows it.

<p align="center">
  <img src="https://raw.githubusercontent.com/jeremyessien/poise/main/docs/media/tour.gif" width="280" alt="Gather, a small app built from poise recipes, playing its tour: a press, a save, a sheet, a page change, then the dial turning from calm to crisp to playful">
</p>

This is the core package: the ten words, springs and fades, the personalities, and `context.motion`. The recipes you copy into an app, the gallery and the agent skill live in the [poise repository](https://github.com/jeremyessien/poise).

Every piece of motion is one of ten words: `feedback`, `enter`, `exit`, `transition`, `change`, `attention`, `celebrate`, `follow`, `loop` and `stagger`. A personality decides what each word feels like. Your code says the word and never picks a duration or a curve by hand.

```dart
import 'package:poise/poise.dart';

PoiseScope(
  motion: PoiseMotion.crisp,
  child: const App(),
)

// Anywhere below it:
final enter = context.motion.enter;
AnimatedContainer(duration: enter.duration, curve: enter.curve, child: card);
```

A feel is a `Move`, a spring described by `perceivedDuration` and `bounce`, or a `Fade`, a duration and a curve for colour and opacity. Fades can't bounce. A `Move` also exposes its `spring` for gestures that need to carry on from a finger's speed.

```dart
final motion = PoiseMotion.calm.copyWith(
  enter: const Move(perceivedDuration: Duration(milliseconds: 260), bounce: 0.1),
);
```

When the phone asks for less motion, `context.motion` is already `PoiseMotion.reduced`: timed words become short fades, nothing travels, groups arrive together. There is nothing to check yourself.

Four haptic words go with them: `tap`, `select`, `confirm` and `warn`. Each motion word knows its own, so a press and its buzz come from the same place.

```dart
MotionWord.feedback.haptic?.play(); // HapticWord.tap
HapticWord.warn.play();
```

Three personalities ship: `calm` for products where trust and focus matter, `crisp` for tools and banking, `playful` for games and social. Read [docs/motion-vocabulary.md](https://github.com/jeremyessien/poise/blob/main/docs/motion-vocabulary.md) for what each word means, [docs/haptics-vocabulary.md](https://github.com/jeremyessien/poise/blob/main/docs/haptics-vocabulary.md) for the haptics, and [docs/feel.md](https://github.com/jeremyessien/poise/blob/main/docs/feel.md) for the values behind them.
