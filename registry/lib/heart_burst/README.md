# HeartBurst

The like. Wrap your heart icon in `HeartBurst`, and when `liked` turns true the heart pops with the `celebrate` word while a ring and a burst of particles fly out around it. Taking the like back is quieter: a small press with `feedback`, because unliking isn't something to celebrate.

```dart
HeartBurst(
  liked: saved,
  child: Icon(saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
)
```

`HeartBurst` only adds the motion. You still swap the icon for a filled one and handle the tap yourself, so it works with any icon and any button. Set `color` to match your heart.

The ring and particles are painted straight from the animation and spill past the icon's edges, so leave a little room around it and don't clip its parent. Nothing in your widget tree rebuilds while they fly.

When the phone asks for less motion, nothing pops or flies. The filled heart says it on its own.
