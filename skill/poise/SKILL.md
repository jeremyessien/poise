---
name: poise
description: Motion for Flutter apps built on poise's ten motion words, its personalities and its copy-in recipes. Use when adding, changing or reviewing any animation, page transition, gesture, loading state, press feedback, like, success tick, error shake or list arrival in a Flutter app that uses poise, or when the user mentions poise, a motion word, a personality, springs, reduce motion, or a recipe such as Pressable, Reveal, PoiseSheet, Shimmer, Shake, CountUp or TextSwap.
---

# poise

Every piece of motion in a poise app is one of ten words. The app says the word, and the personality it runs under decides what the word feels like. You never pick a duration or a curve by hand.

Three layers:

- **Words** say why something moves: `enter`, `exit`, `feedback`.
- **Personalities** say what each word feels like: `calm`, `crisp`, `playful`.
- **Recipes** are finished pieces built on the words, copied into the app and owned there: `Pressable`, `Reveal`, `PoiseSheet`.

When asked for motion, start from the word, then reach for the recipe that uses it. Write new motion only when no recipe fits, and then still read the word from `context.motion`.

## The ten words

| Word | Means | Recipe |
|---|---|---|
| `feedback` | The app felt a touch: a press, a toggle, a tap. The quickest motion there is. | `Pressable`, and `HeartBurst` when a like is taken back |
| `enter` | Something arriving. | `Reveal`, `StaggeredColumn`, `PoiseSheet` opening |
| `exit` | Something leaving. Quicker than `enter`, and it never bounces. | `Reveal`, `PoiseRoute` going back, `SuccessCheck` leaving |
| `transition` | Moving from one screen to another. | `PoiseRoute` |
| `change` | Something updating where it already is: a label, a number. | `TextSwap`, `CountUp` |
| `attention` | Look here, usually because something went wrong. | `Shake` |
| `celebrate` | Rewarding the user: a like, a payment going through. | `HeartBurst`, `SuccessCheck` |
| `follow` | Tracks a finger, then settles from the speed it was let go at. | `PoiseSheet` |
| `loop` | Repeats until something stops it. | `Shimmer` |
| `stagger` | The gap between items in a group, so they arrive one after another. | `StaggeredColumn` |

`attention` and `celebrate` both grab the eye, but one says "problem" and the other says "nice". Don't swap them.

## Reading a word

```dart
import 'package:poise/poise.dart';

final enter = context.motion.enter;      // a Feel: a Move (spring) or a Fade
AnimatedContainer(duration: enter.duration, curve: enter.curve, ...);
```

- `context.motion` is the `PoiseMotion` from the nearest `PoiseScope`, or `calm` if there is none. Put one `PoiseScope` above the app. Put another above any part that should feel different; the nearest wins.
- A `Move` is a spring described by `perceivedDuration` and `bounce` (0 glides, about 0.5 is very bouncy). `duration` is how long it really takes to settle, which is longer than it looks, so a bounce is never cut off. `spring` is the `SpringDescription` for gestures.
- A `Fade` is a plain `duration` and `curve`, for colour and opacity. It has no bounce at all.
- `follow` is always a `Move`. `stagger` is a `Duration`. `motion.feelOf(MotionWord.enter)` reads a word by name.
- When the phone asks for less motion, `context.motion` is already `PoiseMotion.reduced`: timed words become short fades, nothing travels, `stagger` is zero and `reducesMotion` is true. Nothing else to check.

## Haptics

Four haptic words, each a single short haptic: `tap` (a press), `select` (a value moved one step: toggle, segmented control, picker), `confirm` (something the user did worked: a payment, a booking, never a like) and `warn` (something the user did failed). `HapticWord.tap.play(context)` plays one. Each motion word knows its default, `MotionWord.feedback.haptic`: `feedback` is `tap`, `change` is `select`, `celebrate` is `confirm`, `attention` is `warn`, and every other word is null and stays silent. A pairing is a default: a like is a small `celebrate`, so it's a `tap`.

- **No raw `HapticFeedback` calls.** Use the word, the same way motion never uses a hand-picked duration.
- **Only for what the user did, or its result.** A number the server updated is a `change` with no haptic. Never put a haptic on a `loop`.
- **Once, at the moment it happens.** `tap` when the finger comes down, `select` when the toggle flips, not every frame.
- **Never the only message.** The screen still has to show the result.
- **Wire the app's vibration setting to `PoiseScope(haptics: false)`.** Don't check it yourself before playing; `play(context)` already does. A nested scope without `haptics` keeps the outer setting.
- **Reduce motion doesn't silence haptics.** Don't skip them under `reduced`; the phone's own haptics setting already applies.

## Personalities

- `calm`: settled and quiet, for products where trust and focus matter more than delight. Health, finance, reading. Only `attention` bounces.
- `crisp`: quick and exact, for banking, productivity and tools. Only `attention` bounces.
- `playful`: springy and alive, for kids' apps, games and social. Touch, arrival and celebration bounce too.

Pick one by what the product is, not by what looks fun in a demo. Adjust a single word without touching the rest:

