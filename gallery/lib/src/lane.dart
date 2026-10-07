import 'package:flutter/material.dart';

import 'theme.dart';

abstract final class LaneGeometry {
  static const height = 260.0;
  static const objectSize = 44.0;
  static const restTop = height * 0.35;
  static const belowLane = height;
}

final class PlaySignal extends ChangeNotifier {
  void play() => notifyListeners();
}

final class Lane extends StatelessWidget {
  const Lane({super.key, required this.personality, required this.child});

  final Personality personality;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: LaneGeometry.height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: GalleryColors.lane,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GalleryColors.grid),
        ),
        child: CustomPaint(
          painter: const _ChartPaper(),
          child: _LanePersonality(personality: personality, child: child),
        ),
      ),
      const SizedBox(height: 10),
      Text(personality.label, style: GalleryType.label),
      const SizedBox(height: 4),
      Container(width: 24, height: 3, color: personality.color),
    ],
  );
}

final class LaneObject extends StatelessWidget {
  const LaneObject({
    super.key,
    this.size = LaneGeometry.objectSize,
    this.primary = true,
    this.child,
  });

  final double size;
  final bool primary;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final personality = _LanePersonality.of(context);
    return Container(
      key: primary ? ValueKey('lane-object-${personality.label}') : null,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: personality.color,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: child,
    );
  }
}

final class _LanePersonality extends InheritedWidget {
  const _LanePersonality({required this.personality, required super.child});

  final Personality personality;

  static Personality of(BuildContext context) {
    final lane = context.dependOnInheritedWidgetOfExactType<_LanePersonality>();
    if (lane == null) throw FlutterError('LaneObject must be inside a Lane.');
    return lane.personality;
  }

  @override
  bool updateShouldNotify(_LanePersonality oldWidget) =>
      personality != oldWidget.personality;
}

final class _ChartPaper extends CustomPainter {
  const _ChartPaper();

  static const _cell = 16.0;
  static const _dash = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GalleryColors.grid
      ..strokeWidth = 1;
    final firstColumn = (size.width % _cell) / 2;
    for (var x = firstColumn; x < size.width; x += _cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = _cell; y < size.height; y += _cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final target = Paint()
      ..color = GalleryColors.ink.withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += _dash * 2) {
      canvas.drawLine(
        Offset(x, LaneGeometry.restTop),
        Offset(x + _dash, LaneGeometry.restTop),
        target,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPaper oldDelegate) => false;
}
