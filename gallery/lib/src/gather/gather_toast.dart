import 'package:flutter/cupertino.dart';

import 'gather_style.dart';

final class GatherToast extends StatelessWidget {
  const GatherToast({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: GatherColors.dial,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.heart_fill,
          size: 16,
          color: GatherColors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GatherType.detail.copyWith(color: GatherColors.dialText),
        ),
      ],
    ),
  );
}
