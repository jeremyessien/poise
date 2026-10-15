# PoiseSheet

A bottom sheet that behaves like a physical thing. It rises with `enter`, follows your finger while you drag it, and when you let go it settles with `follow` from the speed you threw it at. Nudge it and it springs back. Pull it far enough, or flick it down, and it goes.

```dart
Stack(
  children: [
    const EventList(),
    PoiseSheet(
      open: showDetails,
      onClose: () => setState(() => showDetails = false),
      child: EventDetails(event: event),
    ),
  ],
)
```

Put it last in a `Stack` that fills the screen. It's declarative, like `Reveal`: the sheet opens when `open` turns true and leaves when it turns false. Pulling it down, tapping the scrim behind it and the system back gesture all call `onClose`, and nothing closes until you set `open` to false. If you ignore `onClose`, a sheet that was pulled down springs back up.

It isn't a route. Flutter's route transitions run on a controller that stops at fully open, which flattens a spring's overshoot, so a sheet that bounces has to drive itself. Because of that, `Navigator.pop` won't close it. Change `open` instead.

When the phone asks for less motion, opening and closing fade in place. Dragging still moves the sheet, because it's the person's own finger doing it, and it settles without bouncing.

The sheet sizes itself to its content, up to the height of the screen. Give it a scrollable child if the content can be long.
