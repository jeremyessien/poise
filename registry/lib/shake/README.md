# Shake

The "no" of motion. Wrap a field or a button in `Shake` and it wobbles side to side when something didn't work: a wrong password, a promo code that isn't valid, a form that can't be sent yet. It uses the `attention` word, so the wobble dies away along your personality's curve. Crisp is a tight twitch, playful wobbles a little longer.

```dart
Shake(
  trigger: failedAttempts,
  announcement: "That code didn't work",
  child: PromoCodeField(controller: code),
)
```

It shakes every time `trigger` changes, so pass something that changes on each failed attempt. A count of attempts works well, because two failures in a row still shake twice.

A shake on its own says nothing to someone using a screen reader. Give it an `announcement` and it's read out each time it shakes. Still show the error as text too; motion and colour shouldn't be the only way to know something went wrong.

When the phone asks for less motion, the child doesn't move. It dims and brightens once instead, which still draws the eye.
