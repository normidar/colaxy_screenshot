import 'package:coglax_screenshot/coglax_screenshot.dart';

Future<void> takeScreenshots(ScreenshotConfig config) async {
  final service = ScreenshotService(config);
  await service.executeScreenshots();
}
