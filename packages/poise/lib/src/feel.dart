import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// How something moves: either a [Move] (a spring) or a [Fade].
///
/// Every feel can hand Flutter's animated widgets a [duration] and a [curve].
sealed class Feel {
  const Feel();

  Duration get duration;
  Curve get curve;
}

/// A spring, for anything that changes position, size or rotation.
///
/// Described the way people picture it: how long it looks like it takes,
/// and how much it overshoots, from 0 (no bounce) to about 0.5 (very bouncy).
final class Move extends Feel {
  const Move({required this.perceivedDuration, this.bounce = 0})
    : assert(bounce >= 0 && bounce < 1);

  final Duration perceivedDuration;
  final double bounce;

  /// The real spring, for gestures that need to carry on from a finger's speed.
  SpringDescription get spring => SpringDescription.withDurationAndBounce(
    duration: perceivedDuration,
    bounce: bounce,
  );

  @override
  Duration get duration => settleDuration;

  /// How long the spring takes to actually stop, which is longer than
  /// [perceivedDuration] because of the tail. Animations run this long so a
  /// bounce is never cut off and snapped onto its target.
  Duration get settleDuration =>
      _settleDurations[(perceivedDuration, bounce)] ??= _measureSettle(spring);

  @override
  Curve get curve => _SpringCurve(spring, settleDuration);

  static final Map<(Duration, double), Duration> _settleDurations = {};

  static const _settledWithin = Tolerance(velocity: 0.01);
  static const _frame = Duration(microseconds: 1000000 ~/ 120);
  static const _longestSettle = Duration(seconds: 5);

  static Duration _measureSettle(SpringDescription spring) {
    final simulation = SpringSimulation(
      spring,
      0,
      1,
      0,
      tolerance: _settledWithin,
    );
    var elapsed = Duration.zero;
    while (elapsed < _longestSettle && !simulation.isDone(_seconds(elapsed))) {
      elapsed += _frame;
    }
    return elapsed;
  }
}

/// A duration and a curve, for colour and opacity. Fades never overshoot.
final class Fade extends Feel {
  const Fade({required this.duration, this.curve = Curves.easeOutCubic});

  @override
  final Duration duration;

  @override
  final Curve curve;
}

final class _SpringCurve extends Curve {
  _SpringCurve(SpringDescription spring, Duration settleDuration)
    : _simulation = SpringSimulation(spring, 0, 1, 0),
      _settleSeconds = _seconds(settleDuration);

  final SpringSimulation _simulation;
  final double _settleSeconds;

  @override
  double transformInternal(double t) => _simulation.x(t * _settleSeconds);
}

double _seconds(Duration duration) =>
    duration.inMicroseconds / Duration.microsecondsPerSecond;
