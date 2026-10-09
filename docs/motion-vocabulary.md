# Motion vocabulary

Every piece of motion in poise answers three questions, and each one has its own layer.

**Feel** is how something moves: a fast spring, a slow ease, a bounce or no bounce. These are the raw values, and nobody outside poise should have to touch them.

**Purpose** is why it moves. It's the vocabulary below, ten words that every app, developer and agent uses the same way.

**Recipes** are what exactly happens. They're named, complete pieces like `Pressable`, `Reveal` or `StaggeredColumn`, built out of purposes, that you copy into your app from the registry.

When an agent gets a request, it starts with the purpose and then picks a recipe. If someone asks for a card that rises in, that's an `enter`, and the recipe for it is `Reveal`. The agent never has to make up a number.

## The ten words

I kept the list short on purpose. Agents and people both choose better from a few words with clear meanings than from many vague ones.

### Time-based: starts, runs, stops

`feedback` means the app felt your touch: a button press, a toggle, a tap on a card. It's the shortest motion in the system, because anything slow here makes the app feel unresponsive.

`enter` is something arriving: a card rising in, a sheet opening, a toast appearing.

`exit` is something leaving: a sheet closing, a toast going away. Things leave faster than they arrive, because the user has already moved on and waiting for a goodbye feels sluggish.

`transition` is moving from one screen to another.

`change` is something updating where it already is: a balance counting up, a label swapping text, a toggle flipping.

`attention` means look here, usually because something's wrong, like a wrong password shaking.

`celebrate` rewards the user: a like, a payment going through, a goal reached. I split this from `attention` because a shake and a heart burst both grab focus, but one says "problem" and the other says "nice", and mixing them up is the kind of mistake a vague word invites.

### Driven: no fixed duration

`follow` is motion that tracks a finger or a scroll position: dragging a sheet, swiping a card away, pull to refresh, a header collapsing as you scroll. Nobody knows how long a drag will last, so this can't be timed. When the finger lets go, the motion has to carry on from the finger's speed, or it feels dead.

`loop` repeats until something stops it: a loading shimmer, a pulsing live dot. Loops run the whole time they're on screen, which makes them the easiest way to drain a cheap phone's battery. That's why they get their own word and their own rules.

### Rhythm: how things move together

`stagger` is the spacing between items in a group, so a list arrives one item at a time instead of all at once.

## Rules that apply to every word

Position, size and rotation can overshoot and bounce. Colour and opacity never do, because a fade that overshoots looks like a glitch. I took this rule from Material 3.

Every word has a reduced-motion version for people who turn animations off. That's usually a quick fade, and never just nothing, because the change itself still has to be visible.

Every word will get a cheaper fallback for low-end phones once the values have been tuned on real ones (#10).

Anything interrupted halfway, like a press released early or a sheet grabbed mid-close, reverses smoothly from where it is. It doesn't jump.

Anything that slides mirrors itself in right-to-left languages.

## Personalities

The ten words never change. The values behind them do, and a set of values is a personality. A health app wants calm. A banking app wants crisp, fast and exact. A kids' app wants something bouncy. poise ships three, `calm`, `crisp` and `playful`, and any app can make its own or adjust a single word with `copyWith` without touching the rest. The values are described in [feel.md](feel.md).
