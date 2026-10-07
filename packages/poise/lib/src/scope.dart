import 'package:flutter/widgets.dart';

import 'personality.dart';

final class PoiseScope extends InheritedWidget {
  const PoiseScope({super.key, required this.motion, required super.child});

  final PoiseMotion motion;

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

extension PoiseContext on BuildContext {
  PoiseMotion get motion => PoiseScope.motionOf(this);
}
