import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/haptic_labels.dart';
import 'src/settings.dart';

void main() {
  final binding = GalleryBinding();
  usePathUrlStrategy();
  runApp(GalleryApp(settings: GallerySettings(), haptics: binding.haptics));
}
