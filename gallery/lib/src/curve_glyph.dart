import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'word_feel.dart';
import 'words.dart';

final class CurveGlyph extends StatelessWidget {
  const CurveGlyph({super.key, required this.word});

  static const size = Size(76, 44);

  final MotionWord word;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: size, painter: _CurveGlyphPainter(word)),
  );
}

final class _CurveGlyphPainter extends CustomPainter {
  _CurveGlyphPainter(this.word);

  final MotionWord word;

  static const _samples = 48;
  static const _inset = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTRB(0, _inset, size.width, size.height - _inset);
    if (word == MotionWord.stagger) {
      _paintStagger(canvas, box);
      return;
    }

    final window =
        Personality.values
            .map((p) => feltMicros(word.feelIn(p.motion)))
            .reduce(math.max) *
        curveWindowStretch;
    if (window == 0) return;

    for (final personality in Personality.values) {
      final feel = word.feelIn(personality.motion);
      if (feel == null) continue;
      final runs = feel.duration.inMicroseconds;
      final path = Path();
      for (var step = 0; step <= _samples; step++) {
        final x = step / _samples;
        final t = (x * window / runs).clamp(0.0, 1.0);
        final progress = progressAt(word, feel, t);
        final point = Offset(
          box.left + x * box.width,
          box.bottom - progress * box.height * 0.8,
        );
        step == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, _stroke(personality.color));
    }
  }

  void _paintStagger(Canvas canvas, Rect box) {
    const items = 4;
    final widestGap = Personality.values
        .map((p) => p.motion.stagger.inMicroseconds)
        .reduce(math.max);
    for (final (row, personality) in Personality.values.indexed) {
      final y = box.top + box.height * (row + 0.5) / Personality.values.length;
      final gap =
          personality.motion.stagger.inMicroseconds / widestGap * box.width / 4;
      for (var item = 0; item < items; item++) {
        canvas.drawCircle(
          Offset(box.left + 4 + item * gap, y),
          3,
          Paint()..color = personality.color,
        );
      }
    }
  }

  Paint _stroke(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(_CurveGlyphPainter oldDelegate) =>
      oldDelegate.word != word;
}
