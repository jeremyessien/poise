# PoiseRoute

Use `PoiseRoute` wherever you'd use `MaterialPageRoute` or `CupertinoPageRoute`. The new screen slides in from the end edge with the `transition` word while the one underneath drifts a little the other way, and going back uses `exit`, so it's quicker than arriving.

```dart
Navigator.of(context).push(
  PoiseRoute(builder: (context) => EventPage(event: event)),
);
```

Most custom page transitions quietly lose the iOS swipe back from the edge of the screen, and iPhone users notice straight away. `PoiseRoute` keeps it: on iOS and macOS you can drag the screen back from its start edge and let go to finish or cancel, and it drives the route's own back gesture, so the navigator knows a gesture is happening.

The slide follows the reading direction, so it comes from the left in Arabic or Hebrew. When the phone asks for less motion, the screens cross-fade instead of sliding.

Routes are built above every page, so a `PoiseScope` inside a page doesn't reach them. Put a `PoiseScope` above your `MaterialApp` or `CupertinoApp`, or pass `motion: context.motion` when you push from somewhere with its own personality.
