import 'package:flutter/widgets.dart';
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

/// Shows the tour's captions above every page, and stops the tour the moment
/// a real finger touches the screen.
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
            left: 20,
            right: 20,
            bottom: 164,
            child: IgnorePointer(
              child: Center(
                child: ListenableBuilder(
                  listenable: tour,
                  builder: (context, _) => Reveal(
                    visible: tour.showsCaption,
                    revealOnFirstBuild: false,
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
    decoration: BoxDecoration(
      color: GalleryColors.paper,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: GalleryColors.grid),
    ),
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
  );
}
