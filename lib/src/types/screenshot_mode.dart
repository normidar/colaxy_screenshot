import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/widgets.dart';
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

  DeviceInfo toDeviceInfo() {
    switch (mode) {
      case ScreenshotMode.phone:
        return DeviceInfo.genericPhone(
          platform: TargetPlatform.iOS,
          id: 'iphone_13',
          name: 'iPhone 13',
          screenSize: const Size(390, 844),
          safeAreas: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          rotatedSafeAreas: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 10,
          ),
          pixelRatio: 3,
        );
      case ScreenshotMode.tablet:
        return DeviceInfo.genericTablet(
          platform: TargetPlatform.iOS,
          id: 'ipad_pro_11',
          name: 'iPad Pro 11"',
          screenSize: const Size(834, 1194),
          safeAreas: const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          rotatedSafeAreas: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
        );
    }
  }
}
