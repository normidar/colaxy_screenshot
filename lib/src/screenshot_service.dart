import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:colaxy_screenshot/colaxy_screenshot.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' hide Color, Image;
import 'package:window_size/window_size.dart';

/// Locale mapping for Android
const _androidLocaleMap = {
  'en': 'en-US',
  'ja': 'ja-JP',
  'zh': 'zh-CN',
  'es': 'es-ES',
  'pt': 'pt-PT',
  'tr': 'tr-TR',
};

/// Locale mapping for iOS
const _iOSLocaleMap = {
  'en': 'en-US',
  'ja': 'ja',
  'zh': 'zh-Hans',
  'es': 'es-ES',
  'pt': 'pt-PT',
  'tr': 'tr',
};

/// Main screenshot service
class ScreenshotService {
  ScreenshotService({required this.config, required this.appPath});

  final ScreenshotConfig config;

  final String appPath;

  GlobalKey? _appKey;

  /// Run the screenshot workflow
  Future<void> executeScreenshots() async {
    // set Feature Graphic Page
    await getFeatureGraphicScreenshot();

    final defaultDelay = config.captureDelay;
    var isFirst = true;
    // Capture screenshots for each combination of device, locale, and page
    for (final mode in ScreenshotModeInfo.all) {
      mode.setWindowToSize();
      for (final locale in config.supportedLocales) {
        for (final page in config.pages) {
          if (isFirst) {
            config.captureDelay = const Duration(seconds: 3);
            isFirst = false;
          }
          await _capturePageScreenshot(
            locale: locale,
            page: page,
            modeInfo: mode,
          );
          config.captureDelay = defaultDelay;
        }
      }
    }

    // reset config file
    await resetJsonConfig();

    // exit the app
    exit(0);
  }

