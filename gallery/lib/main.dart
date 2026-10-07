import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/settings.dart';

void main() {
  usePathUrlStrategy();
  runApp(GalleryApp(settings: GallerySettings()));
}
