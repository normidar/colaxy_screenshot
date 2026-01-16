import 'package:colaxy_screenshot/colaxy_screenshot.dart';

Future<void> takeScreenshots(ScreenshotConfig config) async {
  final jsonConfig = await getJsonConfig();
  final appPath = jsonConfig['app_path']!;
  final service = ScreenshotService(config: config, appPath: appPath);
  await service.executeScreenshots();
}
