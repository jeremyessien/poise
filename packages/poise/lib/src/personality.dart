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
}
