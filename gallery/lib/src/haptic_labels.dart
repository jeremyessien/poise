import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

import 'settings.dart';
import 'theme.dart';

/// The haptic words the app has played, so they can be shown on screen. A
/// haptic can't be seen in a simulator or a recording otherwise.
final class PlayedHaptics extends ChangeNotifier {
  HapticWord? _last;
  var _count = 0;

  HapticWord? get last => _last;

  /// Goes up with every haptic, so the same word twice in a row still shows.
  int get count => _count;

  void heard(HapticWord word) {
    _last = word;
    _count++;
    notifyListeners();
  }
}

/// Hears every haptic on its way to the phone and passes it straight on.
final class HapticListeningMessenger implements BinaryMessenger {
  HapticListeningMessenger(this._inner, this._haptics);

  final BinaryMessenger _inner;
  final PlayedHaptics _haptics;

  static const _words = {
    'HapticFeedbackType.lightImpact': HapticWord.tap,
    'HapticFeedbackType.selectionClick': HapticWord.select,
    'HapticFeedbackType.successNotification': HapticWord.confirm,
    'HapticFeedbackType.errorNotification': HapticWord.warn,
  };

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    if (channel == SystemChannels.platform.name && message != null) {
      final call = SystemChannels.platform.codec.decodeMethodCall(message);
      if (call.method == 'HapticFeedback.vibrate') {
        if (_words[call.arguments] case final word?) _haptics.heard(word);
      }
    }
    return _inner.send(channel, message);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) =>
      _inner.setMessageHandler(channel, handler);

  @override
  // ignore: deprecated_member_use
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) =>
      // ignore: deprecated_member_use
      _inner.handlePlatformMessage(channel, data, callback);
}

/// The gallery's binding, which listens for haptics. Create it before
/// `runApp`.
final class GalleryBinding extends WidgetsFlutterBinding {
  GalleryBinding();

  final haptics = PlayedHaptics();

  @override
  BinaryMessenger createBinaryMessenger() =>
      HapticListeningMessenger(super.createBinaryMessenger(), haptics);
}

/// Names each haptic in a small label at the bottom of the screen while
/// "Show haptics" is on.
final class ShowHaptics extends StatefulWidget {
  const ShowHaptics({super.key, required this.haptics, required this.child});

  final PlayedHaptics haptics;
  final Widget child;

  @override
  State<ShowHaptics> createState() => _ShowHapticsState();
}

final class _ShowHapticsState extends State<ShowHaptics> {
  static const _held = Duration(milliseconds: 900);

  HapticWord? _word;
  var _shown = false;
  var _enabled = false;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    widget.haptics.addListener(_heard);
  }

  @override
  void didUpdateWidget(ShowHaptics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.haptics == widget.haptics) return;
    oldWidget.haptics.removeListener(_heard);
    widget.haptics.addListener(_heard);
  }

  @override
  void dispose() {
    widget.haptics.removeListener(_heard);
    _hide?.cancel();
    super.dispose();
  }

  /// Recipes play some haptics while they build, so the label waits for the
  /// frame to finish rather than rebuilding in the middle of it.
  void _heard() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      scheduler.addPostFrameCallback((_) => _show());
    } else {
      _show();
    }
  }

  void _show() {
    if (!mounted || !_enabled) return;
    setState(() {
      _word = widget.haptics.last;
      _shown = true;
    });
    _hide?.cancel();
    _hide = Timer(_held, () {
      if (mounted) setState(() => _shown = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _enabled = GallerySettingsScope.of(context).showHaptics;
    final showing = _shown && _enabled;
    final feel = showing ? context.motion.enter : context.motion.exit;
    return Stack(
      children: [
        widget.child,
        if (_word case final word?)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Center(
                  child: AnimatedSlide(
                    offset: showing ? Offset.zero : const Offset(0, 0.6),
                    duration: feel.duration,
                    curve: feel.curve,
                    child: AnimatedOpacity(
                      opacity: showing ? 1 : 0,
                      duration: feel.duration,
                      child: _HapticLabel(word),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final class _HapticLabel extends StatelessWidget {
  const _HapticLabel(this.word);

  final HapticWord word;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: GalleryColors.ink,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // The label sits above every page, outside any Material, so it brings
      // its own text style instead of inheriting Flutter's yellow fallback.
      child: DefaultTextStyle(
        style: GalleryType.label.copyWith(color: GalleryColors.paper),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'haptic  ',
                style: TextStyle(
                  color: GalleryColors.paper.withValues(alpha: 0.6),
                ),
              ),
              TextSpan(text: word.name),
            ],
          ),
        ),
      ),
    ),
  );
}
