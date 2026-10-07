import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

final class GallerySettings extends ChangeNotifier {
  static const slowMotionFactor = 5.0;

  bool _slowMotion = false;
  bool _reduceMotion = false;
  bool _showCurve = false;

  bool get slowMotion => _slowMotion;
  set slowMotion(bool value) {
    if (value == _slowMotion) return;
    _slowMotion = value;
    timeDilation = value ? slowMotionFactor : 1;
    notifyListeners();
  }

  bool get reduceMotion => _reduceMotion;
  set reduceMotion(bool value) {
    if (value == _reduceMotion) return;
    _reduceMotion = value;
    notifyListeners();
  }

  bool get showCurve => _showCurve;
  set showCurve(bool value) {
    if (value == _showCurve) return;
    _showCurve = value;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_slowMotion) timeDilation = 1;
    super.dispose();
  }
}

final class GallerySettingsScope extends StatelessWidget {
  const GallerySettingsScope({
    super.key,
    required this.settings,
    required this.child,
  });

  final GallerySettings settings;
  final Widget child;

  static GallerySettings of(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<_SettingsNotifier>()
        ?.notifier;
    if (settings == null) {
      throw FlutterError('No GallerySettingsScope above this widget.');
    }
    return settings;
  }

  @override
  Widget build(BuildContext context) => _SettingsNotifier(
    notifier: settings,
    child: ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        final phoneAsksForLessMotion = MediaQuery.disableAnimationsOf(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: phoneAsksForLessMotion || settings.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      child: child,
    ),
  );
}

final class _SettingsNotifier extends InheritedNotifier<GallerySettings> {
  const _SettingsNotifier({required super.notifier, required super.child});
}

final class GalleryControls extends StatelessWidget {
  const GalleryControls({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GallerySettingsScope.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Slow motion'),
          selected: settings.slowMotion,
          onSelected: (value) => settings.slowMotion = value,
        ),
        FilterChip(
          label: const Text('Reduce motion'),
          selected: settings.reduceMotion,
          onSelected: (value) => settings.reduceMotion = value,
        ),
        FilterChip(
          label: const Text('Show curve'),
          selected: settings.showCurve,
          onSelected: (value) => settings.showCurve = value,
        ),
      ],
    );
  }
}
