# Feel

Feel is the bottom layer: the actual values behind the ten words in [motion-vocabulary.md](motion-vocabulary.md).

## Springs, described by duration and bounce

Anything that moves (position, size, rotation) is a spring. Springs handle interruption the way real objects do. Grab a sheet halfway through closing and it carries its momentum into the new direction instead of jumping or restarting.

The physics version of a spring uses mass, stiffness and damping, and nobody can picture "stiffness 438". So poise describes springs with two numbers anyone can imagine:

- **duration**: roughly how long it takes to settle
- **bounce**: how much it overshoots, from `0` (glides in and stops) to about `0.5` (very bouncy)

Flutter supports this directly with `SpringDescription.withDurationAndBounce`, which matches SwiftUI's `spring(duration:bounce:)`. iOS developers already think in these terms, and agents have seen plenty of it in SwiftUI code.

Fades (colour and opacity) use a plain duration and curve. Nobody grabs a fade halfway, and a fade must never overshoot anyway.

## The grid

The whole feel layer is six values:

|             | moves (can bounce) | fades (never bounce) |
|-------------|--------------------|----------------------|
| **fast**    | `moveFast`         | `fadeFast`           |
| **default** | `move`             | `fade`               |
| **slow**    | `moveSlow`         | `fadeSlow`           |

There's no bounce setting for fades at all, so the never-bounce-a-fade rule can't be broken by accident.

## Personalities fill it in

A personality decides two things: the values in the grid, and which feel each word uses. Calm might give `enter` a default move with no bounce, while playful gives it the same move with a 0.25 bounce. The app's code says `enter` either way and never changes.

The numbers aren't set yet. I'll tune them by watching them run on real phones, which is the whole point.
