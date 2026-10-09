import 'feel.dart';
import 'words.dart';

/// A personality: the feel behind each of poise's ten motion words.
///
/// The words never change between apps. The feels behind them do. Use a
/// preset like [calm], [crisp] or [playful], or adjust one with [copyWith].
final class PoiseMotion {
  const PoiseMotion({
    required this.feedback,
    required this.enter,
    required this.exit,
    required this.transition,
    required this.change,
    required this.attention,
    required this.celebrate,
    required this.follow,
    required this.loop,
    required this.stagger,
    this.reducesMotion = false,
  });

  /// The app felt a touch: a press, a toggle, a tap.
  final Feel feedback;

  /// Something arriving on screen.
  final Feel enter;

  /// Something leaving. Quicker than [enter], and never bounces.
  final Feel exit;

  /// Moving from one screen to another.
  final Feel transition;

  /// Something updating where it is, like a number or a label.
  final Feel change;

  /// "Look here", usually because something went wrong.
  final Feel attention;

  /// Rewarding the user: a like, a payment going through.
  final Feel celebrate;

  /// How a drag or swipe settles once the finger lets go.
  final Move follow;

  /// One cycle of something that repeats, like a shimmer or a pulse.
  final Feel loop;

  /// The gap between items in a group, so they arrive one after another.
  final Duration stagger;

  /// True for [reduced]. Loops should hold still instead of repeating.
  final bool reducesMotion;

  /// Settled and quiet, for products where trust and focus matter more than
  /// delight. Only [attention] bounces.
  static const calm = PoiseMotion(
    feedback: Move(perceivedDuration: Duration(milliseconds: 140)),
    enter: Move(perceivedDuration: Duration(milliseconds: 400)),
    exit: Move(perceivedDuration: Duration(milliseconds: 260)),
    transition: Move(perceivedDuration: Duration(milliseconds: 420)),
    change: Fade(duration: Duration(milliseconds: 240)),
    attention: Move(
      perceivedDuration: Duration(milliseconds: 300),
      bounce: 0.3,
    ),
    celebrate: Move(perceivedDuration: Duration(milliseconds: 500)),
    follow: Move(perceivedDuration: Duration(milliseconds: 350)),
    loop: Fade(duration: Duration(milliseconds: 1600)),
    stagger: Duration(milliseconds: 60),
  );

  /// Quick and exact, for banking, productivity and tools. Only [attention]
  /// bounces.
  static const crisp = PoiseMotion(
    feedback: Move(perceivedDuration: Duration(milliseconds: 70)),
    enter: Move(perceivedDuration: Duration(milliseconds: 200)),
    exit: Move(perceivedDuration: Duration(milliseconds: 140)),
    transition: Move(perceivedDuration: Duration(milliseconds: 260)),
    change: Fade(duration: Duration(milliseconds: 120)),
    attention: Move(
      perceivedDuration: Duration(milliseconds: 180),
      bounce: 0.25,
    ),
    celebrate: Move(perceivedDuration: Duration(milliseconds: 260)),
    follow: Move(perceivedDuration: Duration(milliseconds: 200)),
    loop: Fade(duration: Duration(milliseconds: 900)),
    stagger: Duration(milliseconds: 20),
  );

  /// Springy and alive, for kids' apps, games and social.
  static const playful = PoiseMotion(
    feedback: Move(perceivedDuration: Duration(milliseconds: 160), bounce: 0.4),
    enter: Move(perceivedDuration: Duration(milliseconds: 450), bounce: 0.35),
    exit: Move(perceivedDuration: Duration(milliseconds: 260)),
    transition: Move(
      perceivedDuration: Duration(milliseconds: 500),
      bounce: 0.2,
    ),
    change: Move(perceivedDuration: Duration(milliseconds: 320), bounce: 0.3),
    attention: Move(
      perceivedDuration: Duration(milliseconds: 340),
      bounce: 0.5,
    ),
    celebrate: Move(
      perceivedDuration: Duration(milliseconds: 550),
      bounce: 0.5,
    ),
    follow: Move(perceivedDuration: Duration(milliseconds: 380), bounce: 0.35),
    loop: Move(perceivedDuration: Duration(milliseconds: 900), bounce: 0.35),
    stagger: Duration(milliseconds: 90),
  );

  /// What every app gets when the phone asks for less motion. Nothing
  /// travels: timed words become short fades. Applied automatically by
  /// `context.motion`.
  static const reduced = PoiseMotion(
    feedback: Fade(duration: Duration(milliseconds: 100)),
    enter: Fade(duration: Duration(milliseconds: 150)),
    exit: Fade(duration: Duration(milliseconds: 150)),
    transition: Fade(duration: Duration(milliseconds: 150)),
    change: Fade(duration: Duration(milliseconds: 150)),
    attention: Fade(duration: Duration(milliseconds: 150)),
    celebrate: Fade(duration: Duration(milliseconds: 150)),
    follow: Move(perceivedDuration: Duration(milliseconds: 200)),
    loop: Fade(duration: Duration(milliseconds: 150)),
    stagger: Duration.zero,
    reducesMotion: true,
  );

  /// The feel behind [word], or null for [MotionWord.stagger], which is a
  /// gap between feels rather than a feel of its own: see [stagger].
  Feel? feelOf(MotionWord word) => switch (word) {
    MotionWord.feedback => feedback,
    MotionWord.enter => enter,
    MotionWord.exit => exit,
    MotionWord.transition => transition,
    MotionWord.change => change,
    MotionWord.attention => attention,
    MotionWord.celebrate => celebrate,
    MotionWord.follow => follow,
    MotionWord.loop => loop,
    MotionWord.stagger => null,
  };

  PoiseMotion copyWith({
    Feel? feedback,
    Feel? enter,
    Feel? exit,
    Feel? transition,
    Feel? change,
    Feel? attention,
    Feel? celebrate,
    Move? follow,
    Feel? loop,
    Duration? stagger,
  }) => PoiseMotion(
    feedback: feedback ?? this.feedback,
    enter: enter ?? this.enter,
    exit: exit ?? this.exit,
    transition: transition ?? this.transition,
    change: change ?? this.change,
    attention: attention ?? this.attention,
    celebrate: celebrate ?? this.celebrate,
    follow: follow ?? this.follow,
    loop: loop ?? this.loop,
    stagger: stagger ?? this.stagger,
    reducesMotion: reducesMotion,
  );

  @override
  bool operator ==(Object other) =>
      other is PoiseMotion &&
      other.feedback == feedback &&
      other.enter == enter &&
      other.exit == exit &&
      other.transition == transition &&
      other.change == change &&
      other.attention == attention &&
      other.celebrate == celebrate &&
      other.follow == follow &&
      other.loop == loop &&
      other.stagger == stagger &&
      other.reducesMotion == reducesMotion;

  @override
  int get hashCode => Object.hash(
    feedback,
    enter,
    exit,
    transition,
    change,
    attention,
    celebrate,
    follow,
    loop,
    stagger,
    reducesMotion,
  );
}
