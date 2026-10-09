import 'package:flutter/foundation.dart';
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

  @override
  void dispose() {
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

    final page = slides
        ? SlideTransition(
            position: _covered.drive(
              Tween(
                begin: Offset.zero,
                end: Offset(-_coveredDrift * towardsEnd, 0),
              ),
            ),
            child: SlideTransition(
              position: _arriving.drive(
                Tween(begin: Offset(towardsEnd, 0), end: Offset.zero),
              ),
              child: widget.child,
            ),
          )
        : FadeTransition(opacity: _arriving, child: widget.child);

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS => _EdgeSwipeBack(route: widget.route, child: page),
      _ => page,
    };
  }
}

/// Lets the screen be dragged back from its start edge, driving the route's
/// own back gesture so the navigator knows a gesture is in progress.
final class _EdgeSwipeBack extends StatefulWidget {
  const _EdgeSwipeBack({required this.route, required this.child});

  final PoiseRoute<dynamic> route;
  final Widget child;

  @override
  State<_EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

final class _EdgeSwipeBackState extends State<_EdgeSwipeBack> {
  static const _edgeWidth = 20.0;
  static const _flingSpeed = 1.0;

  var _swiping = false;
  var _shown = 1.0;

  double get _width => context.size?.width ?? 1;

  double get _towardsEnd =>
      Directionality.of(context) == TextDirection.ltr ? 1 : -1;

  void _started(DragStartDetails _) {
    if (!widget.route.popGestureEnabled) return;
    _swiping = true;
    _shown = 1;
    widget.route.handleStartBackGesture(progress: _shown);
  }

  void _dragged(DragUpdateDetails details) {
    if (!_swiping) return;
    final moved = (details.primaryDelta ?? 0) * _towardsEnd / _width;
    _shown = (_shown - moved).clamp(0.0, 1.0);
    widget.route.handleUpdateBackGestureProgress(progress: _shown);
  }

  void _released(DragEndDetails details) {
    if (!_swiping) return;
    _swiping = false;
    final speed = (details.primaryVelocity ?? 0) * _towardsEnd / _width;
    if (speed > _flingSpeed || (speed > -_flingSpeed && _shown < 0.5)) {
      widget.route.handleCommitBackGesture();
    } else {
      widget.route.handleCancelBackGesture();
    }
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
