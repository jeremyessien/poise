# Haptics vocabulary

Motion is what you see. Haptics are what you feel, and they get the same treatment: a few words with clear meanings, so nobody has to remember which `HapticFeedback` call goes with what. The code lives in `packages/poise/lib/src/haptics.dart`.

## The four words

The list is even shorter than motion's. A phone can only make a handful of buzzes that feel different from each other, and more words than that would just be the same buzz with different names.

`tap` means the app felt your touch: a press on a card, a row or a custom button. It's the lightest buzz there is.

`select` means a value moved by one step: a toggle flipping, a segmented control changing, a picker ticking past a number. It's a click rather than a knock.

`confirm` means something you did has worked: a payment going through, a booking made, a like.

`warn` means something you did hasn't worked: a wrong password, a refused card, a form that can't be sent.

`confirm` and `warn` are split for the same reason `celebrate` and `attention` are. Both are strong, but one says "nice" and the other says "problem", and on iOS they feel noticeably different.

## Which motion words they go with

Every motion word has a default haptic, and most of them have none.

| Motion word | Haptic |
|---|---|
| `feedback` | `tap` |
| `change` | `select` |
| `celebrate` | `confirm` |
| `attention` | `warn` |
| `enter`, `exit`, `transition`, `follow`, `loop`, `stagger` | nothing |

In code it's `MotionWord.feedback.haptic`, which gives `HapticWord.tap`, and `HapticWord.tap.play()` plays it.

Things arriving, leaving and changing screens are felt as nothing because the user didn't touch them, or the touch that started them has already been felt. A loop that buzzes is a phone that won't stop buzzing.

## Rules that apply to every word

A haptic answers something the user did, or the result of it. A balance counting up because the server sent a new number is a `change`, but nobody asked for it, so it stays silent. The same balance going up because the user just paid someone in is a `confirm`.

Play it once, at the moment it happens. A toggle plays `select` when it flips, not for every frame of the flip. A press plays `tap` when the finger comes down, so it lands with the shrink rather than after it.

Haptics are never the only message. Someone with haptics turned off, or on a phone that can't make them, still has to see that the password was wrong.

Reduce motion doesn't turn haptics off. They're separate settings on the phone, and someone who finds motion hard to watch may rely on the buzz more, not less. The phone's own haptics setting is respected without poise doing anything.

On Android before 11, `confirm` and `warn` are silent, because the buzzes they use don't exist there yet. `tap` and `select` work everywhere.
