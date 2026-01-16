import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Get config file as json
Future<Map<String, String>> getJsonConfig() async {
  final configString = await rootBundle.loadString('assets/config.json');
  final jsonConfig = jsonDecode(configString) as Map<String, dynamic>;
  return jsonConfig.cast<String, String>();
}

/// Reset config file
Future<void> resetJsonConfig() async {
  final jsonConfig = await getJsonConfig();
  final configPath = '${jsonConfig['app_path']!}/assets/config.json';

  jsonConfig['launch_mode'] = '_${jsonConfig['launch_mode']}';
  final jsonString = jsonEncode(jsonConfig);
  File(configPath).writeAsStringSync(jsonString);
}
