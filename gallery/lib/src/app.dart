import 'package:flutter/material.dart';

import 'gather/gather_screen.dart';
import 'menu_page.dart';
import 'recipe_page.dart';
import 'recipes.dart';
import 'settings.dart';
import 'theme.dart';
import 'touches.dart';
import 'tour.dart';
import 'tour_overlay.dart';
import 'word_page.dart';
import 'words.dart';
import 'words_page.dart';

final class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, required this.settings});

  final GallerySettings settings;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

final class _GalleryAppState extends State<GalleryApp> {
  final _navigator = GlobalKey<NavigatorState>();
  late final _tour = GalleryTour(
    navigator: _navigator,
    settings: widget.settings,
  );

  @override
  void dispose() {
    _tour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'poise gallery',
    debugShowCheckedModeBanner: false,
    theme: galleryTheme,
    navigatorKey: _navigator,
    builder: (context, child) => GallerySettingsScope(
      settings: widget.settings,
      child: GalleryTourScope(
        tour: _tour,
        child: ShowTouches(
          child: TourOverlay(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ),
    onGenerateRoute: (route) => MaterialPageRoute<void>(
      settings: route,
      builder: (context) {
        final path = route.name ?? '/';
        return switch ((
          path,
          GalleryWord.fromPath(path),
          GalleryRecipe.fromPath(path),
        )) {
          ('/poise', _, _) => const MenuPage(),
          ('/words', _, _) => const WordsPage(),
          (_, final word?, _) => WordPage(word: word),
          (_, _, final recipe?) => RecipePage(recipe: recipe),
          _ => const GatherScreen(),
        };
      },
    ),
  );
}
