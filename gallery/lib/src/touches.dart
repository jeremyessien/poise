import 'package:flutter/widgets.dart';

import 'settings.dart';
import 'theme.dart';

final class ShowTouches extends StatefulWidget {
  const ShowTouches({super.key, required this.child});

  final Widget child;

  @override
  State<ShowTouches> createState() => _ShowTouchesState();
}

final class _ShowTouchesState extends State<ShowTouches> {
  final _touches = <int, _Touch>{};

  void _down(PointerEvent event) =>
      setState(() => _touches[event.pointer] = _Touch(event.position));

  void _move(PointerEvent event) {
    final touch = _touches[event.pointer];
    if (touch == null) return;
    setState(() => _touches[event.pointer] = touch.movedTo(event.position));
  }

  void _up(PointerEvent event) {
    final touch = _touches[event.pointer];
    if (touch == null) return;
    setState(() => _touches[event.pointer] = touch.lifted());
  }

  @override
  Widget build(BuildContext context) {
    final showing = GallerySettingsScope.of(context).showTouches;
    return Listener(
      onPointerDown: showing ? _down : null,
      onPointerMove: showing ? _move : null,
      onPointerUp: showing ? _up : null,
      onPointerCancel: showing ? _up : null,
      child: Stack(
        children: [
          widget.child,
          if (showing)
            for (final MapEntry(key: pointer, value: touch) in _touches.entries)
              Positioned(
                key: ValueKey(pointer),
                left: touch.position.dx - _TouchDot.size / 2,
                top: touch.position.dy - _TouchDot.size / 2,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: touch.isDown ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    onEnd: () {
                      if (!touch.isDown) {
                        setState(() => _touches.remove(pointer));
                      }
                    },
                    child: const _TouchDot(),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

final class _Touch {
  const _Touch(this.position, {this.isDown = true});

  final Offset position;
  final bool isDown;

  _Touch movedTo(Offset position) => _Touch(position, isDown: isDown);
  _Touch lifted() => _Touch(position, isDown: false);
}

final class _TouchDot extends StatelessWidget {
  const _TouchDot();

  static const size = 44.0;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: GalleryColors.ink.withValues(alpha: 0.18),
      border: Border.all(
        color: GalleryColors.ink.withValues(alpha: 0.35),
        width: 1.5,
      ),
    ),
  );
}
