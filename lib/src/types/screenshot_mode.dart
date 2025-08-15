import 'dart:ui';

import 'package:window_size/window_size.dart';

enum ScreenshotMode { phone, tablet }

class ScreenshotModeInfo {
  const ScreenshotModeInfo({
    required this.mode,
    required this.deviceSize,
  });

  static List<ScreenshotModeInfo> get all => [
        const ScreenshotModeInfo(
            mode: ScreenshotMode.phone, deviceSize: Size(1284, 2778)),
        const ScreenshotModeInfo(
            mode: ScreenshotMode.tablet, deviceSize: Size(2048, 2732)),
      ];

  final ScreenshotMode mode;

  final Size deviceSize;

  void setWindowToSize() {
    const rate = 3.3;
    setWindowMinSize(deviceSize / rate);
    setWindowMaxSize(deviceSize / rate);
    setWindowFrame(
        Rect.fromLTWH(100, 100, deviceSize.width, deviceSize.height));
  }
}
