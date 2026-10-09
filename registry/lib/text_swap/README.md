# TextSwap

Use `TextSwap` wherever a label changes: a button going from "Join" to "Joining…" to "You're in", a status line, a tab title. The new words roll up into the line as the old ones roll out, using the `change` word, and the space resizes to fit so nothing around it jumps.

```dart
TextSwap(
  switch (state) {
    JoinState.idle => 'Join',
    JoinState.joining => 'Joining…',
    JoinState.joined => "You're in",
  },
  style: buttonLabelStyle,
)
```

It takes the text first, like `Text`, so swapping one for the other is a one-word change.

Screen readers announce the new text, because the swap is a live region. A plain `Text` that changes says nothing, so someone using VoiceOver wouldn't know the button had worked.

If the personality's `change` is a fade, as it is in calm and crisp, or the phone asks for less motion, the old and new text cross-fade in place instead of rolling. Playful rolls.

Swapping only animates when the text is different. Rebuilding with the same text does nothing.
