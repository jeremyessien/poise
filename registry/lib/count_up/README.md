# CountUp

When a number changes, `CountUp` counts there instead of jumping: a balance climbing from 1,200 to 1,450, spots left ticking down as people join, a score going up. It uses the `change` word, so it counts at your personality's pace.

```dart
CountUp(
  value: spotsLeft,
  format: (n) => '$n spots left',
)
```

Whole numbers count in whole steps. If the value has decimals, give it a format that shows them, like `(n) => '\$${n.toStringAsFixed(2)}'`, and you'll see the cents go by.

Digits are drawn at equal widths while it counts, so the number doesn't jiggle from side to side as 1 turns into 8. Screen readers hear only the number it lands on, not every number on the way.

If the value changes again while it's still counting, it carries on from where it is. When the phone asks for less motion it doesn't count at all: the new number fades in through `TextSwap`, which is why this recipe needs the `text_swap` folder copied alongside it.
