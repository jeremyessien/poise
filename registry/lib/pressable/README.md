# Pressable

Wrap anything tappable in `Pressable` and it answers the touch: it shrinks a little while held and springs back when released, using the `feedback` word from whatever personality is active. Calm barely moves, crisp is quick, playful has a small bounce.

When the phone asks for less motion, it dims instead of shrinking, so the press still shows without anything moving. You don't have to check for that yourself.

```dart
Pressable(
  semanticLabel: 'Open settings',
  onTap: openSettings,
  child: const SettingsCard(),
)
```

Use it for cards, list rows and custom buttons, anything people press that doesn't already come with its own press effect. Flutter's own buttons already have one, so wrapping them gives you two.

`onTap` fires when the finger lifts, not when it lands, so a press that turns into a scroll doesn't count as a tap. Flutter also waits about 100ms before showing the press, so scrolling past a row doesn't make it flinch.
