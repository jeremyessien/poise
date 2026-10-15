/// The ten motion words. Every piece of motion in a poise app is one of
/// these, and a personality decides what each one feels like.
enum MotionWord {
  /// The app felt a touch: a press, a toggle, a tap.
  feedback,

  /// Something arriving on screen.
  enter,

  /// Something leaving. Quicker than [enter], and never bounces.
  exit,

  /// Moving from one screen to another.
  transition,

  /// Something updating where it already is, like a number or a label.
  change,

  /// "Look here", usually because something went wrong.
  attention,

  /// Rewarding the user: a like, a payment going through.
  celebrate,

  /// How a drag or swipe settles once the finger lets go.
  follow,

  /// One cycle of something that repeats, like a shimmer or a pulse.
  loop,

  /// The gap between items in a group, so they arrive one after another.
  stagger,
}
