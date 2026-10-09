import 'package:flutter/widgets.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'gather_style.dart';

/// Gather's filled button. Its [label] can be any widget, so a [Text] or a
/// label that changes in place both work.
final class GatherButton extends StatelessWidget {
  const GatherButton({super.key, required this.label, required this.onTap});

  final Widget label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GatherColors.accent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DefaultTextStyle.merge(
        style: GatherType.eventTitle.copyWith(color: GatherColors.card),
        child: label,
      ),
    ),
  );
}
