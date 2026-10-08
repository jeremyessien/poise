import 'package:flutter/material.dart';

import 'curve_paint.dart';
import 'theme.dart';
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
      paintStaggerDots(
        canvas,
        box,
        Personality.values,
        items: 4,
        radius: 3,
        colorOf: (personality) => personality.color,
      );
      return;
    }

    final window = curveWindowMicros(word);
    for (final personality in Personality.values) {
      final feel = personality.motion.feelOf(word);
      if (feel == null) continue;
      canvas.drawPath(
        wordCurvePath(
          word,
          feel,
          box,
          windowMicros: window,
          samples: _samples,
          rise: 0.8,
        ),
        curveStroke(personality.color),
      );
    }
  }

  @override
  bool shouldRepaint(_CurveGlyphPainter oldDelegate) =>
      oldDelegate.word != word;
}
