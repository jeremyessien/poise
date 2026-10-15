# Reveal

`Reveal` brings its child in when `visible` turns true and takes it away when it turns false. Arriving uses the `enter` word and leaving uses `exit`, so it moves the way the rest of your app does.

```dart
Reveal(
  visible: resultIsReady,
  child: const ResultCard(),
)
```

Both directions run on real springs. If `visible` flips back while the child is halfway, it turns around from where it is and keeps its momentum instead of jumping or starting over. That matters more than it sounds: banners and toasts get shown and dismissed quickly all the time.

By default the child rises 16 pixels from below as it fades in. Use `from` to change direction: `RevealFrom.top`, `.start` or `.end`. Start and end follow the reading direction, so they mirror in Arabic or Hebrew without you doing anything. Keep `distance` small. `Reveal` is for things arriving, not flying across the screen.

When the phone asks for less motion, the child fades in place and doesn't travel at all.

A hidden child keeps its space, so nothing around it jumps, but it can't be tapped and screen readers skip it. If you want it gone from the layout once it has left, use `onHidden` to remove it.

If the child starts out visible, it animates in when it first appears. Pass `revealOnFirstBuild: false` if it should just be there.
