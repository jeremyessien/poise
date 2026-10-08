import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import 'lane.dart';
import 'settings.dart';
import 'word_feel.dart';
import 'words.dart';

final class LaneCurve extends StatelessWidget {
  const LaneCurve({
    super.key,
    required this.word,
    required this.color,
    required this.windowMicros,
  });

  final MotionWord word;
  final Color color;
  final double windowMicros;

  @override
  Widget build(BuildContext context) {
    final feel = word.feelIn(context.motion);
    if (!GallerySettingsScope.of(context).showCurve || feel == null) {
      return const SizedBox.shrink();
    }
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _LaneCurvePainter(word, feel, color, windowMicros),
      ),
    );
  }
}

final class _LaneCurvePainter extends CustomPainter {
  _LaneCurvePainter(this.word, this.feel, this.color, this.windowMicros);

  final MotionWord word;
  final Feel feel;
  final Color color;
  final double windowMicros;

  static const _samples = 96;
  static const _travel = LaneGeometry.belowLane - LaneGeometry.restTop;

  @override
  void paint(Canvas canvas, Size size) {
    if (windowMicros == 0) return;
    final runs = feel.duration.inMicroseconds;
    final path = Path();
    for (var step = 0; step <= _samples; step++) {
      final x = step / _samples;
      final t = (x * windowMicros / runs).clamp(0.0, 1.0);
      final y = LaneGeometry.belowLane - progressAt(word, feel, t) * _travel;
      step == 0
          ? path.moveTo(x * size.width, y)
          : path.lineTo(x * size.width, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LaneCurvePainter oldDelegate) =>
      oldDelegate.word != word ||
      oldDelegate.feel != feel ||
      oldDelegate.color != color ||
      oldDelegate.windowMicros != windowMicros;
}
