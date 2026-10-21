# SuccessCheck

A tick that draws itself inside a circle that pops in, for the moment something has worked.

- **Words:** celebrate, exit
- **Haptics:** confirm
- **Copy into `lib/poise/`:** `success_check/`
- **Import:**

```dart
import 'package:my_app/poise/success_check/success_check.dart';
```

The moment a payment goes through, a task is done or a place is booked deserves more than a colour change. `SuccessCheck` pops a circle in with the `celebrate` word and draws a tick inside it.

```dart
SuccessCheck(shown: paymentWentThrough)
```

Set `shown` to true and it celebrates; set it back to false and it fades away with `exit`. Change `size`, `color` and `tickColor` to fit your app. Calm pops it gently, playful gives it a bounce.

When `shown` turns true it plays the `confirm` haptic. A tick that's already showing when the screen opens stays silent, because nothing has just happened. Pass `haptic: false` to leave it out.

The tick is painted straight from the animation, so nothing in your widget tree rebuilds while it draws. That keeps it cheap on low-end phones.

When the phone asks for less motion, the finished tick fades in, already drawn and at full size. Screen readers hear `semanticLabel`, "Done" by default, once it's shown. Give it something more specific, like "Payment sent", when you can.
