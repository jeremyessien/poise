## 0.2.0

- Four haptic words as `HapticWord`: `tap`, `select`, `confirm` and `warn`. `play(context)` sends one to the phone.
- `PoiseScope(haptics: false)` turns haptics off for everything below it. Nested scopes keep the setting unless they set their own.
- `MotionWord.haptic`, the haptic that goes with each motion word by default: `feedback` taps, `change` selects, `celebrate` confirms, `attention` warns, and the rest stay silent.

## 0.1.0

The first release.

- `Move` and `Fade`, the two kinds of feel. A `Move` is a spring described by how long it looks like it takes and how much it bounces, and it runs until it has really settled so a bounce is never cut off.
- The ten motion words as `MotionWord`, and `PoiseMotion`, which gives each word a feel.
- Three personalities: `calm`, `crisp` and `playful`, plus `reduced` for when the phone asks for less motion.
- `PoiseScope` and `context.motion`, which read the nearest personality and apply `reduced` automatically.
- `copyWith` to adjust one word without touching the rest. Personalities and feels compare by value.
