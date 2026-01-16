import 'dart:io';

import 'package:colaxy_screenshot/colaxy_screenshot.dart';
import 'package:flutter/foundation.dart';

Future<bool> checkScreenshotRunable() async {
  if (!kDebugMode) {
    return false;
  }
  if (!Platform.isMacOS) {
    return false;
  }

  // get the config.yaml
  final config = await getJsonConfig();
  final launchMode = config['launch_mode'];
  if (launchMode != 'screenshot') {
    return false;
  }

  return true;
}
