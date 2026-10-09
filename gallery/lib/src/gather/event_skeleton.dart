import 'package:flutter/widgets.dart';

import 'gather_style.dart';

/// The grey outline of an event card, shown while events load.
final class EventSkeleton extends StatelessWidget {
  const EventSkeleton({super.key});

  static const _shade = Color(0xFFE9E9EE);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: GatherColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GatherColors.hairline),
    ),
    child: Row(
      children: [
        Container(
          width: 56,
          height: 60,
          decoration: BoxDecoration(
            color: _shade,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bar(widthFactor: 0.7, height: 16),
              SizedBox(height: 10),
              _Bar(widthFactor: 0.5, height: 12),
              SizedBox(height: 8),
              _Bar(widthFactor: 0.35, height: 12),
            ],
          ),
        ),
      ],
    ),
  );
}

final class _Bar extends StatelessWidget {
  const _Bar({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: EventSkeleton._shade,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    ),
  );
}
