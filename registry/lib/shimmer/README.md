# Shimmer

While content loads, show grey placeholder shapes where it will go and wrap them in `Shimmer`. It uses the `loop` word, so it follows your personality. Where `loop` is a fade, as in calm and crisp, the placeholders breathe, dimming and brightening. Where it's a spring, as in playful, a highlight sweeps across them.

```dart
loading
    ? const Shimmer(child: EventCardSkeleton())
    : EventCard(event: event)
```

Swap it for the real content as soon as that arrives. It only runs while it's on screen, and it stops the moment it's removed.

When the phone asks for less motion it holds completely still. Motion that repeats on its own is the hardest kind to sit through, and still placeholders already say "loading".

The sweep is drawn over your placeholders with a shader, so set `highlight` to suit their colour. Keep the placeholders themselves simple, like rounded grey boxes, because they're redrawn on every frame of the sweep.