  /// Feature Graphic Page generate
  Future<void> getFeatureGraphicScreenshot() async {
    _appKey = GlobalKey();

    final Widget appWidget = ProviderScope(
      overrides: config.overrides,
      child: config.easyLocalizationWrapper(
        Builder(
          builder: (context) {
            return FutureBuilder(
              future: () async {
                Intl.defaultLocale = 'en';
                await context.setLocale(const Locale('en', 'US'));
                return null;
              }(),
              builder: (_, __) => config.wrapFunction(
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8BC34A), // Light Green
                        Color(0xFF009688), // Teal
                      ],
                    ),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 200,
                          child: Transform.rotate(
                            angle: -math.pi /
                                6, // Larger numbers reduce the rotation angle
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                'assets/app_icons/icon.png',
                                width: 400,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -50,
                          right: 200,
                          child: Transform.rotate(
                            angle: math.pi /
                                6, // Larger numbers reduce the rotation angle
                            child: DeviceFrame(
                              device: const ScreenshotModeInfo(
                                mode: ScreenshotMode.phone,
                                deviceSize: Size(642, 1389),
                              ).toDeviceInfo(),
                              screen: config.featureGraphicPage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    setWindowToSize(const Size(1024, 500));
    runApp(RepaintBoundary(
      key: _appKey,
      child: appWidget,
    ));
    await Future<void>.delayed(const Duration(seconds: 3));
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _appKey?.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary!.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();
    if (imageBytes == null) {
      throw Exception('Failed to capture the screenshot');
    }
    final pngImage = decodePng(imageBytes)!;
    final resizedImage = copyResize(pngImage, width: 1024, height: 500);
    File('$appPath/fastlane/metadata/android/featureGraphic.png')
        .writeAsBytesSync(encodePng(resizedImage));
  }

  void setWindowToSize(Size deviceSize) {
    const rate = 3.3;
    setWindowMinSize(deviceSize / rate);
    setWindowMaxSize(deviceSize / rate);
    setWindowFrame(
        Rect.fromLTWH(100, 100, deviceSize.width, deviceSize.height));
  }

  /// Build the app widget with the given locale
  Widget _buildAppWithLocale({
    required Locale locale,
    required ScreenshotPageInfo page,
    required ScreenshotModeInfo modeInfo,
  }) {
    _appKey = GlobalKey();

    final Widget appWidget = ProviderScope(
      overrides: [
        ...config.overrides,
        ...page.overrides ?? [],
      ],
      child: config.easyLocalizationWrapper(
        Builder(
          builder: (context) {
            return FutureBuilder(
              future: () async {
                Intl.defaultLocale = locale.languageCode;
                await context.setLocale(locale);
                return null;
              }(),
              builder: (_, __) => config.wrapFunction(
                _buildMarketingLayout(
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: DeviceFrame(
                      device: modeInfo.mode == ScreenshotMode.phone
                          ? Devices.ios.iPhone13
                          : Devices.ios.iPad,
                      screen: page.widget(),
                    ),
                  ),
                  page,
                ),
              ),
            );
          },
        ),
      ),
    );

    return RepaintBoundary(
      key: _appKey,
      child: appWidget,
    );
  }

  /// Build the marketing layout (background + title + device frame)
  Widget _buildMarketingLayout(Widget deviceFrame, ScreenshotPageInfo page) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        width: 1080, // Standard screenshot size
        height: 1920,
        color: const ui.Color.fromARGB(255, 216, 255, 239),
        child: Column(
          children: [
            // Title area at the top
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 80, 40, 20),
              child: Text(
                page.titleTextKey.tr(),
                style: const TextStyle(
                  color: ui.Color.fromARGB(255, 25, 178, 255),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Centered device frame
            Expanded(
              child: Center(
                child: deviceFrame,
              ),
            ),

            // Bottom spacing
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// Capture and upload a screenshot for a single page
  Future<void> _capturePageScreenshot({
    required Locale locale,
    required ScreenshotPageInfo page,
    required ScreenshotModeInfo modeInfo,
  }) async {
    // Launch the app with runApp
    final app =
        _buildAppWithLocale(locale: locale, page: page, modeInfo: modeInfo);

    runApp(app);

    // Wait until the app finishes rendering
    await Future<void>.delayed(config.captureDelay);

    // Wait for the frame callback to ensure rendering is complete
    await WidgetsBinding.instance.endOfFrame;

    // Retrieve the screenshot from the RepaintBoundary
    Uint8List? imageBytes;
    final currentContext = _appKey?.currentContext;
    if (currentContext != null && currentContext.mounted) {
      final boundary =
          currentContext.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      imageBytes = byteData?.buffer.asUint8List();
    }

    if (imageBytes == null) {
      throw Exception('Failed to capture the screenshot');
    }
    final image = decodePng(imageBytes)!;

    final index = page.index;
    final screenshotId = page.name;

    // image resize
    final width = modeInfo.deviceSize.width.toInt();
    final height = modeInfo.deviceSize.height.toInt();
    final resizedImage = copyResize(image, width: width, height: height);

    switch (modeInfo.mode) {
      case ScreenshotMode.phone:
        // save to iphone screenshot folder
        final iOSLocaleName = _iOSLocaleMap[locale.languageCode]!;
        final iphonePath = '$appPath/fastlane/screenshots/$iOSLocaleName';
        Directory(iphonePath).createSync(recursive: true);

        // Delete existing files with pattern ${index}_iphone65_$index.*.png
        _deleteExistingScreenshots(
          directoryPath: iphonePath,
          deviceName: 'iphone65',
          index: index,
        );

        File('$iphonePath/${index}_iphone65_$index.$screenshotId.png')
            .writeAsBytesSync(encodePng(resizedImage));

        // save to android screenshot folder
        final androidLocaleName = _androidLocaleMap[locale.languageCode]!;
        final androidPhonePath =
            '$appPath/fastlane/metadata/android/$androidLocaleName/images/phoneScreenshots';
        final androidSevenInchPath =
            '$appPath/fastlane/metadata/android/$androidLocaleName/images/sevenInchScreenshots';
        Directory(androidPhonePath).createSync(recursive: true);
        Directory(androidSevenInchPath).createSync(recursive: true);
        File('$androidPhonePath/${index}_$androidLocaleName.png')
            .writeAsBytesSync(encodePng(resizedImage));
        File('$androidSevenInchPath/${index}_$androidLocaleName.png')
            .writeAsBytesSync(encodePng(resizedImage));

      case ScreenshotMode.tablet:
        // save to ipad screenshot folder
        final iOSLocaleName = _iOSLocaleMap[locale.languageCode]!;
        final ipadPath = '$appPath/fastlane/screenshots/$iOSLocaleName';
        Directory(ipadPath).createSync(recursive: true);

        // Delete existing files with pattern ${index}_ipadPro129_$index.*.png
        _deleteExistingScreenshots(
          directoryPath: ipadPath,
          deviceName: 'ipadPro129',
          index: index,
        );

        File('$ipadPath/${index}_ipadPro129_$index.$screenshotId.png')
            .writeAsBytesSync(encodePng(resizedImage));

        // save to android tablet screenshot folder
        final androidLocaleName = _androidLocaleMap[locale.languageCode]!;
        final androidTenInchPath =
            '$appPath/fastlane/metadata/android/$androidLocaleName/images/tenInchScreenshots';
        Directory(androidTenInchPath).createSync(recursive: true);
        File('$androidTenInchPath/${index}_$androidLocaleName.png')
            .writeAsBytesSync(encodePng(resizedImage));
    }
  }

  /// Remove existing iPhone screenshot files
  /// Pattern: ${index}_iphone65_$index.*.png
  void _deleteExistingScreenshots({
    required String directoryPath,
    required String deviceName,
    required int index,
  }) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return;

    // Find and delete files that match the pattern
    final pattern = RegExp('^${index}_${deviceName}_$index' r'\..*\.png$');

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => pattern.hasMatch(file.uri.pathSegments.last));

    for (final file in files) {
      try {
        file.deleteSync();
        print('Deleted: ${file.path}');
      } catch (e) {
        print('Failed to delete file: ${file.path}, Error: $e');
      }
    }
  }
}
