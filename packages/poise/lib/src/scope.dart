import 'package:flutter/widgets.dart';

import 'personality.dart';

/// Sets the motion personality, and whether haptics play, for everything
/// below it.
///
/// Put one above your app, and another above any part that should feel
/// different. The nearest one wins. Works in any Flutter app, not just
/// Material ones.
final class PoiseScope extends InheritedWidget {
  const PoiseScope({
    super.key,
    required this.motion,
    this.haptics,
    required super.child,
  });

  final PoiseMotion motion;

  /// Whether haptic words play below this scope. Set it to false when the
  /// app's own settings turn vibration off. Left out, it follows the scope
  /// above, so a nested scope that only changes the personality doesn't
  /// switch haptics back on.
  final bool? haptics;

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

  /// Whether haptic words play here: the [haptics] of the nearest
  /// [PoiseScope] that sets it, or true if none does. Read it at the moment a
  /// haptic plays, not in build, because it doesn't rebuild anything.
  static bool hapticsOf(BuildContext context) {
    bool? haptics;
    context.visitAncestorElements((element) {
      if (element.widget case PoiseScope(haptics: final setting?)) {
        haptics = setting;
        return false;
      }
      return true;
    });
    return haptics ?? true;
  }

  @override
  bool updateShouldNotify(PoiseScope oldWidget) => motion != oldWidget.motion;
}

/// Lets any widget write `context.motion.enter`.
extension PoiseContext on BuildContext {
  PoiseMotion get motion => PoiseScope.motionOf(this);
}
