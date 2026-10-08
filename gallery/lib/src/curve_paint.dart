import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:poise/poise.dart';

import 'theme.dart';

/// Charts show the longest perceived duration among the personalities,
/// stretched a little so a spring's tail is visible.
const _windowStretch = 0.8;

double curveWindowMicros(MotionWord word) =>
    Personality.values
        .map((p) => _feltMicros(p.motion.feelOf(word)))
        .reduce(math.max) *
    _windowStretch;

int _feltMicros(Feel? feel) => switch (feel) {
  Move(:final perceivedDuration) => perceivedDuration.inMicroseconds,
  Fade(:final duration) => duration.inMicroseconds,
  null => 0,
};

/// The curve of [feel] as [word] would run it, drawn left to right across
/// [box] over [windowMicros], rising to [rise] of the box's height.
Path wordCurvePath(
  MotionWord word,
  Feel feel,
  Rect box, {
  required double windowMicros,
  required int samples,
  required double rise,
}) {
  final curve = feel.curve;
  final runs = feel.duration.inMicroseconds;
  final path = Path();
  for (var step = 0; step <= samples; step++) {
    final x = step / samples;
    final t = (x * windowMicros / runs).clamp(0.0, 1.0);
    final point = Offset(
      box.left + x * box.width,
      box.bottom - _progressAt(word, curve, t) * box.height * rise,
    );
    step == 0
        ? path.moveTo(point.dx, point.dy)
        : path.lineTo(point.dx, point.dy);
  }
  return path;
}

double _progressAt(MotionWord word, Curve curve, double t) => switch (word) {
  MotionWord.exit => 1 - curve.transform(t),
  MotionWord.loop =>
    t < 0.5 ? curve.transform(t * 2) : curve.transform((1 - t) * 2),
  _ => curve.transform(t),
};

/// Stagger has no curve, so it is drawn as a row of dots per personality,
/// spaced in proportion to its gap.
void paintStaggerDots(
  Canvas canvas,
  Rect box,
  Iterable<Personality> order, {
  required int items,
  required double radius,
  required Color Function(Personality) colorOf,
}) {
  final widest = Personality.values
      .map((p) => p.motion.stagger.inMicroseconds)
      .reduce(math.max);
  for (final personality in order) {
    final y =
        box.top +
        box.height * (personality.index + 0.5) / Personality.values.length;
    final gap =
        personality.motion.stagger.inMicroseconds /
        widest *
        (box.width - 2 * radius) /
        (items - 1);
    final paint = Paint()..color = colorOf(personality);
    for (var item = 0; item < items; item++) {
      canvas.drawCircle(
        Offset(box.left + radius + item * gap, y),
        radius,
        paint,
      );
    }
  }
}

Paint curveStroke(Color color, {double width = 2}) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
