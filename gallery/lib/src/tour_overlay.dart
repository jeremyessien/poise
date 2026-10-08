import 'package:flutter/material.dart';
import 'package:poise_registry/reveal/reveal.dart';

import 'theme.dart';
import 'tour.dart';

final class GalleryTourScope extends InheritedNotifier<GalleryTour> {
  const GalleryTourScope({
    super.key,
    required GalleryTour tour,
    required super.child,
  }) : super(notifier: tour);

  /// The tour, without listening to it. Use a [ListenableBuilder] to follow
  /// its captions.
  static GalleryTour of(BuildContext context) {
    final tour = context
        .getInheritedWidgetOfExactType<GalleryTourScope>()
        ?.notifier;
    if (tour == null) {
      throw FlutterError('No GalleryTourScope above this widget.');
    }
    return tour;
  }
}

/// Shows the tour's captions along the top of every page, and stops the tour
/// the moment a real finger touches the screen.
final class TourOverlay extends StatelessWidget {
  const TourOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tour = GalleryTourScope.of(context);
    return Listener(
      onPointerDown: (event) {
        if (!GalleryTour.isTourTouch(event)) tour.stop();
      },
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: ListenableBuilder(
                  listenable: tour,
                  builder: (context, _) => Reveal(
                    visible: tour.showsCaption,
                    revealOnFirstBuild: false,
                    from: RevealFrom.top,
                    child: TourCaption(
                      title: tour.caption.title,
                      line: tour.caption.line,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class TourCaption extends StatelessWidget {
  const TourCaption({super.key, required this.title, required this.line});

  final String title;
  final String line;

  @override
  Widget build(BuildContext context) => Material(
    color: GalleryColors.paper,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: GalleryColors.grid),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GalleryType.listWord.copyWith(fontSize: 30),
          ),
          Text(line, textAlign: TextAlign.center, style: GalleryType.group),
        ],
      ),
    ),
  );
}
