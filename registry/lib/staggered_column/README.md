# StaggeredColumn

A `Column` whose children don't all appear at once. Each one arrives a moment after the one before, using `enter`, with the gap coming from the personality's `stagger`. Crisp ripples in quickly, playful takes its time.

```dart
StaggeredColumn(
  children: [
    for (final event in events) EventCard(event: event),
  ],
)
```

Each child arrives through a `Reveal`, so this recipe needs the `reveal` folder copied alongside it. That also means every child gets the same springs, and if the phone asks for less motion, the gap drops to zero and everything fades in together.

Change `replayKey` to play the cascade again, for example when a list is refreshed or filtered. Children added to the end later arrive in turn after the rest, so a list that loads more as you scroll keeps the same rhythm.

It's meant for a handful of items, like the cards on a screen or the results of a search. For long scrolling lists, stagger only what's on screen when it first appears. Making the hundredth item wait for the ninety-nine before it is just a delay.
