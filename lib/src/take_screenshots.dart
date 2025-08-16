import 'package:colaxy_screenshot/colaxy_screenshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

Future<void> takeScreenshots(ScreenshotConfig config) async {
  debugPrint('takeScreenshots');
  final configString = await rootBundle.loadString('assets/config.yaml');
  final yamlConfig = loadYaml(configString) as Map<dynamic, dynamic>;
  final appPath = yamlConfig['app_path'] as String;
  final service = ScreenshotService(config: config, appPath: appPath);
  await service.executeScreenshots();
}
