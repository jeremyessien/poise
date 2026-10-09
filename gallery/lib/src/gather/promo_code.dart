import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:poise_registry/shake/shake.dart';

import 'gather_style.dart';

/// A promo code field that shakes when the code doesn't work.
final class PromoCode extends StatefulWidget {
  const PromoCode({super.key});

  /// The one code Gather accepts.
  static const working = 'GATHER';

  static const apply = 'Apply';
  static const didNotWork = "That code didn't work";
  static const worked = 'Code applied: 10% off';

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

final class _PromoCodeState extends State<PromoCode> {
  final _code = TextEditingController();
  var _failures = 0;
  var _message = '';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// A failure is announced by the shake, every time. Success has no shake,
  /// so it's announced here. The message itself stays quiet, or a screen
  /// reader would hear each failure twice.
  void _apply() {
    final worked = _code.text.trim().toUpperCase() == PromoCode.working;
    setState(() {
      if (worked) {
        _message = PromoCode.worked;
      } else {
        _failures++;
        _message = PromoCode.didNotWork;
      }
    });
    if (worked) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        PromoCode.worked,
        Directionality.of(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Shake(
        trigger: _failures,
        announcement: PromoCode.didNotWork,
        child: Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _code,
                placeholder: 'Promo code',
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _apply(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: GatherColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GatherColors.hairline),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              onPressed: _apply,
              child: const Text(
                PromoCode.apply,
                style: TextStyle(color: GatherColors.accent),
              ),
            ),
          ],
        ),
      ),
      if (_message.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(_message, style: GatherType.detail),
        ),
    ],
  );
}
