import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'scope.dart';

/// The four haptic words. Each one is a single short haptic the user feels,
/// and [play] sends it to the phone.
enum HapticWord {
  /// The app felt a touch: a press on a card, a row or a custom button.
  tap,

  /// A value moved by one step: a toggle, a segmented control, a picker.
  select,

  /// Something the user did has worked: a payment, a booking, a task done.
  /// For outcomes, not small moments such as a like, which is a [tap].
  confirm,

  /// Something the user did hasn't worked: a wrong password, a refused card.
  warn;

  /// Plays this word, unless the nearest [PoiseScope] has turned haptics
  /// off. The phone's own haptics setting still decides whether anything is
  /// felt. On Android before 11, [confirm] and [warn] are silent.
  Future<void> play(BuildContext context) async {
    if (!PoiseScope.hapticsOf(context)) return;
    await switch (this) {
      HapticWord.tap => HapticFeedback.lightImpact(),
      HapticWord.select => HapticFeedback.selectionClick(),
      HapticWord.confirm => HapticFeedback.successNotification(),
      HapticWord.warn => HapticFeedback.errorNotification(),
    };
  }
}
