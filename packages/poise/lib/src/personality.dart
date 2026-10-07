import 'feel.dart';

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

  final Feel feedback;
  final Feel enter;
  final Feel exit;
  final Feel transition;
  final Feel change;
  final Feel attention;
  final Feel celebrate;
  final Move follow;
  final Feel loop;
  final Duration stagger;
  final bool reducesMotion;

  static const calm = PoiseMotion(
    feedback: Move(perceivedDuration: Duration(milliseconds: 120)),
    enter: Move(perceivedDuration: Duration(milliseconds: 300)),
    exit: Move(perceivedDuration: Duration(milliseconds: 200)),
    transition: Move(perceivedDuration: Duration(milliseconds: 350)),
    change: Fade(duration: Duration(milliseconds: 200)),
    attention: Move(
      perceivedDuration: Duration(milliseconds: 250),
      bounce: 0.3,
    ),
    celebrate: Move(perceivedDuration: Duration(milliseconds: 400)),
    follow: Move(perceivedDuration: Duration(milliseconds: 300)),
    loop: Fade(duration: Duration(milliseconds: 1200)),
    stagger: Duration(milliseconds: 40),
  );

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
}
