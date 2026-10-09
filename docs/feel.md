# Feel

Feel is the bottom layer: the actual values behind the ten words in [motion-vocabulary.md](motion-vocabulary.md). The code lives in `packages/poise/lib/src/feel.dart`.

## Two kinds of feel

A `Feel` is either a `Move` or a `Fade`. Both can hand Flutter's animated widgets a `duration` and a `curve`, so `AnimatedContainer(duration: feel.duration, curve: feel.curve)` works with either.

**`Move` is a spring**, for anything that changes position, size or rotation. Springs handle interruption the way real objects do: grab a sheet halfway through closing and it carries its momentum into the new direction instead of jumping or restarting. That only holds when the spring itself is driven, with `Move.spring` in a `SpringSimulation` that starts from the current value and velocity, as the recipes do. `Move.curve` in a widget like `AnimatedContainer` still moves like the spring, but an interruption starts a fresh curve from where it is and the speed it had is lost. The physics version of a spring uses mass, stiffness and damping, and nobody can picture "stiffness 438", so a `Move` is described with two numbers anyone can imagine:

- `perceivedDuration`: roughly how long it looks like it takes
- `bounce`: how much it overshoots, from `0` (glides in and stops) to about `0.5` (very bouncy)

Flutter supports this directly with `SpringDescription.withDurationAndBounce`, which matches SwiftUI's `spring(duration:bounce:)`. iOS developers already think in these terms, and agents have seen plenty of it in SwiftUI code. A `Move` exposes that `spring` for gestures that need to carry on from a finger's speed.

A spring keeps moving a little after it looks finished. `Move.settleDuration` measures how long it really takes to stop, and that is what `duration` returns, so a bounce is never cut off and snapped onto its target.

**`Fade` is a duration and a curve**, for colour and opacity. It has no bounce setting at all, so the never-bounce-a-fade rule can't be broken by accident. Nobody grabs a fade halfway.

## Personalities fill in the words

A `PoiseMotion` gives each of the ten words a feel: `feedback`, `enter`, `exit`, `transition`, `change`, `attention` and `celebrate` take any feel; `follow` is always a `Move`, because a drag has to settle on a real spring; `stagger` is a plain gap; `loop` is one cycle of something that repeats.

Three presets ship: `calm`, `crisp` and `playful`. Calm and crisp bounce only for `attention`. Playful bounces on touch, arrival and celebration too. `copyWith` adjusts one word and keeps the rest.

`PoiseMotion.reduced` is what every app gets when the phone asks for less motion: timed words become short fades, nothing travels, groups arrive together. `PoiseScope` applies it automatically, so `context.motion` already has the right answer.

Personalities and feels compare by value, so a `copyWith` built inside `build` does not make everything below the scope rebuild.

The presets are tuned by watching them run on real phones, which is the whole point. They will keep moving while poise is early.
