# SuccessCheck

The moment a payment goes through, a task is done or a place is booked deserves more than a colour change. `SuccessCheck` pops a circle in with the `celebrate` word and draws a tick inside it.

```dart
SuccessCheck(shown: paymentWentThrough)
```

Set `shown` to true and it celebrates; set it back to false and it fades away with `exit`. Change `size`, `color` and `tickColor` to fit your app. Calm pops it gently, playful gives it a bounce.

The tick is painted straight from the animation, so nothing in your widget tree rebuilds while it draws. That keeps it cheap on low-end phones.

When the phone asks for less motion, the finished tick fades in, already drawn and at full size. Screen readers hear `semanticLabel`, "Done" by default, once it's shown. Give it something more specific, like "Payment sent", when you can.
