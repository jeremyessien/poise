import 'package:flutter/widgets.dart';

abstract final class GatherColors {
  static const background = Color(0xFFF4F4F6);
  static const card = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFE6E6EA);
  static const text = Color(0xFF1C1C1E);
  static const secondaryText = Color(0xFF6E6E73);
  static const accent = Color(0xFFFF5A5F);
  static const dial = Color(0xFF1C1C1E);
  static const dialText = Color(0xFFF4F4F6);
}

abstract final class GatherType {
  static const title = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: GatherColors.text,
  );

  static const subtitle = TextStyle(
    fontSize: 17,
    color: GatherColors.secondaryText,
  );

  static const eventTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: GatherColors.text,
  );

  static const detail = TextStyle(
    fontSize: 14,
    color: GatherColors.secondaryText,
  );

  static const tileDay = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: GatherColors.text,
  );

  static const tileDate = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: GatherColors.text,
  );

  static const dial = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
