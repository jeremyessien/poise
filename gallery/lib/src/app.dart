import 'package:flutter/material.dart';

import 'gather/gather_screen.dart';
import 'home_page.dart';
import 'menu_page.dart';
import 'recipe_page.dart';
import 'recipes.dart';
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
      builder: (context) {
        final path = route.name ?? '/';
        return switch ((
          path,
          MotionWord.fromPath(path),
          GalleryRecipe.fromPath(path),
        )) {
          ('/poise', _, _) => const MenuPage(),
          ('/words', _, _) => const HomePage(),
          (_, final word?, _) => WordPage(word: word),
          (_, _, final recipe?) => RecipePage(recipe: recipe),
          _ => const GatherScreen(),
        };
      },
    ),
  );
}
