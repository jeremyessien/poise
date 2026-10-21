# HeartBurst

The like, where a heart pops and bursts when it's filled and simply presses when it's taken back.

- **Words:** celebrate, feedback
- **Haptics:** tap
- **Copy into `lib/poise/`:** `heart_burst/`
- **Import:**

```dart
import 'package:my_app/poise/heart_burst/heart_burst.dart';
```

The like. Wrap your heart icon in `HeartBurst`, and when `liked` turns true the heart pops with the `celebrate` word while a ring and a burst of particles fly out around it. Taking the like back is quieter: a small press with `feedback`, because unliking isn't something to celebrate.

```dart
HeartBurst(
  liked: saved,
  child: Icon(saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
)
```

`HeartBurst` only adds the motion. You still swap the icon for a filled one and handle the tap yourself, so it works with any icon and any button. Set `color` to match your heart.

The ring and particles are painted straight from the animation and spill past the icon's edges, so leave a little room around it and don't clip its parent. Nothing in your widget tree rebuilds while they fly.

Filling the heart plays the `tap` haptic, and taking it back plays nothing. A like is a small moment, so it's a light tap rather than the stronger `confirm` a payment gets. `HeartBurst` can't tell whether `liked` changed because of a finger or because likes synced from somewhere else, so pass `haptic: false` where they can arrive on their own.

When the phone asks for less motion, nothing pops or flies. The filled heart says it on its own, and the haptic still plays.
