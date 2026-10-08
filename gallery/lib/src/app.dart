import 'package:flutter/material.dart';

import 'gather/gather_screen.dart';
import 'home_page.dart';
import 'settings.dart';
import 'theme.dart';
import 'word_page.dart';
import 'words.dart';

final class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key, required this.settings});

  final GallerySettings settings;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'poise gallery',
    debugShowCheckedModeBanner: false,
    theme: galleryTheme(),
    builder: (context, child) => GallerySettingsScope(
      settings: settings,
      child: child ?? const SizedBox.shrink(),
    ),
    onGenerateRoute: (route) => MaterialPageRoute<void>(
      settings: route,
      builder: (context) => switch (route.name ?? '/') {
        '/poise' => const HomePage(),
        final path => switch (MotionWord.fromPath(path)) {
          final word? => WordPage(word: word),
          null => const GatherScreen(),
        },
      },
    ),
  );
}
