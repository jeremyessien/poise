import 'package:flutter/widgets.dart';

import 'personality.dart';

/// Sets the motion personality for everything below it.
///
/// Put one above your app, and another above any part that should feel
/// different. The nearest one wins. Works in any Flutter app, not just
/// Material ones.
final class PoiseScope extends InheritedWidget {
  const PoiseScope({super.key, required this.motion, required super.child});

  final PoiseMotion motion;

  /// The personality from the nearest [PoiseScope], or [PoiseMotion.calm] if
  /// there isn't one. Returns [PoiseMotion.reduced] whenever the phone asks
  /// for less motion.
  static PoiseMotion motionOf(BuildContext context) {
    final scoped =
        context.dependOnInheritedWidgetOfExactType<PoiseScope>()?.motion ??
        PoiseMotion.calm;
    final userAskedForLessMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return userAskedForLessMotion ? PoiseMotion.reduced : scoped;
  }

  @override
  bool updateShouldNotify(PoiseScope oldWidget) => motion != oldWidget.motion;
}

/// Lets any widget write `context.motion.enter`.
extension PoiseContext on BuildContext {
  PoiseMotion get motion => PoiseScope.motionOf(this);
}
