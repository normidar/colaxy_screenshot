import 'dart:io';
import 'dart:ui' as ui;

import 'package:colaxy_screenshot/colaxy_screenshot.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';

/// Android用のロケールマッピング
const _androidLocaleMap = {'en': 'en-US', 'ja': 'ja-JP', 'zh': 'zh-CN'};

/// iOS用のロケールマッピング
const _iOSLocaleMap = {'en': 'en-US', 'ja': 'ja', 'zh': 'zh-Hans'};

/// メインのスクリーンショットサービス
class ScreenshotService {
  ScreenshotService({required this.config, required this.appPath});

  final ScreenshotConfig config;

  final String appPath;

  GlobalKey? _appKey;

  /// スクリーンショットを実行する
  Future<void> executeScreenshots() async {
    final defaultDelay = config.captureDelay;
    var isFirst = true;
    // 各デバイス × 各言語 × 各ページの組み合わせでスクリーンショットを作成
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
  }

  /// 言語設定を含むアプリウィジェットを構築
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
      child: EasyLocalization(
        supportedLocales: const [
          Locale('ja', 'JP'),
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: Builder(
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
                      device: modeInfo.toDeviceInfo(),
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

  /// マーケティング用のレイアウトを構築（背景 + タイトル + デバイスフレーム）
  Widget _buildMarketingLayout(Widget deviceFrame, ScreenshotPageInfo page) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        width: 1080, // 一般的なスクリーンショットサイズ
        height: 1920,
        color: const ui.Color.fromARGB(255, 216, 255, 239),
        child: Column(
          children: [
            // 上部のタイトルエリア
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

            // デバイスフレーム（中央配置）
            Expanded(
              child: Center(
                child: deviceFrame,
              ),
            ),

            // 下部のスペース
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// 単一ページのスクリーンショットを撮影してアップロード
  Future<void> _capturePageScreenshot({
    required Locale locale,
    required ScreenshotPageInfo page,
    required ScreenshotModeInfo modeInfo,
  }) async {
    // runAppでアプリを起動
    final app =
        _buildAppWithLocale(locale: locale, page: page, modeInfo: modeInfo);

    runApp(app);

    // アプリが完全に描画されるまで待機
    await Future<void>.delayed(config.captureDelay);

    // フレームのコールバックを待機して描画が完了することを確認
    await WidgetsBinding.instance.endOfFrame;

    // RepaintBoundaryからスクリーンショットを取得
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
      throw Exception('スクリーンショットの撮影に失敗しました');
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

  /// 既存のiPhoneスクリーンショットファイルを削除する
  /// パターン: ${index}_iphone65_$index.*.png
  void _deleteExistingScreenshots({
    required String directoryPath,
    required String deviceName,
    required int index,
  }) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return;

    // パターンに一致するファイルを検索して削除
    final pattern = RegExp('^${index}_${deviceName}_$index' r'\..*\.png$');

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => pattern.hasMatch(file.uri.pathSegments.last));

    for (final file in files) {
      try {
        file.deleteSync();
        print('削除しました: ${file.path}');
      } catch (e) {
        print('ファイル削除に失敗しました: ${file.path}, エラー: $e');
      }
    }
  }
}
