import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// A bottom sheet you can drag and throw. Put it last in a [Stack] that fills
/// the screen, and open it by setting [open] to true.
///
/// It rises with the `enter` word and leaves with `exit`. While open it
/// follows the finger, and when the finger lets go it settles with `follow`
/// from the speed it was thrown at: back up if it was only nudged, away if it
/// was pulled far enough or flicked. Pulling it, tapping the scrim and the
/// system back gesture all call [onClose]; the sheet only leaves once [open]
/// turns false, so the parent stays in charge.
///
/// When the phone asks for less motion, opening and closing fade in place.
/// Dragging still moves the sheet, because the finger is driving it, but it
/// settles without bouncing.
final class PoiseSheet extends StatefulWidget {
  const PoiseSheet({
    super.key,
    required this.open,
    required this.onClose,
    required this.child,
    this.color = const Color(0xFFFFFFFF),
    this.scrimColor = const Color(0x59000000),
    this.closeLabel = 'Close',
  });

  final bool open;

  /// Called when the sheet asks to close: pulled down, scrim tapped or back.
  final VoidCallback onClose;

  final Widget child;
  final Color color;
  final Color scrimColor;

  /// What a screen reader announces for the scrim behind the sheet.
  final String closeLabel;

  @override
  State<PoiseSheet> createState() => _PoiseSheetState();
}

final class _PoiseSheetState extends State<PoiseSheet>
    with SingleTickerProviderStateMixin {
  static const _pulledFarEnough = 0.3;
  static const _flickSpeed = 700.0;
  static const _overpullResistance = 0.25;
  static const _overhang = 48.0;

  late final AnimationController _shown;
  final _sheet = GlobalKey();
  late PoiseMotion _motion;
  late Feel _feel;
  var _settledIn = false;
  double? _releaseSpeed;

  @override
  void initState() {
    super.initState();
    _shown = AnimationController.unbounded(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previous = _settledIn ? _motion : null;
    _motion = context.motion;
    if (!_settledIn) {
      _settledIn = true;
      _feel = _motion.enter;
      if (widget.open) _animate(open: true);
    } else if (previous != _motion && _shown.isAnimating) {
      _animate(open: widget.open);
    }
  }

  @override
  void didUpdateWidget(PoiseSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != widget.open) _animate(open: widget.open);
  }

  @override
  void dispose() {
    _shown.dispose();
    super.dispose();
  }

  double get _height => _sheet.currentContext?.size?.height ?? 1;

  Future<void> _animate({required bool open}) async {
    final target = open ? 1.0 : 0.0;
    final releaseSpeed = _releaseSpeed;
    _releaseSpeed = null;
    _feel = switch (releaseSpeed) {
      double() => _motion.follow,
      null => open ? _motion.enter : _motion.exit,
    };
    final run = switch (_feel) {
      Move(:final spring) => _shown.animateWith(
        SpringSimulation(
          spring,
          _shown.value,
          target,
          releaseSpeed ?? _shown.velocity,
        ),
      ),
      Fade(:final duration, :final curve) => _shown.animateTo(
        target,
        duration: duration,
        curve: curve,
      ),
    };
    try {
      await run.orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) _shown.value = target;
  }

  void _dragStarted(DragStartDetails _) {
    _shown.stop();
    _feel = _motion.follow;
  }

  void _dragged(DragUpdateDetails details) {
    final pulled = (details.primaryDelta ?? 0) / _height;
    final resistance = _shown.value > 1 ? _overpullResistance : 1.0;
    _shown.value = (_shown.value - pulled * resistance).clamp(0.0, 2.0);
  }

  void _released(DragEndDetails details) {
    final speed = -(details.primaryVelocity ?? 0) / _height;
    final flickedDown = (details.primaryVelocity ?? 0) > _flickSpeed;
    final pulledFar = _shown.value < 1 - _pulledFarEnough;
    _releaseSpeed = speed;
    if (flickedDown || pulledFar) {
      widget.onClose();
      WidgetsBinding.instance
        ..addPostFrameCallback((_) {
          if (mounted && widget.open) _animate(open: true);
        })
        ..scheduleFrame();
    } else {
      _animate(open: true);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.open,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) widget.onClose();
    },
    child: AnimatedBuilder(
      animation: _shown,
      builder: (context, sheet) {
        final shown = _shown.value.clamp(0.0, 1.0);
        final gone = shown == 0 && !widget.open && !_shown.isAnimating;
        if (gone) return const SizedBox.shrink();
        final travels = _feel is Move;
        return Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                button: true,
                label: widget.closeLabel,
                onTap: widget.onClose,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: widget.open ? widget.onClose : null,
                  child: ColoredBox(
                    color: widget.scrimColor.withValues(
                      alpha: widget.scrimColor.a * shown,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: !widget.open,
                child: Transform.translate(
                  offset: const Offset(0, _overhang),
                  child: FractionalTranslation(
                    translation: Offset(0, travels ? 1 - _shown.value : 0),
                    child: Opacity(opacity: travels ? 1 : shown, child: sheet),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _dragStarted,
        onVerticalDragUpdate: _dragged,
        onVerticalDragEnd: _released,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: DecoratedBox(
            key: _sheet,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Handle(),
                  widget.child,
                  const SizedBox(height: _overhang),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

final class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Container(
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}
