import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

Future<bool> checkScreenshotRunable() async {
  if (!kDebugMode) {
    return false;
  }
  if (!Platform.isMacOS) {
    return false;
  }

  // get the config.yaml
  final configString = await rootBundle.loadString('assets/config.yaml');
  final config = loadYaml(configString) as Map<dynamic, dynamic>;
  final launchMode = config['launch_mode'] as String?;
  if (launchMode != 'screenshot') {
    return false;
  }

  return true;
}