```dart
PoiseScope(
  motion: PoiseMotion.crisp.copyWith(
    enter: const Move(perceivedDuration: Duration(milliseconds: 260), bounce: 0.1),
  ),
  child: const App(),
)
```

Build the adjusted personality once and keep it, rather than calling `copyWith` inside `build` on every frame.

## Rules that are easy to get wrong

- **No hand-picked numbers.** `Duration(milliseconds: 300)` and `Curves.easeOut` in app code are a sign the word was skipped. Read `context.motion`.
- **Fades never bounce.** A colour or opacity that overshoots looks like a glitch. `Fade` can't bounce; don't animate opacity with a `Move`.
- **Exits are quicker than entrances and never bounce.** The user has already moved on.
- **Leave reduce motion to poise.** Don't read `MediaQuery.disableAnimations` yourself. Under `reduced`, loops hold still, nothing slides, and a drag still follows the finger because the finger is the user's.
- **Never rebuild `Opacity` every frame.** Use `FadeTransition` with an animation, or `AnimatedOpacity`. With `AnimatedBuilder`, pass the unchanging subtree as `child`.
- **Interruptible motion runs on a real spring.** Anything a finger can grab, or that can be shown and hidden quickly, uses `AnimationController.animateWith(SpringSimulation(move.spring, from, to, velocity))` so it turns around from where it is. `Reveal` is the pattern. A fixed-duration tween jumps or restarts.
- **Anything that slides mirrors in right-to-left languages.** Use start and end, never left and right.
- **Motion is never the only message.** Announce errors and results to screen readers; `Shake`, `TextSwap` and `SuccessCheck` do this for you.
- **Flutter's own buttons already press.** Don't wrap `ElevatedButton` or `CupertinoButton` in `Pressable`; use it for cards, rows and custom buttons.
- **Keep loops for things that are on screen and loading.** They are the easiest way to drain a cheap phone, and `Shimmer` stops the moment it is removed.

## Bringing a recipe in

Recipes are copied, not depended on, so the app owns the code.

1. Add `poise` to `pubspec.yaml` (from pub.dev once it is published, until then as a git dependency on `packages/poise` in the poise repository).
2. Copy the recipe's folder from `registry/lib/` into `lib/poise/` in the app, along with every folder listed under **Copy into** in its reference. Recipes only ever depend on Flutter, `poise` and each other.
3. Import it with a package import, so it resolves from any file in the app: `import 'package:my_app/poise/pressable/pressable.dart';`, with `my_app` replaced by the `name` in the app's `pubspec.yaml`. The references write it the same way.
4. Don't edit the registry copy; edit the one in the app.

## Recipes

Each reference says what the recipe is for, when to reach for it, what to copy and how to use it. Load only the one you need.

- `Pressable` makes any widget respond to a press, and dims instead of shrinking when the phone asks for less motion. [references/pressable.md](references/pressable.md)
- `Reveal` brings a widget in and takes it away on springs that turn around smoothly if you change your mind halfway. [references/reveal.md](references/reveal.md)
- `StaggeredColumn` is a column whose children arrive one after another, spaced by the personality's stagger gap. [references/staggered_column.md](references/staggered_column.md)
- `PoiseRoute` is a page route that slides between screens in your personality, and keeps the swipe back on iOS. [references/poise_route.md](references/poise_route.md)
- `PoiseSheet` is a bottom sheet you can drag and throw, which settles from the speed your finger let go at. [references/poise_sheet.md](references/poise_sheet.md)
- `TextSwap` is text that changes where it stands, rolling the new words in and announcing them to screen readers. [references/text_swap.md](references/text_swap.md)
- `CountUp` is a number that counts to its new value, so a balance or a score visibly climbs instead of jumping. [references/count_up.md](references/count_up.md)
- `Shake` is the "no" wobble for a wrong password or a code that didn't work, which flashes instead when motion is reduced. [references/shake.md](references/shake.md)
- `HeartBurst` is the like, where a heart pops and bursts when it's filled and simply presses when it's taken back. [references/heart_burst.md](references/heart_burst.md)
- `SuccessCheck` is a tick that draws itself inside a circle that pops in, for the moment something has worked. [references/success_check.md](references/success_check.md)
- `Shimmer` is loading placeholders that breathe or shimmer in your personality, and hold still when motion is reduced. [references/shimmer.md](references/shimmer.md)

## What to reach for

- A card, row or custom button that should answer a touch: `Pressable`.
- A toast, banner, result or any widget that appears and goes: `Reveal`.
- A list or a screen of cards coming in: `StaggeredColumn`, for a handful of items, not a long scrolling list.
- Pushing a screen: `PoiseRoute` in place of `MaterialPageRoute`.
- A sheet, drawer or panel the user drags: `PoiseSheet`.
- A label that changes: `TextSwap`. A number that changes: `CountUp`.
- A wrong password, invalid code or form that can't be sent: `Shake`, with an announcement.
- A like: `HeartBurst`. A payment, booking or task done: `SuccessCheck`.
- Content loading: `Shimmer` over placeholder shapes, swapped out as soon as the content arrives.
- Something none of these cover: read the word from `context.motion` and follow the rules above.
