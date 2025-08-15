import 'dart:ui';

enum ScreenshotMode { phone, tablet }

class ScreenshotModeInfo {
  const ScreenshotModeInfo({
    required this.mode,
    required this.deviceSize,
  });

  final ScreenshotMode mode;
  final Size deviceSize;
}
