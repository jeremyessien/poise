import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

abstract final class GalleryColors {
  static const paper = Color(0xFFEEF1EE);
  static const grid = Color(0xFFDDE2DD);
  static const lane = Color(0xFFF6F8F6);
  static const ink = Color(0xFF1A2230);
  static const quietInk = Color(0xFF5A6472);
  static const calm = Color(0xFF5B7C99);
  static const crisp = Color(0xFF0F9D8A);
  static const playful = Color(0xFFF2A93B);
}

enum Personality {
  calm('calm', 'Settled and quiet', PoiseMotion.calm, GalleryColors.calm),
  crisp('crisp', 'Quick and exact', PoiseMotion.crisp, GalleryColors.crisp),
  playful(
    'playful',
    'Springy and alive',
    PoiseMotion.playful,
    GalleryColors.playful,
  );

  const Personality(this.label, this.tagline, this.motion, this.color);

  final String label;
  final String tagline;
  final PoiseMotion motion;
  final Color color;
}

/// The raised panel everything on chart paper sits in.
BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
  color: GalleryColors.lane,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: GalleryColors.grid),
);

abstract final class GalleryType {
  static const _sans = 'Instrument Sans';
  static const _serif = 'Instrument Serif';

  static const word = TextStyle(
    fontFamily: _serif,
    fontStyle: FontStyle.italic,
    fontSize: 64,
    height: 1,
    letterSpacing: -1,
    color: GalleryColors.ink,
  );

  static const listWord = TextStyle(
    fontFamily: _serif,
    fontStyle: FontStyle.italic,
    fontSize: 36,
    height: 1.1,
    color: GalleryColors.ink,
  );

  static const body = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    height: 1.45,
    color: GalleryColors.quietInk,
  );

  static const label = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontVariations: [FontVariation.weight(600)],
    color: GalleryColors.ink,
  );

  static const group = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontVariations: [FontVariation.weight(500)],
    color: GalleryColors.quietInk,
  );
}

final galleryTheme = ThemeData(
  scaffoldBackgroundColor: GalleryColors.paper,
  fontFamily: GalleryType.body.fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: GalleryColors.ink,
    surface: GalleryColors.paper,
    onSurface: GalleryColors.ink,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: GalleryColors.ink,
      foregroundColor: GalleryColors.paper,
      minimumSize: const Size.fromHeight(56),
      textStyle: GalleryType.label.copyWith(fontSize: 16),
      shape: const StadiumBorder(),
    ),
  ),
);
