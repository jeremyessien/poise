import 'package:flutter/material.dart';

import 'curve_paint.dart';
import 'theme.dart';
import 'words.dart';

/// The curve of one word in every personality, with [selected] drawn on top.
/// Pass [titled] false when the page already says which word this is.
final class RecipeCurves extends StatelessWidget {
  const RecipeCurves({
    super.key,
    required this.word,
    required this.selected,
    this.titled = true,
  });

  final MotionWord word;
  final Personality selected;
  final bool titled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (titled) ...[
        Text(word.name, style: GalleryType.label),
        const SizedBox(height: 2),
        Text(word.description, style: GalleryType.group),
        const SizedBox(height: 10),
      ],
      Container(
        height: 120,
        width: double.infinity,
        decoration: cardDecoration(radius: 14),
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
    final selectedLast = [
      ...Personality.values.where((p) => p != selected),
      selected,
    ];

    if (word == MotionWord.stagger) {
      paintStaggerDots(
        canvas,
        box,
        selectedLast,
        items: 6,
        radius: 4,
        colorOf: _colorOf,
      );
      return;
    }

    final window = curveWindowMicros(word);
    for (final personality in selectedLast) {
      final feel = personality.motion.feelOf(word);
      if (feel == null) continue;
      canvas.drawPath(
        wordCurvePath(
          word,
          feel,
          box,
          windowMicros: window,
          samples: _samples,
          rise: 0.85,
        ),
        curveStroke(
          _colorOf(personality),
          width: personality == selected ? 3 : 2,
        ),
      );
    }
  }

  Color _colorOf(Personality personality) => personality == selected
      ? personality.color
      : personality.color.withValues(alpha: 0.25);

  @override
  bool shouldRepaint(_CurvesPainter oldDelegate) =>
      oldDelegate.word != word || oldDelegate.selected != selected;
}
