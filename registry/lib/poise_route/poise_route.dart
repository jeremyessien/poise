import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// A page route that moves between screens with the `transition` word, and
/// back again with `exit`.
///
/// The new screen slides in from the end edge while the one underneath
/// drifts a little the other way. Both follow the reading direction, so the
/// slide mirrors in right-to-left languages. On iOS and macOS the screen can
/// still be swiped back from its start edge, the way people expect.
///
/// Routes are built above any page, so a [PoiseScope] inside a page doesn't
/// reach them. Put a scope above your app, or pass [motion]. Either way, when
/// the phone asks for less motion the screens cross-fade instead of sliding.
final class PoiseRoute<T> extends PageRoute<T> {
  PoiseRoute({
    required this.builder,
    this.motion,
    super.settings,
    super.fullscreenDialog,
    this.maintainState = true,
  });

  final WidgetBuilder builder;

  /// The personality to move in, when the app's own scope isn't the one.
  final PoiseMotion? motion;

  @override
  final bool maintainState;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  /// Read without registering a dependency, because routes ask for their
  /// durations outside of any build.
  PoiseMotion get _motion {
    final context = navigator?.context;
    final reduced =
        context
            ?.getInheritedWidgetOfExactType<MediaQuery>()
            ?.data
            .disableAnimations ??
        false;
    if (reduced) return PoiseMotion.reduced;
    return motion ??
        context?.getInheritedWidgetOfExactType<PoiseScope>()?.motion ??
        PoiseMotion.calm;
  }

  @override
  Duration get transitionDuration => _motion.transition.duration;

  void _swipeStarted() => navigator?.didStartUserGesture();

  /// Puts the screen exactly where the finger is: [shown] is 1 when it fills
  /// the screen and 0 when it has gone.
  void _swipeMoved(double shown) => controller?.value = shown;

  /// Hands the screen from the finger to a `follow` spring, carrying on from
  /// where it is at the finger's [speed], in screens per second towards
  /// shown. It stays if it was mostly shown or flung back, and leaves if not.
  Future<void> _swipeReleased(double speed) async {
    final controller = this.controller;
    final navigator = this.navigator;
    if (controller == null || navigator == null) return;
    final stays = speed.abs() >= _flingSpeed
        ? speed > 0
        : controller.value > 0.5;
    final target = stays ? 1.0 : 0.0;
    if (!stays) navigator.pop();
    try {
      await controller
          .animateWith(
            SpringSimulation(
              _motion.follow.spring,
              controller.value,
              target,
              speed,
            ),
          )
          .orCancel;
      controller.value = target;
    } on TickerCanceled {
      return;
    } finally {
      navigator.didStopUserGesture();
    }
  }

  static const _flingSpeed = 1.0;

  @override
  Duration get reverseTransitionDuration => _motion.exit.duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    child: builder(context),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _PoiseTransition(
    route: this,
    motion: _motion,
    arriving: animation,
    covered: secondaryAnimation,
    child: child,
  );
}

final class _PoiseTransition extends StatefulWidget {
  const _PoiseTransition({
    required this.route,
    required this.motion,
    required this.arriving,
    required this.covered,
    required this.child,
  });

  final PoiseRoute<dynamic> route;
  final PoiseMotion motion;
  final Animation<double> arriving;
  final Animation<double> covered;
  final Widget child;

  @override
  State<_PoiseTransition> createState() => _PoiseTransitionState();
}

final class _PoiseTransitionState extends State<_PoiseTransition> {
  static const _coveredDrift = 0.25;

  late CurvedAnimation _arriving;
  late CurvedAnimation _covered;

  @override
  void initState() {
    super.initState();
    _curve();
  }

  @override
  void didUpdateWidget(_PoiseTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.arriving != widget.arriving ||
        oldWidget.covered != widget.covered ||
        oldWidget.motion != widget.motion) {
      _arriving.dispose();
      _covered.dispose();
      _curve();
    }
  }

  void _curve() {
    final transition = widget.motion.transition.curve;
    final exit = widget.motion.exit.curve;
    _arriving = CurvedAnimation(
      parent: widget.arriving,
      curve: transition,
      reverseCurve: exit.flipped,
    );
    _covered = CurvedAnimation(
      parent: widget.covered,
      curve: transition,
      reverseCurve: exit.flipped,
    );
  }

  ValueListenable<bool>? _gesture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gesture = widget.route.navigator?.userGestureInProgressNotifier;
    if (gesture != _gesture) {
      _gesture?.removeListener(_gestureChanged);
      _gesture = gesture?..addListener(_gestureChanged);
    }
  }

  void _gestureChanged() => setState(() {});

  @override
  void dispose() {
    _gesture?.removeListener(_gestureChanged);
    _arriving.dispose();
    _covered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.motion.transition is Move;
    final towardsEnd = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;

    final following = widget.route.navigator?.userGestureInProgress ?? false;
    final arriving = following ? widget.arriving : _arriving;
    final covered = following ? widget.covered : _covered;

    final page = slides
        ? SlideTransition(
            position: covered.drive(
              Tween(
                begin: Offset.zero,
                end: Offset(-_coveredDrift * towardsEnd, 0),
              ),
            ),
            child: SlideTransition(
              position: arriving.drive(
                Tween(begin: Offset(towardsEnd, 0), end: Offset.zero),
              ),
              child: widget.child,
            ),
          )
        : FadeTransition(opacity: arriving, child: widget.child);

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS => _EdgeSwipeBack(route: widget.route, child: page),
      _ => page,
    };
  }
}

/// Lets the screen be dragged back from its start edge. The route follows
/// the finger exactly, and tells the navigator a gesture is in progress.
final class _EdgeSwipeBack extends StatefulWidget {
  const _EdgeSwipeBack({required this.route, required this.child});

  final PoiseRoute<dynamic> route;
  final Widget child;

  @override
  State<_EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

final class _EdgeSwipeBackState extends State<_EdgeSwipeBack> {
  static const _edgeWidth = 20.0;

  var _swiping = false;
  var _shown = 1.0;

  double get _width => context.size?.width ?? 1;

  double get _towardsEnd =>
      Directionality.of(context) == TextDirection.ltr ? 1 : -1;

  void _started(DragStartDetails _) {
    if (!widget.route.popGestureEnabled) return;
    _swiping = true;
    _shown = 1;
    widget.route._swipeStarted();
  }

  void _dragged(DragUpdateDetails details) {
    if (!_swiping) return;
    final moved = (details.primaryDelta ?? 0) * _towardsEnd / _width;
    _shown = (_shown - moved).clamp(0.0, 1.0);
    widget.route._swipeMoved(_shown);
  }

  void _released(DragEndDetails details) {
    if (!_swiping) return;
    _swiping = false;
    final towardsShown = -(details.primaryVelocity ?? 0) * _towardsEnd / _width;
    widget.route._swipeReleased(towardsShown);
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      PositionedDirectional(
        start: 0,
        top: 0,
        bottom: 0,
        width: _edgeWidth,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _started,
          onHorizontalDragUpdate: _dragged,
          onHorizontalDragEnd: _released,
          onHorizontalDragCancel: () => _released(DragEndDetails()),
        ),
      ),
    ],
  );
}
