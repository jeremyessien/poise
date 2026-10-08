import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'word_feel.dart';
import 'words.dart';

final class RecipeCurves extends StatelessWidget {
  const RecipeCurves({super.key, required this.word, required this.selected});

  final MotionWord word;
  final Personality selected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(word.name, style: GalleryType.label),
      const SizedBox(height: 2),
      Text(word.description, style: GalleryType.group),
      const SizedBox(height: 10),
      Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: GalleryColors.lane,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GalleryColors.grid),
        ),
        child: ExcludeSemantics(
          child: CustomPaint(painter: _CurvesPainter(word, selected)),
        ),
      ),
    ],
  );
}

final class _CurvesPainter extends CustomPainter {
  _CurvesPainter(this.word, this.selected);

  final MotionWord word;
  final Personality selected;

  static const _samples = 96;
  static const _inset = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTRB(
      _inset,
      _inset,
      size.width - _inset,
      size.height - _inset,
    );
    final ordered = [
      ...Personality.values.where((p) => p != selected),
      selected,
    ];

    if (word == MotionWord.stagger) {
      _paintGaps(canvas, box, ordered);
      return;
    }

    final window =
        Personality.values
            .map((p) => feltMicros(word.feelIn(p.motion)))
            .reduce(math.max) *
        curveWindowStretch;
    if (window == 0) return;

    for (final personality in ordered) {
      final feel = word.feelIn(personality.motion);
      if (feel == null) continue;
      final runs = feel.duration.inMicroseconds;
      final path = Path();
      for (var step = 0; step <= _samples; step++) {
        final x = step / _samples;
        final t = (x * window / runs).clamp(0.0, 1.0);
        final point = Offset(
          box.left + x * box.width,
          box.bottom - progressAt(word, feel, t) * box.height * 0.85,
        );
        step == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, _stroke(personality));
    }
  }

  void _paintGaps(Canvas canvas, Rect box, List<Personality> ordered) {
    const items = 6;
    final widest = Personality.values
        .map((p) => p.motion.stagger.inMicroseconds)
        .reduce(math.max);
    for (final personality in ordered) {
      final row = Personality.values.indexOf(personality);
      final y = box.top + box.height * (row + 0.5) / Personality.values.length;
      final gap =
          personality.motion.stagger.inMicroseconds /
          widest *
          box.width /
          (items - 1);
      final paint = Paint()..color = _colorOf(personality);
      for (var item = 0; item < items; item++) {
        canvas.drawCircle(Offset(box.left + item * gap, y), 4, paint);
      }
    }
  }

  Color _colorOf(Personality personality) => personality == selected
      ? personality.color
      : personality.color.withValues(alpha: 0.25);

  Paint _stroke(Personality personality) => Paint()
    ..color = _colorOf(personality)
    ..style = PaintingStyle.stroke
    ..strokeWidth = personality == selected ? 3 : 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(_CurvesPainter oldDelegate) =>
      oldDelegate.word != word || oldDelegate.selected != selected;
}
