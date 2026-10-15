import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/app.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/tour_overlay.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  // The live binding drops the tour's own pointer events otherwise.
  binding.shouldPropagateDevicePointerEvents = true;

  testWidgets('the tour plays through on this phone', (tester) async {
    final settings = GallerySettings();
    await tester.pumpWidget(GalleryApp(settings: settings));
    await tester.pumpAndSettle();
    final tour = GalleryTourScope.of(tester.element(find.byType(GatherScreen)));

    await binding.watchPerformance(() async {
      final played = tour.play();
      while (tour.isRunning) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      await played;
    }, reportKey: 'tour');

    await tester.pumpAndSettle();
    expect(find.byType(GatherScreen), findsOneWidget);
    settings.dispose();
  });
}
