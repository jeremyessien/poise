import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

import '../theme.dart';
import 'gather_style.dart';

final class PersonalityDial extends StatefulWidget {
  const PersonalityDial({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Personality selected;
  final ValueChanged<Personality> onChanged;

  @override
  State<PersonalityDial> createState() => _PersonalityDialState();
}

final class _PersonalityDialState extends State<PersonalityDial>
    with SingleTickerProviderStateMixin {
  static const _segmentWidth = 92.0;
  static const _height = 44.0;
  static const _inset = 4.0;

  late final AnimationController _position;

  @override
  void initState() {
    super.initState();
    _position = AnimationController.unbounded(
      vsync: this,
      value: widget.selected.index.toDouble(),
    );
  }

  @override
  void didUpdateWidget(PersonalityDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _slideTo(widget.selected);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _slideTo(Personality personality) {
    final target = personality.index.toDouble();
    switch (context.motion.transition) {
      case Move(:final spring):
        _position.animateWith(
          SpringSimulation(spring, _position.value, target, _position.velocity),
        );
      case Fade():
        _position.value = target;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_inset),
    decoration: BoxDecoration(
      color: GatherColors.dial,
      borderRadius: BorderRadius.circular(_height),
    ),
    child: SizedBox(
      width: _segmentWidth * Personality.values.length,
      height: _height,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _position,
            builder: (context, indicator) => PositionedDirectional(
              start: _position.value * _segmentWidth,
              top: 0,
              bottom: 0,
              width: _segmentWidth,
              child: indicator ?? const SizedBox.shrink(),
            ),
            child: DecoratedBox(
              key: const ValueKey('dial-highlight'),
              decoration: BoxDecoration(
                color: GatherColors.dialText,
                borderRadius: BorderRadius.circular(_height),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (final personality in Personality.values)
                  _Segment(
                    personality: personality,
                    selected: personality == widget.selected,
                    width: _segmentWidth,
                    onTap: () => widget.onChanged(personality),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final class _Segment extends StatelessWidget {
  const _Segment({
    required this.personality,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final Personality personality;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${personality.label} motion',
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: personality.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  personality.label,
                  style: GatherType.dial.copyWith(
                    color: selected ? GatherColors.dial : GatherColors.dialText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
